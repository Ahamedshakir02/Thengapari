import 'package:flutter/material.dart';

import 'features/dev/widget_gallery_screen.dart';

/// Dev entrypoint:  flutter run --flavor dev -t lib/main_dev.dart
///
/// During the foundation phase this boots the [WidgetGalleryApp] — a scrollable
/// page rendering every shared widget and custom painter for visual review.
/// It deliberately skips Firebase/router boot so it hot-reloads instantly.
///
/// To run the real app shell instead, use `bootstrap(Flavor.dev)` (see
/// `bootstrap.dart`) or run another flavor entrypoint.
void main() => runApp(const WidgetGalleryApp());
