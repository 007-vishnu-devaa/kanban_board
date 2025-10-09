import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanbanboard/login/presentation/notifier/auth_notifier.dart';
import 'package:kanbanboard/login/domain/repositories/auth_repositories.dart';
import 'package:kanbanboard/login/domain/model/user_entity.dart';

// A fake repository that overrides network behaviour for tests.
class FakeAuthRepository implements AuthRepository {
  final bool shouldThrow;
  final UserEntity? result;

  FakeAuthRepository({this.shouldThrow = false, this.result});

  @override
  Future<UserEntity?> login(String email, String password) async {
    if (shouldThrow) throw Exception('login failed');
    return result ?? UserEntity(uid: 'u1', email: email);
  }

  @override
  Future<UserEntity?> signUp(String email, String password) async {
    if (shouldThrow) throw Exception('signup failed');
    return result ?? UserEntity(uid: 'u2', email: email);
  }
}

void main() {
  test('login success sets AsyncData with user', () async {
    final repo = FakeAuthRepository();
    final notifier = LoginNotifier(repo);

    // initial state should be AsyncData(null)
    expect(notifier.state, const AsyncData<UserEntity?>(null));

    await notifier.login('test@example.com', 'password');

    final state = notifier.state;
    expect(state, isA<AsyncData<UserEntity?>>());

    final user = (state as AsyncData<UserEntity?>).value;
    expect(user, isNotNull);
    expect(user!.email, 'test@example.com');
  });

  test('login failure sets AsyncError', () async {
    final repo = FakeAuthRepository(shouldThrow: true);
    final notifier = LoginNotifier(repo);

    await notifier.login('a@b.com', 'bad');

    expect(notifier.state, isA<AsyncError>());
  });

  test('signUp success sets AsyncData with user', () async {
    final repo = FakeAuthRepository();
    final notifier = LoginNotifier(repo);

    await notifier.signUp('new@example.com', 'password');

    final state = notifier.state;
    expect(state, isA<AsyncData<UserEntity?>>());

    final user = (state as AsyncData<UserEntity?>).value;
    expect(user, isNotNull);
    expect(user!.email, 'new@example.com');
  });

  test('signUp failure sets AsyncError', () async {
    final repo = FakeAuthRepository(shouldThrow: true);
    final notifier = LoginNotifier(repo);

    await notifier.signUp('x@y.com', 'bad');

    expect(notifier.state, isA<AsyncError>());
  });
}
