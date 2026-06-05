import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

/// Shared phone-OTP authentication, used by all four roles.
///
/// Wraps Firebase Auth phone verification and joins the signed-in
/// FirebaseUser with its `/users/{uid}` profile document so the router
/// can react to both auth state and role assignment.
class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Emits an [AppUser] whenever auth state OR the user's profile doc changes.
  ///
  /// - Signed out            -> `null`
  /// - Signed in, no profile -> [AppUser] with `role == null` (needs role)
  /// - Signed in, has profile-> fully populated [AppUser]
  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().asyncExpand((fbUser) {
      if (fbUser == null) {
        return Stream<AppUser?>.value(null);
      }
      return _firestore
          .collection('users')
          .doc(fbUser.uid)
          .snapshots()
          .map((doc) {
        if (!doc.exists || doc.data() == null) {
          return AppUser(
            uid: fbUser.uid,
            phoneNumber: fbUser.phoneNumber ?? '',
          );
        }
        return AppUser.fromFirestore(fbUser.uid, doc.data()!);
      });
    });
  }

  /// Starts phone-number verification. On Android the OTP may auto-resolve via
  /// [verificationCompleted]; otherwise [codeSent] fires with a verificationId
  /// to pass to [verifyOtp].
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(FirebaseAuthException e) verificationFailed,
    void Function(PhoneAuthCredential credential)? verificationCompleted,
  }) {
    return _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted ?? (_) {},
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// Completes sign-in with the 6-digit SMS code the user entered.
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  /// Persists the chosen [role] to `/users/{uid}`. The auth stream re-emits the
  /// updated [AppUser], which re-runs router redirects (homeowner → profile
  /// setup; other roles → their home).
  Future<void> setRole(UserRole role) async {
    final uid = currentUserId;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).set(
      {
        'role': role.asFirestoreValue,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> signOut() => _auth.signOut();
}
