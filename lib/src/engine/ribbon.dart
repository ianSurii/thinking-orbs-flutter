import 'dart:math' as math;

import 'core.dart';
import 'profiles.dart';

/// Ribbon mode: composing (ribbon) and breathing (ring).
OrbFrame frameRibbon(double size, double t, ModeOpts o) {
  final cx = size / 2.0;
  final cy = size / 2.0;
  final R = (size / 2.0) * 0.78;
  final spin = o['spin'] ?? 1.0;
  const camTilt = 0.3;
  final pt = makeProj(t * 0.1 * spin, camTilt, cx, cy, 1.0);
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

  final isFaceOn = (o['faceOn'] ?? 0.0) != 0.0;
  final ya = t * 0.24 * spin;
  final ta = isFaceOn ? -camTilt : 0.55 + 0.3 * math.sin(t * 0.18) * spin;
  final ux = math.cos(ya);
  const uy = 0.0;
  final uz = math.sin(ya);
  final vx = -uz * math.sin(ta);
  final vy = math.cos(ta);
  final vz = ux * math.sin(ta);

  final nx = uy * vz - uz * vy;
  final ny = uz * vx - ux * vz;
  final nz = ux * vy - uy * vx;

  final wobAmp = 0.23 * (o['wobMul'] ?? 1.0);
  final baseR = isFaceOn ? R / (1.0 + 0.85 * wobAmp) : R;

  final baseLanes = (o['lanes'] ?? 5.0).toInt();
  final segs = (o['segs'] ?? 88.0).toInt();
  final lanes = math.max(1, (baseLanes * (o['bandMul'] ?? 1.0)).round());

  for (int w = 0; w < lanes; w++) {
    final laneOff = (w - (lanes - 1.0) / 2.0) * 0.075;
    final edge =
        (w - (lanes - 1.0) / 2.0).abs() / math.max(1.0, (lanes - 1.0) / 2.0);

    for (int k = 0; k < segs; k++) {
      final a = (k / segs.toDouble()) * 2.0 * math.pi;
      final wob = (0.16 * math.sin(a * 3.0 - t * 1.7 + w * 0.22) +
              0.07 * math.sin(a * 5.0 + t * 1.1)) *
          (o['wobMul'] ?? 1.0);
      final radial = isFaceOn ? 1.0 + wob : 1.0;
      final off = isFaceOn ? laneOff : laneOff + wob;

      final x = ux * math.cos(a) + vx * math.sin(a) + nx * off;
      final y = uy * math.cos(a) + vy * math.sin(a) + ny * off;
      final z = uz * math.cos(a) + vz * math.sin(a) + nz * off;
      final l = math.sqrt(x * x + y * y + z * z);
      final rr = baseR * radial;
      final (px, py, zr) = pt((x / l) * rr, (y / l) * rr, (z / l) * rr);
      final depth = (zr / R + 1.0) / 2.0;

      dots.add(Dot(
        x: px,
        y: py,
        z: zr,
        r: ((o['rBase'] ?? 1.1) + (o['rDepth'] ?? 1.7) * depth) *
            (1.0 - 0.25 * edge) *
            rs,
        white: 0.52 - 0.44 * depth + 0.18 * edge,
        a: 0.4 + 0.6 * depth,
      ));
    }
  }

  return finalizeFrame(dots, const [], o['rMin'] ?? 0.3);
}
