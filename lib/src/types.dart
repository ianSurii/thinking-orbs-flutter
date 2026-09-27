/// Shipped states, sizes, and theme modes for Thinking Orbs.
library;

/// The nine shipped states — each a hand-tuned animation:
/// - [working]    — particles on tilted orbits
/// - [searching]  — a scan meridian sweeps a dotted globe
/// - [solving]    — bands scramble in quarter turns, then click back
/// - [listening]  — a waveform rolls through latitude rings
/// - [connecting] — a constellation wires itself, packets running the edges
/// - [weaving]    — three strands plait around the sphere
/// - [composing]  — an undulating multi-band sash
/// - [breathing]  — a face-on ring slowly morphing
/// - [shaping]    — a dotted outline morphs circle → triangle → square
enum OrbState {
  working('working', 'Working…'),
  searching('searching', 'Searching…'),
  solving('solving', 'Solving…'),
  listening('listening', 'Listening…'),
  connecting('connecting', 'Connecting…'),
  weaving('weaving', 'Weaving…'),
  composing('composing', 'Composing…'),
  breathing('breathing', 'Thinking…'),
  shaping('shaping', 'Shaping…');

  const OrbState(this.name, this.label);

  /// The string identifier matching the spec.
  final String name;

  /// Default accessibility label.
  final String label;

  /// Parse from string name.
  static OrbState fromString(String name) {
    return OrbState.values.firstWhere(
      (s) => s.name == name,
      orElse: () => throw ArgumentError('Unknown OrbState: $name'),
    );
  }
}

/// Rendered size preset.
///
/// Exactly two tuned presets ship:
/// [px64] (chat-avatar scale) and [px20] (inline-text scale).
/// Each size carries its own dot count, dot size, and speed tuning.
enum OrbSize {
  /// 64 logical px (chat avatar / primary loading scale).
  px64(64),

  /// 20 logical px (inline text / badge scale).
  px20(20);

  const OrbSize(this.dimension);

  /// Pixel dimension (both width and height).
  final int dimension;

  /// Alias for 64px.
  static const OrbSize large = OrbSize.px64;

  /// Alias for 20px.
  static const OrbSize small = OrbSize.px20;

  /// Resolve from int value (64 or 20).
  static OrbSize fromInt(int value) {
    if (value <= 20) return OrbSize.px20;
    return OrbSize.px64;
  }
}

/// Theme mode.
///
/// - [auto] (default) automatically detects brightness from [Theme.of(context).brightness].
/// - [dark] pins light ink for dark backgrounds.
/// - [light] pins dark ink for light backgrounds.
enum OrbTheme {
  /// Automatically resolves based on current Flutter ThemeData brightness.
  auto,

  /// Inverted ink: light dots for dark backgrounds.
  dark,

  /// Standard ink: dark dots for light backgrounds.
  light;
}

/// The 9 underlying geometry modes.
enum ModeKey {
  orbits('orbits'),
  globe('globe'),
  rubik('rubik'),
  wave('wave'),
  web('web'),
  braid('braid'),
  ribbon('ribbon'),
  ring('ring'),
  morph('morph');

  const ModeKey(this.name);
  final String name;

  static ModeKey fromString(String name) {
    return ModeKey.values.firstWhere(
      (m) => m.name == name,
      orElse: () => throw ArgumentError('Unknown ModeKey: $name'),
    );
  }
}
