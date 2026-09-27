import 'dart:math' as math;

import 'core.dart';
import 'profiles.dart';

/// Web mode: connecting — a constellation wires itself with packets.
OrbFrame frameWeb(double size, double t, ModeOpts o) {
  final cx = size / 2.0;
  final cy = size / 2.0;
  final R = (size / 2.0) * 0.8 * (o['spread'] ?? 1.0);
  final pt = makeProj(t * 0.12, 0.32, cx, cy, R);
  final rs = radiusScale(size, o['rsPow'] ?? 0.6);

  final nodeN = (o['nodeN'] ?? 30.0).toInt();
  final thr = o['thr'] ?? 0.72;
  final nodeR = o['nodeR'] ?? 1.4;
  final nodeRDepth = o['nodeRDepth'] ?? 1.8;

  final nodes = <(double, double, double)>[];
  for (int i = 0; i < nodeN; i++) {
    final d = fibDir(i, nodeN);
    final x = d.$1 + 0.3 * (vnoise(i * 0.31 + 9.0, t * 0.24) - 0.5) * 2.0;
    final y = d.$2 + 0.3 * (vnoise(i * 0.53 + 27.0, t * 0.21) - 0.5) * 2.0;
    final z = d.$3 + 0.3 * (vnoise(i * 0.77 + 55.0, t * 0.27) - 0.5) * 2.0;
    final l = math.sqrt(x * x + y * y + z * z);
    nodes.add((x / l, y / l, z / l));
  }

  final lines = <Line>[];
  final dots = <Dot>[];

  // Edges between close neighbours
  for (int i = 0; i < nodeN; i++) {
    for (int j = i + 1; j < nodeN; j++) {
      final dx = nodes[i].$1 - nodes[j].$1;
      final dy = nodes[i].$2 - nodes[j].$2;
      final dz = nodes[i].$3 - nodes[j].$3;
      final dist = math.sqrt(dx * dx + dy * dy + dz * dz);
      if (dist >= thr) continue;

      final (x1, y1, z1) = pt(nodes[i].$1, nodes[i].$2, nodes[i].$3);
      final (x2, y2, z2) = pt(nodes[j].$1, nodes[j].$2, nodes[j].$3);
      final depth = ((z1 + z2) / 2.0 + 1.0) / 2.0;

      lines.add(Line(
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        white: 0.42,
        a: (1.0 - dist / thr) * (0.3 + 0.55 * depth),
        w: math.max(0.6, (o['lineW'] ?? 0.8) * rs),
      ));
    }
  }

  // Node dots
  for (int i = 0; i < nodeN; i++) {
    final (px, py, z) = pt(nodes[i].$1, nodes[i].$2, nodes[i].$3);
    final depth = (z + 1.0) / 2.0;
    final pulse = 1.0 + 0.25 * math.sin(t * 1.4 + i * 2.7);

    dots.add(Dot(
      x: px,
      y: py,
      z: z,
      r: (nodeR + nodeRDepth * depth) * pulse * rs,
      white: 0.55 - 0.45 * depth,
    ));
  }

  // Signal packets
  final signals = (o['signals'] ?? 5.0).toInt();
  for (int s = 0; s < signals; s++) {
    final seg = (t * 0.55 + s * 7.31).floor();
    final a = (hashD(seg.toDouble(), s * 3.1 + 1.7) * nodeN).floor();
    final b = (hashD(seg.toDouble(), s * 5.7 + 4.2) * nodeN).floor();
    if (a == b) continue;

    final f = frac(t * 0.55 + s * 7.31);
    final x = lerp(nodes[a].$1, nodes[b].$1, f);
    final y = lerp(nodes[a].$2, nodes[b].$2, f);
    final z = lerp(nodes[a].$3, nodes[b].$3, f);
    final l = math.max(1e-6, math.sqrt(x * x + y * y + z * z));
    final (px, py, zr) = pt(x / l, y / l, z / l);
    final depth = (zr + 1.0) / 2.0;

    dots.add(Dot(
      x: px,
      y: py,
      z: zr,
      r: (nodeR * 1.5 + nodeRDepth * depth) * rs,
      white: 0.05,
      a: 0.5 + 0.5 * depth,
    ));
  }

  return finalizeFrame(dots, lines, o['rMin'] ?? 0.3);
}
