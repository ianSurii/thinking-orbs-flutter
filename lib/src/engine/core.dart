import 'dart:math' as math;

/// A rendered dot primitive in 3D space with projection coordinates and ink properties.
class Dot {
  Dot({
    required this.x,
    required this.y,
    required this.z,
    required this.r,
    required this.white,
    this.a = 1.0,
  });

  /// Projected 2D x coordinate in logical pixels.
  final double x;

  /// Projected 2D y coordinate in logical pixels.
  final double y;

  /// Depth z coordinate for depth-sorting and shading.
  final double z;

  /// Rendered radius in logical pixels.
  double r;

  /// Ink value: 0.0 = darkest ink, 1.0 = lightest ink.
  /// On dark themes, this value is inverted (1.0 - white) so near dots read bright.
  final double white;

  /// Opacity multiplier in range [0.0, 1.0].
  final double? a;

  /// Resolved alpha value (defaults to 1.0 if null).
  double get alpha => a ?? 1.0;

  Dot copyWith({
    double? x,
    double? y,
    double? z,
    double? r,
    double? white,
    double? a,
  }) {
    return Dot(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      r: r ?? this.r,
      white: white ?? this.white,
      a: a ?? this.a,
    );
  }

  @override
  String toString() => 'Dot(x: $x, y: $y, z: $z, r: $r, white: $white, a: $a)';
}

/// A stroked line edge between two projected points (e.g. for `connecting` mode).
class Line {
  const Line({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.white,
    this.a = 1.0,
    required this.w,
  });

  final double x1;
  final double y1;
  final double x2;
  final double y2;

  /// Ink value: 0.0 = darkest ink, 1.0 = lightest ink.
  final double white;

  /// Opacity multiplier in range [0.0, 1.0].
  final double? a;

  /// Stroke width in logical pixels.
  final double w;

  /// Resolved alpha value (defaults to 1.0 if null).
  double get alpha => a ?? 1.0;

  @override
  String toString() =>
      'Line(x1: $x1, y1: $y1, x2: $x2, y2: $y2, white: $white, a: $a, w: $w)';
}

/// One rendered instant: a complete, final set of draw instructions.
/// [dots] is already z-sorted into draw order and radius-clamped; [lines] are drawn first.
class OrbFrame {
  const OrbFrame({required this.dots, required this.lines});

  final List<Dot> dots;
  final List<Line> lines;
}

/// A 3D projection function mapping (x, y, z) to 2D screen (px, py, depth z).
typedef Projector =
    (double, double, double) Function(double x, double y, double z);

/// Linear interpolation between [a] and [b] by factor [f].
double lerp(double a, double b, double f) {
  return a + (b - a) * f;
}

/// Fractional part of [x], matching `x - Math.floor(x)` in JavaScript.
double frac(double x) {
  return x - x.floorToDouble();
}

/// Value noise on a 2D lattice — smooth, deterministic, cheap.
double vnoise(double x, double y) {
  final xi = x.floorToDouble();
  final yi = y.floorToDouble();
  var fx = x - xi;
  var fy = y - yi;
  fx = fx * fx * (3.0 - 2.0 * fx);
  fy = fy * fy * (3.0 - 2.0 * fy);
  final a = hashD(xi, yi);
  final b = hashD(xi + 1.0, yi);
  final c = hashD(xi, yi + 1.0);
  final d = hashD(xi + 1.0, yi + 1.0);
  return a + (b - a) * fx + (c - a) * fy + (a - b - c + d) * fx * fy;
}

/// Deterministic hash in [0, 1).
double hashD(double a, double b) {
  final h = math.sin(a * 12.9898 + b * 78.233) * 43758.5453;
  return h - h.floorToDouble();
}

/// Stable directions on a unit sphere (Fibonacci lattice).
(double, double, double) fibDir(int i, int n) {
  final golden = math.pi * (3.0 - math.sqrt(5.0));
  final y = 1.0 - (2.0 * (i + 0.5)) / n;
  final rad = math.sqrt(math.max(0.0, 1.0 - y * y));
  final a = i * golden;
  return (rad * math.cos(a), y, rad * math.sin(a));
}

/// Shortest signed angular distance, wrapped to (-π, π].
double angleDelta(double a, double b) {
  return math.atan2(math.sin(a - b), math.cos(a - b));
}

/// Shared spin + tilt + orthographic projection.
Projector makeProj(
  double yaw,
  double tilt,
  double cx,
  double cy,
  double scale,
) {
  final st = math.sin(tilt);
  final ct = math.cos(tilt);
  final sy = math.sin(yaw);
  final cyw = math.cos(yaw);
  return (double x, double y, double z) {
    final x1 = x * cyw + z * sy;
    final z1 = -x * sy + z * cyw;
    final y1 = y * ct - z1 * st;
    final z2 = y * st + z1 * ct;
    return (cx + x1 * scale, cy - y1 * scale, z2);
  };
}

/// Turn raw mode output into a finished frame: drop invisible marks, clamp
/// radii to the mode's floor, and stably z-sort far→near into draw order.
OrbFrame finalizeFrame(List<Dot> dots, List<Line> lines, [double rMin = 0.3]) {
  final visible = <(int, Dot)>[];
  int index = 0;
  for (final d in dots) {
    if ((d.a ?? 1.0) < 0.02) continue;
    d.r = math.max(rMin, d.r);
    visible.add((index++, d));
  }
  // Stable ascending sort by z (far to near), preserving insertion order on equal z
  visible.sort((a, b) {
    final cmp = a.$2.z.compareTo(b.$2.z);
    if (cmp != 0) return cmp;
    return a.$1.compareTo(b.$1);
  });
  return OrbFrame(
    dots: visible.map((e) => e.$2).toList(),
    lines: lines.where((l) => (l.a ?? 1.0) >= 0.02).toList(),
  );
}

/// Sub-linear radius scaling: keeps small spinners legible.
double radiusScale(double size, double pow) {
  return math.pow(size / 300.0, pow).toDouble();
}
