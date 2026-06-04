import 'app/flavor_config.dart';
import 'bootstrap.dart';

/// Prod entrypoint:  flutter run --flavor prod -t lib/main_prod.dart
void main() => bootstrap(Flavor.prod);
