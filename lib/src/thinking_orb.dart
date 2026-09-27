import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'clock.dart';
import 'engine/core.dart';
import 'engine/registry.dart';
import 'presets.dart';
import 'types.dart';

/// Dotted thought-orb loading indicator widget for AI and agent UIs.
///
/// Features:
/// - 9 hand-tuned animated verb states ([OrbState.working], [OrbState.searching], etc.)
/// - 2 tuned size presets: 64px avatar scale and 20px inline text scale
/// - Live dark/light theme detection and monochrome depth ink
/// - Reduced-motion support (renders a static representative frame at `t = 0.6`)
/// - Shared clock synchronization keeping all on-screen orbs in exact phase
/// - Full accessibility Semantics support
class ThinkingOrb extends StatefulWidget {
  /// Creates a ThinkingOrb widget.
  const ThinkingOrb({
    super.key,
    this.state = OrbState.working,
    this.size = OrbSize.px64,
    this.theme = OrbTheme.auto,
    this.speed = 1.0,
    this.paused = false,
    this.label,
    this.color,
    this.customDimension,
    this.time,
  });

  /// Creates a small 20px ThinkingOrb (e.g. for inline text or badges).
  const ThinkingOrb.small({
    super.key,
    this.state = OrbState.working,
    this.theme = OrbTheme.auto,
    this.speed = 1.0,
    this.paused = false,
    this.label,
    this.color,
    this.time,
  })  : size = OrbSize.px20,
        customDimension = null;

  /// Creates a large 64px ThinkingOrb (e.g. for chat avatars or hero loading).
  const ThinkingOrb.large({
    super.key,
    this.state = OrbState.working,
    this.theme = OrbTheme.auto,
    this.speed = 1.0,
    this.paused = false,
    this.label,
    this.color,
    this.time,
  })  : size = OrbSize.px64,
        customDimension = null;

  /// Creates a ThinkingOrb with a custom pixel dimension.
  const ThinkingOrb.custom({
    super.key,
    required double dimension,
    this.state = OrbState.working,
    this.theme = OrbTheme.auto,
    this.speed = 1.0,
    this.paused = false,
    this.label,
    this.color,
    this.time,
  })  : size = dimension <= 20 ? OrbSize.px20 : OrbSize.px64,
        customDimension = dimension;

  /// Which animation verb to show.
  final OrbState state;

  /// The preset size category (64px or 20px).
  final OrbSize size;

  /// Optional custom dimension in logical pixels.
  final double? customDimension;

  /// Theme mode (auto detects dark/light from Flutter ThemeData).
  final OrbTheme theme;

  /// Multiplier on top of the preset's baked speed (defaults to 1.0).
  final double speed;

  /// Freeze animation on the current frame.
  final bool paused;

  /// Accessibility label override (defaults to [OrbState.label]).
  final String? label;

  /// Optional custom tint color. If omitted, standard monochrome ink is used.
  final Color? color;

  /// Explicit timestamp in seconds (overrides the global clock when provided).
  final double? time;

  @override
  State<ThinkingOrb> createState() => _ThinkingOrbState();
}

class _ThinkingOrbState extends State<ThinkingOrb>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _lastTime = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    if (!widget.paused && widget.time == null) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant ThinkingOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.paused != oldWidget.paused ||
        (widget.time != null) != (oldWidget.time != null)) {
      if (widget.paused || widget.time != null) {
        _ticker.stop();
      } else if (!_ticker.isActive) {
        _ticker.start();
      }
    }
  }

  void _onTick(Duration elapsed) {
    // Rebuild frame if time progressed
    final now = OrbClock.elapsedSeconds;
    if ((now - _lastTime).abs() >= 0.001) {
      _lastTime = now;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final isReducedMotion = mediaQuery?.disableAnimations ?? false;

    final isDark = switch (widget.theme) {
      OrbTheme.auto => Theme.of(context).brightness == Brightness.dark,
      OrbTheme.dark => true,
      OrbTheme.light => false,
    };

    final dimension = widget.customDimension ?? widget.size.dimension.toDouble();
    final sizePreset = widget.size.dimension;
    final resolved = resolvePreset(widget.state, sizePreset);

    final double effectiveTime;
    if (widget.time != null) {
      effectiveTime = widget.time! * resolved.speed * widget.speed;
    } else if (isReducedMotion) {
      // Reduced motion: static representative frame at t = 0.6
      effectiveTime = 0.6;
    } else {
      effectiveTime =
          OrbClock.elapsedSeconds * resolved.speed * widget.speed;
    }

    final modeFunction = kModeFrames[resolved.mode]!;
    final frame = modeFunction(dimension, effectiveTime, resolved.opts);

    final semanticLabel = widget.label ?? widget.state.label;

    return Semantics(
      label: semanticLabel,
      image: true,
      child: RepaintBoundary(
        child: SizedBox(
          width: dimension,
          height: dimension,
          child: CustomPaint(
            size: Size(dimension, dimension),
            painter: ThinkingOrbPainter(
              frame: frame,
              isDark: isDark,
              customColor: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for rendering an [OrbFrame] onto a Flutter [Canvas].
class ThinkingOrbPainter extends CustomPainter {
  ThinkingOrbPainter({
    required this.frame,
    required this.isDark,
    this.customColor,
  });

  final OrbFrame frame;
  final bool isDark;
  final Color? customColor;

  static final Paint _dotPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw lines first so node dots sit on top
    for (final line in frame.lines) {
      final alpha = line.alpha.clamp(0.0, 1.0);
      final w = line.white.clamp(0.0, 1.0);
      final gray = ((isDark ? 1.0 - w : w) * 255.0).round();

      if (customColor != null) {
        _linePaint.color = customColor!.withValues(alpha: alpha);
      } else {
        _linePaint.color = Color.fromRGBO(gray, gray, gray, alpha);
      }
      _linePaint.strokeWidth = line.w;

      canvas.drawLine(
        Offset(line.x1, line.y1),
        Offset(line.x2, line.y2),
        _linePaint,
      );
    }

    // 2. Draw dots (already sorted far-to-near by z-coordinate)
    for (final dot in frame.dots) {
      final alpha = dot.alpha.clamp(0.0, 1.0);
      final w = dot.white.clamp(0.0, 1.0);
      final gray = ((isDark ? 1.0 - w : w) * 255.0).round();

      if (customColor != null) {
        _dotPaint.color = customColor!.withValues(alpha: alpha);
      } else {
        _dotPaint.color = Color.fromRGBO(gray, gray, gray, alpha);
      }

      canvas.drawCircle(Offset(dot.x, dot.y), dot.r, _dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ThinkingOrbPainter oldDelegate) {
    return oldDelegate.frame != frame ||
        oldDelegate.isDark != isDark ||
        oldDelegate.customColor != customColor;
  }
}
