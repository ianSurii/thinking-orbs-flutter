import 'dart:math' as math;

import 'core.dart';
import 'profiles.dart';

typedef _Path = (double, double) Function(double f);

double _smoothE(double x) {
  return x * x * (3.0 - 2.0 * x);
}

_Path _polyPath(List<(double, double)> verts) {
  final v = verts.length;
  final l = <double>[];
  double total = 0.0;

  for (int i = 0; i < v; i++) {
    final a = verts[i];
    final b = verts[(i + 1) % v];
    final dx = b.$1 - a.$1;
    final dy = b.$2 - a.$2;
    final segLen = math.sqrt(dx * dx + dy * dy);
    l.add(segLen);
    total += segLen;
  }

  return (double f) {
    var target = f * total;
    int i = 0;
    while (target > l[i] && i < v - 1) {
      target -= l[i];
      i++;
    }
    final a = verts[i];
    final b = verts[(i + 1) % v];
    final ff = l[i] > 0.0 ? math.min(1.0, target / l[i]) : 0.0;
    return (a.$1 + (b.$1 - a.$1) * ff, a.$2 + (b.$2 - a.$2) * ff);
  };
}

(double, double) _circlePath(double f) {
  final a = -math.pi / 2.0 + f * 2.0 * math.pi;
  return (math.cos(a) * 0.24, math.sin(a) * 0.24);
}

final _Path _trianglePath = _polyPath(const [
  (0.0, -0.26),
  (0.24, 0.16),
  (-0.24, 0.16),
]);

// 5-vertex walk so the path starts at top-centre like the other shapes
final _Path _squarePath = _polyPath(const [
  (0.0, -0.2),
  (0.2, -0.2),
  (0.2, 0.2),
  (-0.2, 0.2),
  (-0.2, -0.2),
]);

final List<_Path> _cycle = [_circlePath, _trianglePath, _squarePath];

int _morphN(double d) {
  return math.max(6, (34.0 * d).round());
}

const double _kHold = 1.4;
const double _kMorph = 0.9;
const double _kSeg = _kHold + _kMorph;

/// Morph mode: shaping — a dotted outline cycling circle → triangle → square → circle.
OrbFrame frameMorph(double size, double t, ModeOpts o) {
  final kCount = _cycle.length;
  final tc = t % (_kSeg * kCount);
  final k = (tc / _kSeg).floor();
  final local = tc - k * _kSeg;
  final m = local > _kHold ? _smoothE((local - _kHold) / _kMorph) : 0.0;
  final sprd = o['spread'] ?? 1.0;

  // Blend the two shape paths at m, then measure the blended outline
  final pA = _cycle[k];
  final pB = _cycle[(k + 1) % kCount];
  const mSteps = 160;
  final pts = <(double, double)>[];

  for (int i = 0; i < mSteps; i++) {
    final f = i / mSteps.toDouble();
    final a = pA(f);
    final b = pB(f);
    pts.add((
      (a.$1 + (b.$1 - a.$1) * m) * sprd,
      (a.$2 + (b.$2 - a.$2) * m) * sprd,
    ));
  }

  final lList = <double>[];
  double total = 0.0;
  for (int i = 0; i < mSteps; i++) {
    final a = pts[i];
    final b = pts[(i + 1) % mSteps];
    final dx = b.$1 - a.$1;
    final dy = b.$2 - a.$2;
    final len = math.sqrt(dx * dx + dy * dy);
    lList.add(len);
    total += len;
  }

  final n = _morphN(o['iconD'] ?? 1.0);
  final re = (o['rDot'] ?? 0.021) * 1.35 * sprd;
  final pulse = 1.0 + 0.02 * math.sin(local * 3.1);

  final dots = <Dot>[];
  final c2 = size / 2.0;
  int seg = 0;
  double acc = 0.0;

  for (int k2 = 0; k2 < n; k2++) {
    final target = (k2 / n.toDouble()) * total;
    while (acc + lList[seg] < target && seg < mSteps - 1) {
      acc += lList[seg];
      seg++;
    }
    final a = pts[seg];
    final b = pts[(seg + 1) % mSteps];
    final f =
        lList[seg] > 0.0 ? math.min(1.0, (target - acc) / lList[seg]) : 0.0;
    final x = (a.$1 + (b.$1 - a.$1) * f) * pulse;
    final y = (a.$2 + (b.$2 - a.$2) * f) * pulse;

    dots.add(Dot(
      x: c2 + x * size,
      y: c2 + y * size,
      z: 0.0,
      r: math.max(0.35, re * size),
      white: 0.1,
    ));
  }

  return finalizeFrame(dots, const [], o['rMin'] ?? 0.25);
}
