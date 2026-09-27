import 'dart:math' as math;

import 'core.dart';
import 'profiles.dart';

/// Braid mode: weaving — three strands plait around the sphere.
OrbFrame frameBraid(double size, double t, ModeOpts o) {
  final cx = size / 2.0;
  final cy = size / 2.0;
  final R = (size / 2.0) * 0.76;
  final pt = makeProj(t * 0.4, 0.3, cx, cy, 1.0);
  final rs = radiusScale(size, o['rsPow'] ?? 0.6);

  final dots = <Dot>[];
  final ghostN = (o['ghostN'] ?? 150.0).toInt();

  for (int i = 0; i < ghostN; i++) {
    final d = fibDir(i, ghostN);
    final (px, py, z) = pt(d.$1 * R, d.$2 * R, d.$3 * R);
    final depth = (z / R + 1.0) / 2.0;
    dots.add(Dot(
      x: px,
      y: py,
      z: z,
      r: 0.8 * rs,
      white: 0.78,
      a: 0.1 + 0.22 * depth,
    ));
  }

  final strandN = (o['strandN'] ?? 52.0).toInt();
  final turns = o['turns'] ?? 3.0;

  for (int s = 0; s < 3; s++) {
    final phase = (s / 3.0) * 2.0 * math.pi;
    for (int i = 0; i < strandN; i++) {
      final u = (frac(i / strandN + t * 0.045) * 2.0 - 1.0) * 0.96;
      final surf = math.sqrt(math.max(0.0, 1.0 - u * u));
      final endFade = math.min(1.0, (1.0 - u.abs()) / 0.1);
      final a = u * math.pi * turns + phase;
      final weave =
          1.0 + 0.075 * math.sin(u * math.pi * turns * 2.0 + phase * 2.0 + t * 0.8);
      final rr = surf * R * weave;
      final (px, py, zr) = pt(math.cos(a) * rr, u * R * weave, math.sin(a) * rr);
      final depth = (zr / R + 1.0) / 2.0;

      dots.add(Dot(
        x: px,
        y: py,
        z: zr,
        r: ((o['rBase'] ?? 1.2) + (o['rDepth'] ?? 1.8) * depth) * rs,
        white: 0.55 - 0.45 * depth,
        a: endFade * (0.45 + 0.55 * depth),
      ));
    }
  }

  return finalizeFrame(dots, const [], o['rMin'] ?? 0.3);
}
