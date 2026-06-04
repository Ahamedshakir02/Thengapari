import 'app/flavor_config.dart';
import 'bootstrap.dart';

/// Staging entrypoint:  flutter run --flavor staging -t lib/main_staging.dart
void main() => bootstrap(Flavor.staging);
