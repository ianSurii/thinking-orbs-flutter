import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agent_thinking_orbs/agent_thinking_orbs.dart';

void main() {
  runApp(const ThinkingOrbsDemoApp());
}

class ThinkingOrbsDemoApp extends StatefulWidget {
  const ThinkingOrbsDemoApp({super.key});

  @override
  State<ThinkingOrbsDemoApp> createState() => _ThinkingOrbsDemoAppState();
}

class _ThinkingOrbsDemoAppState extends State<ThinkingOrbsDemoApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF090A0F),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6366F1),
        surface: Color(0xFF13151F),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF13151F),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF222638)),
        ),
      ),
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF4F46E5),
        surface: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );

    return MaterialApp(
      title: 'Thinking Orbs for Flutter',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: ThinkingOrbsGalleryScreen(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class ThinkingOrbsGalleryScreen extends StatefulWidget {
  const ThinkingOrbsGalleryScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<ThinkingOrbsGalleryScreen> createState() =>
      _ThinkingOrbsGalleryScreenState();
}

class _ThinkingOrbsGalleryScreenState extends State<ThinkingOrbsGalleryScreen> {
  OrbState _selectedState = OrbState.searching;
  OrbSize _selectedSize = OrbSize.px64;
  double _customDimension = 64.0;
  bool _useCustomDimension = false;
  double _speed = 1.0;
  bool _paused = false;
  OrbTheme _themeOption = OrbTheme.auto;
  Color? _customColor;

  final Map<String, Color?> _colorPalette = {
    'Monochrome': null,
    'Indigo': const Color(0xFF818CF8),
    'Cyan': const Color(0xFF38BDF8),
    'Emerald': const Color(0xFF34D399),
    'Amber': const Color(0xFFFBBF24),
    'Rose': const Color(0xFFFB7185),
  };

  String _generateCodeSnippet() {
    final buffer = StringBuffer('ThinkingOrb(\n');
    buffer.writeln('  state: OrbState.${_selectedState.name},');
    if (_useCustomDimension) {
      buffer.writeln('  customDimension: ${_customDimension.toInt()},');
    } else {
      buffer.writeln('  size: OrbSize.${_selectedSize.name},');
    }
    if (_themeOption != OrbTheme.auto) {
      buffer.writeln('  theme: OrbTheme.${_themeOption.name},');
    }
    if (_speed != 1.0) {
      buffer.writeln('  speed: ${_speed.toStringAsFixed(1)},');
    }
    if (_paused) {
      buffer.writeln('  paused: true,');
    }
    if (_customColor != null) {
      buffer.writeln('  color: const Color(0x${_customColor!.toARGB32().toRadixString(16).toUpperCase()}),');
    }
    buffer.write(')');
    return buffer.toString();
  }

  void _copyCodeToClipboard() {
    final code = _generateCodeSnippet();
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Flutter code copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const ThinkingOrb(
                state: OrbState.breathing,
                size: OrbSize.px20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Thinking Orbs',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'v0.3.1',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: widget.isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              widget.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Banner
                _buildHeroSection(isDark, primaryColor),

                const SizedBox(height: 32),

                // Interactive Playground
                _buildInteractivePlayground(isDark, primaryColor),

                const SizedBox(height: 48),

                // All 9 States Gallery
                _buildStatesGallery(isDark),

                const SizedBox(height: 48),

                // Size Comparison
                _buildSizeComparison(isDark),

                const SizedBox(height: 48),

                // Footer
                _buildFooter(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
              : [const Color(0xFFEEF2FF), const Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF312E81) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '100% MATHEMATICAL PARITY',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Dotted thought-orb loading indicators for AI & agent UIs in Flutter',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Nine hand-tuned verb states × two tuned sizes, rendered honestly in 3D on a plain 2D canvas with depth-sorted shading and synchronized monotonic clocking.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThinkingOrb.large(state: _selectedState),
              const SizedBox(width: 16),
              ThinkingOrb.small(state: _selectedState),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractivePlayground(bool isDark, Color primaryColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Interactive Playground',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                ElevatedButton.icon(
                  onPressed: _copyCodeToClipboard,
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview Stage
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 280,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF090A0F)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF222638)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Center(
                      child: ThinkingOrb(
                        state: _selectedState,
                        size: _selectedSize,
                        customDimension:
                            _useCustomDimension ? _customDimension : null,
                        speed: _speed,
                        paused: _paused,
                        theme: _themeOption,
                        color: _customColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Controls Panel
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // State Selector
                      const Text(
                        'Orb State (Verb)',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: OrbState.values.map((s) {
                          final selected = _selectedState == s;
                          return ChoiceChip(
                            label: Text(s.name),
                            selected: selected,
                            onSelected: (val) {
                              if (val) setState(() => _selectedState = s);
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Size Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Size Preset',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey),
                          ),
                          if (_useCustomDimension)
                            Text(
                              '${_customDimension.toInt()} px (custom)',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SegmentedButton<OrbSize>(
                              segments: const [
                                ButtonSegment(
                                  value: OrbSize.px64,
                                  label: Text('Large (64px)'),
                                ),
                                ButtonSegment(
                                  value: OrbSize.px20,
                                  label: Text('Small (20px)'),
                                ),
                              ],
                              selected: {_selectedSize},
                              onSelectionChanged: (val) {
                                setState(() {
                                  _selectedSize = val.first;
                                  _customDimension = _selectedSize.dimension.toDouble();
                                  _useCustomDimension = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _customDimension,
                        min: 16.0,
                        max: 120.0,
                        divisions: 26,
                        onChanged: (v) => setState(() {
                          _customDimension = v;
                          _useCustomDimension = true;
                          _selectedSize = OrbSize.fromInt(v.toInt());
                        }),
                      ),

                      const SizedBox(height: 16),

                      // Speed Multiplier
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Speed Multiplier',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey),
                          ),
                          Text('${_speed.toStringAsFixed(1)}x',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Slider(
                        value: _speed,
                        min: 0.2,
                        max: 3.0,
                        divisions: 14,
                        onChanged: (v) => setState(() => _speed = v),
                      ),

                      const SizedBox(height: 12),

                      // Theme mode selector
                      const Text(
                        'Orb Theme Mode',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<OrbTheme>(
                        segments: const [
                          ButtonSegment(
                            value: OrbTheme.auto,
                            label: Text('Auto'),
                          ),
                          ButtonSegment(
                            value: OrbTheme.dark,
                            label: Text('Dark'),
                          ),
                          ButtonSegment(
                            value: OrbTheme.light,
                            label: Text('Light'),
                          ),
                        ],
                        selected: {_themeOption},
                        onSelectionChanged: (val) {
                          setState(() => _themeOption = val.first);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Color Tints & Play/Pause
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tint Color',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: _colorPalette.entries.map((e) {
                                    final isSelected = _customColor == e.value;
                                    return InkWell(
                                      onTap: () => setState(
                                          () => _customColor = e.value),
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: e.value ??
                                              (isDark
                                                  ? Colors.white
                                                  : Colors.black87),
                                          shape: BoxShape.circle,
                                          border: isSelected
                                              ? Border.all(
                                                  color: primaryColor, width: 3)
                                              : null,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                setState(() => _paused = !_paused),
                            icon: Icon(
                                _paused ? Icons.play_arrow : Icons.pause),
                            label: Text(_paused ? 'Resume' : 'Pause'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatesGallery(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All 9 Hand-Tuned States',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Every state is a distinct mathematical animation with tailored particle trajectories and depth shading.',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 360,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            mainAxisExtent: 104,
          ),
          itemCount: OrbState.values.length,
          itemBuilder: (context, index) {
            final state = OrbState.values[index];
            final isSelected = _selectedState == state;

            return InkWell(
              onTap: () => setState(() => _selectedState = state),
              borderRadius: BorderRadius.circular(16),
              child: Card(
                color: isSelected
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: isDark ? 0.2 : 0.08)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : (isDark
                            ? const Color(0xFF222638)
                            : const Color(0xFFE2E8F0)),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      ThinkingOrb.large(state: state),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getStateDescription(state),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.25,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSizeComparison(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Purpose-Tuned Sizes (Not just a scale factor)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '64px (chat-avatar scale) and 20px (inline-text scale) carry separate dot counts, dot radii, and speed tunings.',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 640),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(2.4),
                    2: FlexColumnWidth(2.4),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isDark
                                ? const Color(0xFF222638)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('State',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Large (64px Avatar)',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Small (20px Inline)',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    ...OrbState.values.map((state) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(state.name,
                                style:
                                    const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ThinkingOrb.large(state: state),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    'ThinkingOrb.large(\n  state: OrbState.${state.name},\n)',
                                    style: const TextStyle(
                                        fontSize: 11, fontFamily: 'monospace'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ThinkingOrb.small(state: state),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    'ThinkingOrb.small(\n  state: OrbState.${state.name},\n)',
                                    style: const TextStyle(
                                        fontSize: 11, fontFamily: 'monospace'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Center(
      child: Column(
        children: [
          Text(
            'thinking_orbs for Flutter • MIT License',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dotted thought-orb loading indicators for AI & agent interfaces',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[600] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getStateDescription(OrbState state) {
    return switch (state) {
      OrbState.working => 'particles on tilted orbits',
      OrbState.searching => 'a scan meridian sweeps a dotted globe',
      OrbState.solving => 'bands scramble, then click back solved',
      OrbState.listening => 'a waveform rolls through latitude rings',
      OrbState.connecting => 'a constellation wires itself with packets',
      OrbState.weaving => 'three strands plait around the sphere',
      OrbState.composing => 'an undulating multi-band sash',
      OrbState.breathing => 'a face-on ring slowly morphing',
      OrbState.shaping => 'dotted outline: circle → triangle → square',
    };
  }
}
