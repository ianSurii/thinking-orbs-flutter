import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thinking_orbs/thinking_orbs.dart';

void main() {
  group('Math & Engine Primitives', () {
    test('lerp calculates linear interpolation correctly', () {
      expect(lerp(0.0, 10.0, 0.5), equals(5.0));
      expect(lerp(10.0, 20.0, 0.0), equals(10.0));
      expect(lerp(10.0, 20.0, 1.0), equals(20.0));
    });

    test('frac returns fractional part matching JS Math.floor', () {
      expect(frac(4.75), closeTo(0.75, 1e-9));
      expect(frac(5.0), closeTo(0.0, 1e-9));
      expect(frac(-0.25), closeTo(0.75, 1e-9));
    });

    test('hashD produces deterministic values in [0, 1)', () {
      final h1 = hashD(1.0, 2.0);
      final h2 = hashD(1.0, 2.0);
      final h3 = hashD(2.0, 1.0);

      expect(h1, equals(h2));
      expect(h1, isNot(equals(h3)));
      expect(h1, greaterThanOrEqualTo(0.0));
      expect(h1, lessThan(1.0));
    });

    test('vnoise produces continuous smooth values', () {
      final n1 = vnoise(0.5, 0.5);
      final n2 = vnoise(0.51, 0.5);
      expect((n1 - n2).abs(), lessThan(0.1));
    });

    test('fibDir generates unit vectors distributed on sphere', () {
      for (int i = 0; i < 10; i++) {
        final d = fibDir(i, 10);
        final len = math.sqrt(d.$1 * d.$1 + d.$2 * d.$2 + d.$3 * d.$3);
        expect(len, closeTo(1.0, 1e-6));
      }
    });

    test('angleDelta wraps shortest signed distance to (-pi, pi]', () {
      expect(angleDelta(0.0, 0.0), closeTo(0.0, 1e-9));
      expect(angleDelta(math.pi * 0.5, 0.0), closeTo(math.pi * 0.5, 1e-9));
      expect(angleDelta(math.pi * 1.5, 0.0), closeTo(-math.pi * 0.5, 1e-9));
    });

    test('radiusScale calculates (size / 300)^pow', () {
      expect(radiusScale(300.0, 0.6), closeTo(1.0, 1e-9));
      expect(radiusScale(64.0, 0.6), closeTo(math.pow(64.0 / 300.0, 0.6), 1e-9));
    });

    test('finalizeFrame culls alpha < 0.02 and sorts by z ascending', () {
      final dots = [
        Dot(x: 10, y: 10, z: 5, r: 0.1, white: 0.5, a: 1.0),
        Dot(x: 10, y: 10, z: -2, r: 0.1, white: 0.5, a: 1.0),
        Dot(x: 10, y: 10, z: 1, r: 0.1, white: 0.5, a: 0.01), // culled
      ];
      final lines = [
        Line(x1: 0, y1: 0, x2: 1, y2: 1, white: 0.5, a: 1.0, w: 1),
        Line(x1: 0, y1: 0, x2: 1, y2: 1, white: 0.5, a: 0.01, w: 1), // culled
      ];

      final frame = finalizeFrame(dots, lines, 0.3);
      expect(frame.dots.length, equals(2));
      expect(frame.dots[0].z, equals(-2));
      expect(frame.dots[1].z, equals(5));
      expect(frame.dots[0].r, equals(0.3)); // clamped to rMin
      expect(frame.lines.length, equals(1));
    });
  });

  group('Presets & Scaling', () {
    test('All 9 states resolve correctly', () {
      for (final state in OrbState.values) {
        final res64 = resolvePreset(state, 64);
        final res20 = resolvePreset(state, 20);

        expect(res64.mode, equals(kStateToMode[state]));
        expect(res20.mode, equals(kStateToMode[state]));
        expect(res64.speed, greaterThan(0.0));
        expect(res20.speed, greaterThan(0.0));
      }
    });

    test('OrbState has proper labels and strings', () {
      expect(OrbState.working.label, equals('Working…'));
      expect(OrbState.searching.label, equals('Searching…'));
      expect(OrbState.solving.label, equals('Solving…'));
      expect(OrbState.listening.label, equals('Listening…'));
      expect(OrbState.connecting.label, equals('Connecting…'));
      expect(OrbState.weaving.label, equals('Weaving…'));
      expect(OrbState.composing.label, equals('Composing…'));
      expect(OrbState.breathing.label, equals('Thinking…'));
      expect(OrbState.shaping.label, equals('Shaping…'));

      expect(OrbState.fromString('working'), equals(OrbState.working));
    });

    test('OrbSize dimensions', () {
      expect(OrbSize.px64.dimension, equals(64));
      expect(OrbSize.px20.dimension, equals(20));
      expect(OrbSize.large, equals(OrbSize.px64));
      expect(OrbSize.small, equals(OrbSize.px20));
      expect(OrbSize.fromInt(20), equals(OrbSize.px20));
      expect(OrbSize.fromInt(64), equals(OrbSize.px64));
    });
  });

  group('ThinkingOrb Widget Tests', () {
    testWidgets('Renders all 9 states without crashing',
        (WidgetTester tester) async {
      for (final state in OrbState.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: ThinkingOrb(
                  state: state,
                  time: 0.6,
                ),
              ),
            ),
          ),
        );
        expect(find.byType(ThinkingOrb), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
      }
    });

    testWidgets('Renders with large and small constructors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ThinkingOrb.large(state: OrbState.searching, time: 0.6),
                ThinkingOrb.small(state: OrbState.listening, time: 0.6),
                ThinkingOrb.custom(
                  dimension: 48,
                  state: OrbState.solving,
                  time: 0.6,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ThinkingOrb), findsNWidgets(3));
      final sizes = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where((s) => s.width != null)
          .toList();

      expect(sizes.any((s) => s.width == 64.0), isTrue);
      expect(sizes.any((s) => s.width == 20.0), isTrue);
      expect(sizes.any((s) => s.width == 48.0), isTrue);
    });

    testWidgets('Respects custom Semantics accessibility label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThinkingOrb(
              state: OrbState.solving,
              label: 'Analyzing repository code…',
              time: 0.6,
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Analyzing repository code…'),
        findsOneWidget,
      );
    });

    testWidgets('Respects dark, light, and auto themes',
        (WidgetTester tester) async {
      // Dark theme explicit
      await tester.pumpWidget(
        const MaterialApp(
          themeMode: ThemeMode.light,
          home: Scaffold(
            body: ThinkingOrb(
              theme: OrbTheme.dark,
              time: 0.6,
            ),
          ),
        ),
      );
      expect(find.byType(ThinkingOrb), findsOneWidget);

      // Light theme explicit
      await tester.pumpWidget(
        const MaterialApp(
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: ThinkingOrb(
              theme: OrbTheme.light,
              time: 0.6,
            ),
          ),
        ),
      );
      expect(find.byType(ThinkingOrb), findsOneWidget);

      // Auto theme following ThemeData
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: ThinkingOrb(
              theme: OrbTheme.auto,
              time: 0.6,
            ),
          ),
        ),
      );
      expect(find.byType(ThinkingOrb), findsOneWidget);
    });

    testWidgets('Respects custom tint color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThinkingOrb(
              color: Colors.blueAccent,
              time: 0.6,
            ),
          ),
        ),
      );
      expect(find.byType(ThinkingOrb), findsOneWidget);
    });

    testWidgets('Respects paused property and updates properly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThinkingOrb(
              paused: true,
            ),
          ),
        ),
      );
      expect(find.byType(ThinkingOrb), findsOneWidget);

      // Switch to unpaused
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThinkingOrb(
              paused: false,
            ),
          ),
        ),
      );
      expect(find.byType(ThinkingOrb), findsOneWidget);
    });

    testWidgets('Respects reduced motion by rendering static frame',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: ThinkingOrb(
                state: OrbState.connecting,
              ),
            ),
          ),
        ),
      );
      expect(find.byType(ThinkingOrb), findsOneWidget);
    });
  });

  group('Clock Management', () {
    test('OrbClock freeze and unfreeze', () {
      OrbClock.freeze(1.5);
      expect(OrbClock.elapsedSeconds, equals(1.5));

      OrbClock.unfreeze();
      expect(OrbClock.elapsedSeconds, greaterThanOrEqualTo(0.0));

      OrbClock.reset();
      expect(OrbClock.elapsedSeconds, greaterThanOrEqualTo(0.0));
    });
  });
}
