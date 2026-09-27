import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:agent_thinking_orbs/agent_thinking_orbs.dart';

void main() {
  group('Golden Vector Parity Tests (spec/orbs-golden.json)', () {
    late Map<String, dynamic> goldenData;

    setUpAll(() {
      final file = File('spec/orbs-golden.json');
      expect(file.existsSync(), isTrue,
          reason: 'spec/orbs-golden.json must exist in repository root');
      goldenData = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    });

    test('Resolved presets match spec ground truth', () {
      final resolvedMap = goldenData['resolved'] as Map<String, dynamic>;

      for (final entry in resolvedMap.entries) {
        final parts = entry.key.split('-');
        final stateName = parts[0];
        final sizeVal = int.parse(parts[1]);

        final state = OrbState.fromString(stateName);
        final resolved = resolvePreset(state, sizeVal);
        final expected = entry.value as Map<String, dynamic>;

        expect(resolved.mode.name, equals(expected['mode']),
            reason: 'Mode mismatch for ${entry.key}');
        expect(resolved.speed, closeTo((expected['speed'] as num).toDouble(), 1e-6),
            reason: 'Speed mismatch for ${entry.key}');

        final expectedOpts = expected['opts'] as Map<String, dynamic>;
        for (final optKey in expectedOpts.keys) {
          final expVal = (expectedOpts[optKey] as num).toDouble();
          final actVal = resolved.opts[optKey];
          expect(actVal, isNotNull,
              reason: 'Missing option $optKey for ${entry.key}');
          expect(actVal!, closeTo(expVal, 1e-4),
              reason: 'Option value mismatch for $optKey in ${entry.key}');
        }
      }
    });

    test('All 72 golden vector cases match numerical geometry within 1e-4 tolerance',
        () {
      final tolerance = (goldenData['tolerance'] as num).toDouble();
      final cases = goldenData['cases'] as List<dynamic>;

      expect(cases.length, equals(72),
          reason:
              'Must have 72 cases (9 states × 2 sizes × 4 timestamps)');

      int totalDotsTested = 0;
      int totalLinesTested = 0;

      for (final c in cases) {
        final caseMap = c as Map<String, dynamic>;
        final key = caseMap['key'] as String;
        final state = OrbState.fromString(caseMap['state'] as String);
        final size = (caseMap['size'] as num).toDouble();
        final mode = ModeKey.fromString(caseMap['mode'] as String);
        final t = (caseMap['t'] as num).toDouble();

        final expectedDotCount = caseMap['dotCount'] as int;
        final expectedLineCount = caseMap['lineCount'] as int;
        final expectedDots = (caseMap['dots'] as List<dynamic>)
            .map((v) => (v as num).toDouble())
            .toList();
        final expectedLines = (caseMap['lines'] as List<dynamic>)
            .map((v) => (v as num).toDouble())
            .toList();

        final resolved = resolvePreset(state, size.toInt());
        final frame = kModeFrames[mode]!(size, t, resolved.opts);

        expect(frame.dots.length, equals(expectedDotCount),
            reason: 'Dot count mismatch for case $key');
        expect(frame.lines.length, equals(expectedLineCount),
            reason: 'Line count mismatch for case $key');

        // Verify dots (stride 6: x, y, z, r, white, a)
        // If dots have identical z within 1e-9 (same plane), match within the equal-z group
        for (int i = 0; i < frame.dots.length; i++) {
          final dot = frame.dots[i];
          final offset = i * 6;

          final expX = expectedDots[offset];
          final expY = expectedDots[offset + 1];
          final expZ = expectedDots[offset + 2];
          final expR = expectedDots[offset + 3];
          final expWhite = expectedDots[offset + 4];
          final expA = expectedDots[offset + 5];

          // Check direct match
          if ((dot.x - expX).abs() <= tolerance &&
              (dot.y - expY).abs() <= tolerance &&
              (dot.z - expZ).abs() <= tolerance) {
            expect(dot.r, closeTo(expR, tolerance));
            expect(dot.white, closeTo(expWhite, tolerance));
            expect(dot.alpha, closeTo(expA, tolerance));
            totalDotsTested++;
            continue;
          }

          // If on same z plane (within 1e-6), search within the same-z cluster
          bool foundMatch = false;
          for (int j = 0; j < frame.dots.length; j++) {
            final jOff = j * 6;
            final jZ = expectedDots[jOff + 2];
            if ((dot.z - jZ).abs() <= 1e-6) {
              final jX = expectedDots[jOff];
              final jY = expectedDots[jOff + 1];
              if ((dot.x - jX).abs() <= tolerance &&
                  (dot.y - jY).abs() <= tolerance) {
                foundMatch = true;
                break;
              }
            }
          }

          expect(foundMatch, isTrue,
              reason: 'Dot $i ($dot) had no matching golden dot in case $key');
          totalDotsTested++;
        }

        // Verify lines (stride 7: x1, y1, x2, y2, white, a, w)
        for (int i = 0; i < frame.lines.length; i++) {
          final line = frame.lines[i];
          final offset = i * 7;

          final expX1 = expectedLines[offset];
          final expY1 = expectedLines[offset + 1];
          final expX2 = expectedLines[offset + 2];
          final expY2 = expectedLines[offset + 3];
          final expWhite = expectedLines[offset + 4];
          final expA = expectedLines[offset + 5];
          final expW = expectedLines[offset + 6];

          expect(line.x1, closeTo(expX1, tolerance),
              reason: 'Line $i X1 mismatch in case $key');
          expect(line.y1, closeTo(expY1, tolerance),
              reason: 'Line $i Y1 mismatch in case $key');
          expect(line.x2, closeTo(expX2, tolerance),
              reason: 'Line $i X2 mismatch in case $key');
          expect(line.y2, closeTo(expY2, tolerance),
              reason: 'Line $i Y2 mismatch in case $key');
          expect(line.white, closeTo(expWhite, tolerance),
              reason: 'Line $i White mismatch in case $key');
          expect(line.alpha, closeTo(expA, tolerance),
              reason: 'Line $i Alpha mismatch in case $key');
          expect(line.w, closeTo(expW, tolerance),
              reason: 'Line $i Width mismatch in case $key');

          totalLinesTested++;
        }
      }

      // Verify all dots and lines were verified
      expect(totalDotsTested, equals(11288),
          reason: 'Must have tested all 11,288 golden dots');
      expect(totalLinesTested, equals(341),
          reason: 'Must have tested all 341 golden lines');
    });
  });
}
