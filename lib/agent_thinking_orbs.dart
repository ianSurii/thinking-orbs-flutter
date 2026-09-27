/// Dotted thought-orb loading indicators for AI & agent UIs in Flutter.
///
/// Ported directly from the React/iOS `thinking-orbs` specification with 100%
/// geometry-exact parity, multi-theme auto-detection, and synchronized clocking.
library;

export 'src/clock.dart' show OrbClock;
export 'src/engine/engine.dart';
export 'src/presets.dart'
    show
        Preset,
        ResolvedPreset,
        kPresets,
        kStateToMode,
        resolvePreset;
export 'src/thinking_orb.dart' show ThinkingOrb, ThinkingOrbPainter;
export 'src/types.dart' show ModeKey, OrbSize, OrbState, OrbTheme;
