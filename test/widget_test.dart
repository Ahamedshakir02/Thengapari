// Role-based routing tests.
//
// These exercise the GoRouter redirect in lib/app/router.dart by overriding
// `authStateProvider` with a fixed auth state — no Firebase required. They are
// the foundation's proof that "routing works".
import 'package:thengapari/app/app.dart';
import 'package:thengapari/core/models/app_user.dart';
import 'package:thengapari/core/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpApp(WidgetTester tester, AppUser? user) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream<AppUser?>.value(user)),
      ],
      child: const AgriApp(),
    ),
  );
  await tester.pumpAndSettle();
}

AppUser _userWithRole(UserRole role) =>
    AppUser(uid: 'u1', phoneNumber: '+910000000000', role: role);

void main() {
  testWidgets('signed-out user lands on the login screen', (tester) async {
    await _pumpApp(tester, null);
    expect(find.text('Send OTP'), findsOneWidget);
  });

  testWidgets('signed-in user with no role lands on the role gate',
      (tester) async {
    await _pumpApp(tester, const AppUser(uid: 'u1', phoneNumber: '+910'));
    expect(find.text('Choose your role'), findsOneWidget);
  });

  testWidgets('homeowner without a profile routes to profile setup',
      (tester) async {
    // A homeowner whose profile is incomplete (no name/district) is funnelled
    // into onboarding before reaching the home dashboard.
    await _pumpApp(tester, _userWithRole(UserRole.homeowner));
    expect(find.text('Set up your profile'), findsOneWidget);
  });

  testWidgets('worker routes to the worker app', (tester) async {
    await _pumpApp(tester, _userWithRole(UserRole.worker));
    expect(find.text('Worker App'), findsOneWidget);
  });

  testWidgets('site manager routes to the site manager app', (tester) async {
    await _pumpApp(tester, _userWithRole(UserRole.siteManager));
    expect(find.text('Site Manager App'), findsOneWidget);
  });

  testWidgets('b2b buyer routes to the b2b portal', (tester) async {
    await _pumpApp(tester, _userWithRole(UserRole.b2b));
    expect(find.text('B2B Portal'), findsOneWidget);
  });
}
