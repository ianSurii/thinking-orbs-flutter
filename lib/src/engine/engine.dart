/// Pure Dart thinking-orbs geometry engine: zero Flutter UI dependencies.
///
/// Use this library to calculate raw dot and line geometries for custom renderers,
/// background isolates, server-side rasterization, or unit tests.
library;

export '../presets.dart'
    show
        Preset,
        ResolvedPreset,
        kPresets,
        kStateToMode,
        resolvePreset;
export '../types.dart' show ModeKey, OrbSize, OrbState, OrbTheme;
export 'braid.dart' show frameBraid;
export 'core.dart'
    show
        Dot,
        Line,
        OrbFrame,
        Projector,
        angleDelta,
        fibDir,
        finalizeFrame,
        frac,
        hashD,
        lerp,
        makeProj,
        radiusScale,
        vnoise;
export 'lattice.dart' show frameGlobe, frameRubik, frameWave;
export 'morph.dart' show frameMorph;
export 'orbits.dart' show frameOrbits;
export 'profiles.dart'
    show
        ModeOpts,
        kBaseProfiles,
        kCountKeys,
        kCountPairs,
        kIconDensityKeys,
        kRadiusKeys,
        scaleCounts,
        scaleRadii;
export 'registry.dart' show ModeFrameFunction, kModeFrames;
export 'ribbon.dart' show frameRibbon;
export 'web.dart' show frameWeb;
