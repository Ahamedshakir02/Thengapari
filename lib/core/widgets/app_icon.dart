import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/tree_inventory.dart';

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// Stroke UI icons ported verbatim from the design's `app-icons.jsx`
/// (24-grid, round caps/joins). Rendered as real SVG so they match the design.
class AppIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  final double strokeWidth;

  const AppIcon(
    this.name, {
    this.size = 24,
    this.color = const Color(0xFF2B2A24),
    this.strokeWidth = 2,
    super.key,
  });

  static const _paths = <String, String>{
    'home':
        '<path d="M4 11.5 12 4l8 7.5"/><path d="M6 10.5V20h12v-9.5"/><path d="M10 20v-5h4v5"/>',
    'calendar':
        '<rect x="4" y="5" width="16" height="16" rx="3"/><path d="M4 9h16M8 3v4M16 3v4"/>',
    'report':
        '<rect x="5" y="3" width="14" height="18" rx="3"/><path d="M9 12v4M12 9v7M15 13v3"/>',
    'profile':
        '<circle cx="12" cy="8.5" r="3.6"/><path d="M5.5 19.5a6.5 6.5 0 0 1 13 0"/>',
    'arrow-right': '<path d="M4 12h15M13 6l6 6-6 6"/>',
    'plus': '<path d="M12 5v14M5 12h14"/>',
    'chevron-right': '<path d="M9 5l7 7-7 7"/>',
    'chevron-left': '<path d="M15 5l-7 7 7 7"/>',
    'check': '<path d="M5 12.5 10 17l9-10"/>',
    'leaf': '<path d="M5 19c0-8 6-13 14-13 0 8-5 14-13 14"/><path d="M5 19c2-4 5-7 9-9"/>',
    'rupee': '<path d="M7 5h10M7 9h10M16 5c0 4-3.5 5-7 5l7 9"/>',
    'feather':
        '<path d="M19 5c-3 0-9 1-12 8l-3 5"/><path d="M19 5c0 6-4 11-10 11H4"/><path d="M9 13h6"/>',
    'trend-up': '<path d="M4 16l5-5 3 3 7-7"/><path d="M16 7h4v4"/>',
    'scale':
        '<path d="M12 4v16M7 4h10"/><path d="M7 4 4 11a3 3 0 0 0 6 0L7 4Z"/><path d="M17 4l-3 7a3 3 0 0 0 6 0l-3-7Z"/>',
    'tree':
        '<path d="M12 21v-5"/><path d="M12 16c-3.5 0-6-2.4-6-5.5C6 7 8.5 4 12 4s6 3 6 6.5c0 3.1-2.5 5.5-6 5.5Z"/>',
    'wallet': '<rect x="4" y="6" width="16" height="13" rx="3"/><path d="M4 9h16"/>',
    'globe':
        '<circle cx="12" cy="12" r="8"/><path d="M4 12h16M12 4c2.5 2.5 2.5 13 0 16M12 4c-2.5 2.5-2.5 13 0 16"/>',
    'shield':
        '<path d="M12 3l7 2.5V11c0 5-3.5 8-7 10-3.5-2-7-5-7-10V5.5Z"/><path d="M9 12l2 2 4-4"/>',
    'pin':
        '<path d="M12 21s7-6.3 7-11a7 7 0 1 0-14 0c0 4.7 7 11 7 11Z"/><circle cx="12" cy="10" r="2.6"/>',
    'phone':
        '<path d="M6.5 4h3l1.5 4-2 1.5a11 11 0 0 0 5 5l1.5-2 4 1.5v3a2 2 0 0 1-2 2A15 15 0 0 1 4.5 6a2 2 0 0 1 2-2Z"/>',
    'home-place':
        '<path d="M4 11.5 12 4l8 7.5"/><path d="M6 10.5V20h12v-9.5"/>',
    'recycle':
        '<path d="M8 5.5 10.3 9 6.5 9.2l-2.3 4a2 2 0 0 0 1.7 3H8"/><path d="M14.5 6.5 13 4h-2.5"/><path d="M16.5 9.5 18.8 13l2-.6"/><path d="M14 18.5h3.8a2 2 0 0 0 1.7-3l-1-1.7"/><path d="M11 18.5 14 21l.2-3.6"/>',
    'chat':
        '<path d="M5 5h14a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H9l-4 3.5V6a1 1 0 0 1 1-1Z"/>',
    'coconut':
        '<circle cx="12" cy="13" r="7"/><path d="M9.5 12.5h.01M14.5 12.5h.01M12 15.5h.01"/><path d="M12 6V4"/>',
  };

  @override
  Widget build(BuildContext context) {
    final inner = _paths[name] ?? '';
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
        'fill="none" stroke="${_hex(color)}" stroke-width="$strokeWidth" '
        'stroke-linecap="round" stroke-linejoin="round">$inner</svg>';
    return SvgPicture.string(svg, width: size, height: size);
  }
}

/// Filled crop motifs ported from the design's `app-icons.jsx` crop glyphs.
class CropGlyph extends StatelessWidget {
  final CropType type;
  final double size;
  final Color color;

  const CropGlyph(
    this.type, {
    this.size = 22,
    this.color = const Color(0xFF1E4D2B),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = _hex(color);
    final inner = switch (type) {
      CropType.coconut =>
        '<path d="M12 9c0-3-1-5.4-3.6-7 -.3 3 .9 5.2 3.6 6.6Z" fill="$c"/>'
            '<path d="M12 9c0-3 1-5.4 3.6-7 .3 3-.9 5.2-3.6 6.6Z" fill="$c" opacity=".7"/>'
            '<circle cx="12" cy="15.5" r="5.6" fill="$c"/>'
            '<circle cx="10" cy="14.5" r=".95" fill="#fff" opacity=".55"/>'
            '<circle cx="14" cy="14.5" r=".95" fill="#fff" opacity=".55"/>'
            '<circle cx="12" cy="17.6" r=".95" fill="#fff" opacity=".55"/>',
      CropType.mango =>
        '<path d="M16.5 6c2.5 2 3 5.5 1.2 8.4-1.7 2.8-5.2 4.2-8.4 3.3-2.6-.8-3.8-3-3-5.6C7.4 8 12 5 16.5 6Z" fill="$c"/>'
            '<path d="M16.5 6c.7-1 1.7-1.6 2.8-1.7-.2 1.2-.9 2.1-1.9 2.6" stroke="$c" stroke-width="1.6" stroke-linecap="round" fill="none"/>',
      CropType.pepper =>
        '<path d="M12 4c2 0 3 1.2 3 2.5" stroke="$c" stroke-width="1.6" stroke-linecap="round" fill="none"/>'
            '<g fill="$c"><circle cx="11" cy="9" r="1.5"/><circle cx="14" cy="10.5" r="1.5"/>'
            '<circle cx="10.5" cy="12.5" r="1.5"/><circle cx="13.5" cy="14" r="1.5"/>'
            '<circle cx="11.5" cy="16" r="1.5"/><circle cx="14.5" cy="17.5" r="1.5"/>'
            '<circle cx="12" cy="19" r="1.5"/></g>',
      CropType.jackfruit =>
        '<path d="M12 4c.2-1 1-1.4 2-1.2-.2 1-.8 1.5-1.6 1.5" stroke="$c" stroke-width="1.5" stroke-linecap="round" fill="none"/>'
            '<ellipse cx="12" cy="13.5" rx="6" ry="7" fill="$c"/>'
            '<g fill="#fff" opacity=".4"><circle cx="10" cy="11" r="1"/><circle cx="14" cy="11" r="1"/>'
            '<circle cx="12" cy="13.5" r="1"/><circle cx="10" cy="16" r="1"/><circle cx="14" cy="16" r="1"/></g>',
      CropType.areca =>
        '<ellipse cx="12" cy="13" rx="5" ry="6.5" fill="$c"/>'
            '<path d="M12 6.5c0-1.6.8-2.8 2.4-3.3.2 1.6-.6 2.8-2 3.3Z" fill="$c" opacity=".7"/>',
    };
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none">$inner</svg>';
    return SvgPicture.string(svg, width: size, height: size);
  }
}

/// Per-crop chip tint (background) and glyph foreground, matching the design.
class CropPalette {
  CropPalette._();

  static Color tint(CropType t) => switch (t) {
        CropType.coconut => const Color(0xFFE6EFD9),
        CropType.mango => const Color(0xFFFCEBCB),
        CropType.jackfruit => const Color(0xFFECF3E0),
        CropType.pepper => const Color(0xFFF8DED6),
        CropType.areca => const Color(0xFFFBDFA6),
      };

  static Color fg(CropType t) => switch (t) {
        CropType.coconut => const Color(0xFF2E6B3E),
        CropType.mango => const Color(0xFFDD8413),
        CropType.jackfruit => const Color(0xFF4C7A3C),
        CropType.pepper => const Color(0xFFA33523),
        CropType.areca => const Color(0xFFB86A06),
      };
}
