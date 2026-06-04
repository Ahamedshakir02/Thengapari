import 'app/flavor_config.dart';
import 'bootstrap.dart';

/// Default entrypoint so a plain `flutter run` works during development.
/// For an explicit environment use main_dev / main_staging / main_prod.dart
/// together with the matching `--flavor`.
void main() => bootstrap(Flavor.dev);
