import 'dart:math' as math;

import 'core.dart';
import 'profiles.dart';

/// Orbits mode: working — particles on tilted orbits.
OrbFrame frameOrbits(double size, double t, ModeOpts o) {
  final cx = size / 2.0;
  final cy = size / 2.0;
  final R = (size / 2.0) * 0.82;
  final pt = makeProj(t * 0.12, 0.3, cx, cy, 1.0);
  final rs = radiusScale(size, o['rsPow'] ?? 0.6);

  final dots = <Dot>[];
  final orbitN = (o['orbitN'] ?? 12.0).toInt();
  final ghostN = (o['ghostN'] ?? 40.0).toInt();
  final particles = (o['particles'] ?? 3.0).toInt();

  for (int orb = 0; orb < orbitN; orb++) {
    final h1 = hashD(orb.toDouble(), 1.7);
    final h2 = hashD(orb.toDouble(), 5.2);
    final h3 = hashD(orb.toDouble(), 8.9);
    final ro = R * (0.45 + 0.52 * h1);
    final th = h1 * 2.0 * math.pi;
    final phi = math.acos(2.0 * h2 - 1.0);

    // Orbit plane basis (u, v perpendicular to normal n)
    final nx = math.sin(phi) * math.cos(th);
    final ny = math.cos(phi);
    final nz = math.sin(phi) * math.sin(th);

    var ux = -ny;
    var uy = nx;
    const uz = 0.0;
    final ul = math.max(1e-6, math.sqrt(ux * ux + uy * uy));
    ux /= ul;
    uy /= ul;

    final vx = ny * uz - nz * uy;
    final vy = nz * ux - nx * uz;
    final vz = nx * uy - ny * ux;
    final speed = (0.25 + 0.55 * h3) * (h3 > 0.5 ? 1.0 : -1.0);

    // Ghost path
    for (int k = 0; k < ghostN; k++) {
      final a = (k / ghostN.toDouble()) * 2.0 * math.pi;
      final (px, py, z) = pt(
        (ux * math.cos(a) + vx * math.sin(a)) * ro,
        (uy * math.cos(a) + vy * math.sin(a)) * ro,
        (uz * math.cos(a) + vz * math.sin(a)) * ro,
      );
      final depth = (z / ro + 1.0) / 2.0;

      dots.add(Dot(
        x: px,
        y: py,
        z: z,
        r: (o['ghostR'] ?? 0.9) * rs,
        white: 0.72,
        a: (o['ghostA'] ?? 0.5) * (0.4 + 0.6 * depth),
      ));
    }

    // Active particles
    for (int m = 0; m < particles; m++) {
      final a = t * speed + (m / particles.toDouble()) * 2.0 * math.pi + h2 * 6.0;
      final (px, py, z) = pt(
        (ux * math.cos(a) + vx * math.sin(a)) * ro,
        (uy * math.cos(a) + vy * math.sin(a)) * ro,
        (uz * math.cos(a) + vz * math.sin(a)) * ro,
      );
      final depth = (z / ro + 1.0) / 2.0;

      dots.add(Dot(
        x: px,
        y: py,
        z: z,
        r: ((o['partR'] ?? 1.2) + (o['partRDepth'] ?? 1.6) * depth) * rs,
        white: 0.3 - 0.22 * depth,
      ));
    }
  }

  return finalizeFrame(dots, const [], o['rMin'] ?? 0.3);
}
