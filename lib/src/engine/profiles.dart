import 'dart:math' as math;

/// Mode options map.
typedef ModeOpts = Map<String, double>;

/// Count pairs that scale with sqrt(scale) on each axis so total count scales by scale.
const List<(String, String)> kCountPairs = [
  ('latRings', 'lonDensity'),
  ('rings', 'lonDensity'),
  ('lanes', 'segs'),
];

/// Flat list count keys that scale linearly.
const List<String> kCountKeys = [
  'orbitN',
  'ghostN',
  'nodeN',
  'strandN',
  'signals',
];

/// Icon density keys for morph outlines.
const List<String> kIconDensityKeys = ['iconD'];

/// Radius keys to scale together.
const List<String> kRadiusKeys = [
  'rBase',
  'rDepth',
  'rActive',
  'rDot',
  'ghostR',
  'partR',
  'partRDepth',
  'nodeR',
  'nodeRDepth',
];

/// Scales count parameters in [opts] according to the spec scaling rules.
ModeOpts scaleCounts(ModeOpts opts, double scale) {
  final out = Map<String, double>.from(opts);
  final done = <String>{};
  final rt = math.sqrt(scale);

  for (final (a, b) in kCountPairs) {
    final va = out[a];
    final vb = out[b];
    if (va != null && vb != null && !done.contains(a) && !done.contains(b)) {
      out[a] = math.max(2.0, (va * rt).roundToDouble());
      out[b] = math.max(2.0, (vb * rt).roundToDouble());
      done.add(a);
      done.add(b);
    }
  }

  for (final k in kCountKeys) {
    final v = out[k];
    // 0 means the mode opted out of that layer entirely (e.g. ring has no ghost sphere)
    if (v != null && v != 0.0 && !done.contains(k)) {
      out[k] = math.max(1.0, (v * scale).roundToDouble());
    }
  }

  for (final k in kIconDensityKeys) {
    final v = out[k];
    if (v != null) {
      out[k] = math.max(0.02, v * scale);
    }
  }

  return out;
}

/// Scales all radius parameters in [opts] by [scale].
ModeOpts scaleRadii(ModeOpts opts, double scale) {
  final out = Map<String, double>.from(opts);
  for (final k in kRadiusKeys) {
    final v = out[k];
    if (v != null) {
      out[k] = v * scale;
    }
  }
  out['rSizeMul'] = (out['rSizeMul'] ?? 1.0) * scale;
  return out;
}

/// Base (fine) profiles per mode, before preset multipliers.
final Map<String, ModeOpts> kBaseProfiles = {
  'globe': {
    'latRings': 17.0,
    'lonDensity': 44.0,
    'rBase': 0.6,
    'rDepth': 1.7,
    'rBoost': 1.0,
    'inkFar': 0.62,
    'inkSpan': 0.54,
    'rsPow': 0.6,
    'rMin': 0.3,
  },
  'orbits': {
    'orbitN': 12.0,
    'ghostN': 40.0,
    'ghostR': 0.9,
    'ghostA': 0.5,
    'particles': 3.0,
    'partR': 1.2,
    'partRDepth': 1.6,
    'rsPow': 0.6,
    'rMin': 0.3,
  },
  'rubik': {
    'latRings': 15.0,
    'lonDensity': 40.0,
    'moveCount': 14.0,
    'rBase': 0.6,
    'rDepth': 1.7,
    'rActive': 0.3,
    'inkFar': 0.62,
    'inkSpan': 0.54,
    'rsPow': 0.6,
    'rMin': 0.3,
  },
  'wave': {
    'rings': 15.0,
    'lonDensity': 40.0,
    'rBase': 0.6,
    'rDepth': 1.7,
    'rsPow': 0.6,
    'rMin': 0.3,
  },
  'web': {
    'nodeN': 30.0,
    'thr': 0.72,
    'signals': 5.0,
    'nodeR': 1.4,
    'nodeRDepth': 1.8,
    'lineW': 0.8,
    'rsPow': 0.6,
    'rMin': 0.3,
  },
  'braid': {
    'strandN': 52.0,
    'turns': 3.0,
    'ghostN': 150.0,
    'rBase': 1.2,
    'rDepth': 1.8,
    'rsPow': 0.6,
    'rMin': 0.3,
  },
  'ribbon': {
    'lanes': 5.0,
    'segs': 88.0,
    'ghostN': 150.0,
    'rBase': 1.1,
    'rDepth': 1.7,
    'rsPow': 0.6,
    'rMin': 0.3,
  },
  'ring': {
    'lanes': 5.0,
    'segs': 88.0,
    'ghostN': 0.0,
    'faceOn': 1.0,
    'rBase': 1.1,
    'rDepth': 1.7,
    'rsPow': 0.6,
    'rMin': 0.3,
  },
  'morph': {
    'rDot': 0.021,
    'iconD': 1.0,
    'rMin': 0.25,
  },
};
