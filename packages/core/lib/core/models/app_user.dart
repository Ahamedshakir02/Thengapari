/// The shared `/users/{uid}` document, common to all four roles.
///
/// Hand-written for the foundation phase. The plan migrates models to
/// `freezed` + `json_serializable` once feature work begins; the dev
/// dependencies for that are already in pubspec.yaml.
enum UserRole {
  homeowner,
  worker,
  siteManager,
  b2b;

  /// Firestore stores roles as snake_case strings.
  static UserRole? fromString(String? value) => switch (value) {
        'homeowner' => UserRole.homeowner,
        'worker' => UserRole.worker,
        'site_manager' => UserRole.siteManager,
        'b2b' => UserRole.b2b,
        _ => null,
      };

  String get asFirestoreValue => switch (this) {
        UserRole.homeowner => 'homeowner',
        UserRole.worker => 'worker',
        UserRole.siteManager => 'site_manager',
        UserRole.b2b => 'b2b',
      };
}

class AppUser {
  final String uid;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? district;
  final UserRole? role;

  const AppUser({
    required this.uid,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.district,
    this.role,
  });

  /// True once the user has been assigned a role (set at first login).
  bool get hasRole => role != null;

  /// True once the homeowner has completed profile setup (name + district
  /// written to `/users/{uid}`). Drives the onboarding redirect in the router.
  bool get isProfileComplete =>
      firstName != null && firstName!.isNotEmpty && district != null;

  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      phoneNumber: data['phoneNumber'] as String? ?? '',
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      district: data['district'] as String?,
      role: UserRole.fromString(data['role'] as String?),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'phoneNumber': phoneNumber,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (district != null) 'district': district,
        if (role != null) 'role': role!.asFirestoreValue,
      };
}
