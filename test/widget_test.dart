// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanbanboard/core/connectivity/connectivity_service.dart';
import 'package:kanbanboard/main.dart';
import 'package:kanbanboard/login/domain/repositories/auth_repositories.dart';
import 'package:kanbanboard/login/domain/model/user_entity.dart';
import 'package:kanbanboard/login/presentation/provider/auth_provider.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<UserEntity?> login(String email, String password) async => null;

  @override
  Future<UserEntity?> signUp(String email, String password) async => null;
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope and stub connectivity so the
    // connectivity StreamProvider doesn't start network checks/timers.
    // Provide a fake AuthRepository so the production Firebase-backed
    // implementation is not instantiated (avoids Firebase.initializeApp()
    // and related errors during tests).
    await tester.pumpWidget(ProviderScope(overrides: [
      connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
    ], child: const MyApp()));

    // Verify that the login UI is shown (Sign In button present).
    expect(find.text('Sign In'), findsOneWidget);
  });
}
