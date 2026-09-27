import 'engine/profiles.dart';
import 'types.dart';

/// Shipped preset values for a given mode and size.
class Preset {
  const Preset({
    required this.speed,
    required this.count,
    required this.size,
    this.extra,
  });

  final double speed;
  final double count;
  final double size;
  final ModeOpts? extra;
}

/// Resolved preset with effective mode, base speed, and fully scaled options.
class ResolvedPreset {
  const ResolvedPreset({
    required this.mode,
    required this.speed,
    required this.opts,
  });

  final ModeKey mode;
  final double speed;
  final ModeOpts opts;
}

/// Mapping from [OrbState] to internal [ModeKey].
const Map<OrbState, ModeKey> kStateToMode = {
  OrbState.working: ModeKey.orbits,
  OrbState.searching: ModeKey.globe,
  OrbState.solving: ModeKey.rubik,
  OrbState.listening: ModeKey.wave,
  OrbState.connecting: ModeKey.web,
  OrbState.weaving: ModeKey.braid,
  OrbState.composing: ModeKey.ribbon,
  OrbState.breathing: ModeKey.ring,
  OrbState.shaping: ModeKey.morph,
};

/// Shipped presets for all modes at both 64px and 20px sizes.
final Map<ModeKey, Map<int, Preset>> kPresets = {
  ModeKey.orbits: {
    64: const Preset(speed: 1.885, count: 1.0, size: 1.0),
    20: const Preset(speed: 3.9, count: 0.238, size: 2.4),
  },
  ModeKey.globe: {
    64: const Preset(
      speed: 2.015,
      count: 0.42,
      size: 1.15,
      extra: {'scanMul': 4.08, 'dimBase': 0.45},
    ),
    20: const Preset(
      speed: 2.665,
      count: 0.105,
      size: 1.75,
      extra: {'scanMul': 4.335, 'dimBase': 0.45},
    ),
  },
  ModeKey.rubik: {
    64: const Preset(speed: 1.82, count: 0.35, size: 1.05),
    20: const Preset(speed: 1.95, count: 0.088, size: 1.9),
  },
  ModeKey.wave: {
    64: const Preset(speed: 4.388, count: 0.341, size: 1.0),
    20: const Preset(speed: 3.998, count: 0.105, size: 1.6),
  },
  ModeKey.web: {
    64: const Preset(speed: 3.315, count: 1.35, size: 0.95),
    20: const Preset(speed: 6.63, count: 0.25, size: 1.52),
  },
  ModeKey.braid: {
    64: const Preset(speed: 1.625, count: 0.5, size: 1.0),
    20: const Preset(speed: 2.75, count: 0.1125, size: 1.36),
  },
  ModeKey.ribbon: {
    64: const Preset(
      speed: 2.34,
      count: 0.25,
      size: 0.85,
      extra: {'spin': 0.0, 'bandMul': 3.9, 'wobMul': 1.0},
    ),
    20: const Preset(
      speed: 3.12,
      count: 0.051,
      size: 1.073,
      extra: {'spin': 0.0, 'bandMul': 4.94, 'wobMul': 1.0},
    ),
  },
  ModeKey.ring: {
    64: const Preset(
      speed: 3.24,
      count: 0.25,
      size: 0.956,
      extra: {'spin': 0.0, 'bandMul': 3.627, 'wobMul': 0.368},
    ),
    20: const Preset(
      speed: 3.78,
      count: 0.028,
      size: 1.622,
      extra: {'spin': 0.0, 'bandMul': 3.968, 'wobMul': 0.565},
    ),
  },
  ModeKey.morph: {
    64: const Preset(
      speed: 2.405,
      count: 0.702,
      size: 0.395,
      extra: {'spread': 1.45},
    ),
    20: const Preset(
      speed: 2.08,
      count: 0.53,
      size: 1.011,
      extra: {'spread': 1.45},
    ),
  },
};

final Map<String, ResolvedPreset> _cache = {};

/// Resolves an [OrbState] and dimension (e.g. 64 or 20) into its [ResolvedPreset].
ResolvedPreset resolvePreset(OrbState state, int sizeDimension) {
  final normSize = sizeDimension <= 20 ? 20 : 64;
  final key = '${state.name}-$normSize';
  final hit = _cache[key];
  if (hit != null) return hit;

  final mode = kStateToMode[state]!;
  final preset = kPresets[mode]![normSize]!;
  var opts = Map<String, double>.from(kBaseProfiles[mode.name]!);
  if (preset.count != 1.0) {
    opts = scaleCounts(opts, preset.count);
  }
  if (preset.size != 1.0) {
    opts = scaleRadii(opts, preset.size);
  }
  if (preset.extra != null) {
    opts.addAll(preset.extra!);
  }

  final resolved = ResolvedPreset(
    mode: mode,
    speed: preset.speed,
    opts: opts,
  );
  _cache[key] = resolved;
  return resolved;
}
