import '../types.dart';
import 'braid.dart';
import 'core.dart';
import 'lattice.dart';
import 'morph.dart';
import 'orbits.dart';
import 'profiles.dart';
import 'ribbon.dart';
import 'web.dart';

/// Geometry function signature for a single instant.
typedef ModeFrameFunction = OrbFrame Function(
  double size,
  double t,
  ModeOpts opts,
);

/// Registry of mode frame generators.
final Map<ModeKey, ModeFrameFunction> kModeFrames = {
  ModeKey.orbits: frameOrbits,
  ModeKey.globe: frameGlobe,
  ModeKey.rubik: frameRubik,
  ModeKey.wave: frameWave,
  ModeKey.web: frameWeb,
  ModeKey.braid: frameBraid,
  ModeKey.ribbon: frameRibbon,
  // Ring shares ribbon's geometry — the faceOn profile flag switches it
  ModeKey.ring: frameRibbon,
  ModeKey.morph: frameMorph,
};
