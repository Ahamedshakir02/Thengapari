/// Build flavors mapped to the three Firebase environments.
///
/// See `android/app/build.gradle.kts` for the matching Android product flavors
/// and `android/app/src/<flavor>/google-services.json` for per-env Firebase
/// config. Set via the flavor-specific entrypoints (main_dev/staging/prod.dart).
enum Flavor { dev, staging, prod }

class FlavorConfig {
  final Flavor flavor;
  final String firebaseProjectId;

  FlavorConfig._(this.flavor, this.firebaseProjectId);

  static FlavorConfig? _instance;

  /// Initialise the active flavor. Call once, early in an entrypoint's `main()`.
  factory FlavorConfig(Flavor flavor) {
    final projectId = switch (flavor) {
      Flavor.dev => 'agri-marketplace-dev',
      Flavor.staging => 'agri-marketplace-staging',
      Flavor.prod => 'agri-marketplace-prod',
    };
    return _instance = FlavorConfig._(flavor, projectId);
  }

  /// The active flavor. Defaults to [Flavor.dev] if no entrypoint set one.
  static FlavorConfig get instance =>
      _instance ??= FlavorConfig(Flavor.dev);

  String get name => flavor.name;
  bool get isProd => flavor == Flavor.prod;
}
