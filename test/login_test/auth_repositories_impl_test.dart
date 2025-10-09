import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/services.dart';
import 'package:kanbanboard/login/data/repositories_impl/auth_repositories_impl.dart';
import 'package:kanbanboard/login/domain/model/user_entity.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  // Ensure Flutter bindings are initialized because AuthRepositoryImpl's
  // error path shows a Flutter toast which uses platform channels.
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel _toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
  setUpAll(() {
    // Prevent MissingPluginException by stubbing the fluttertoast method channel.
    _toastChannel.setMockMethodCallHandler((call) async => null);
  });
  tearDownAll(() {
    _toastChannel.setMockMethodCallHandler(null);
  });
  late MockFirebaseAuth mockAuth;
  late AuthRepositoryImpl repo;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    repo = AuthRepositoryImpl(firebaseAuth: mockAuth);
  });

  group('AuthRepositoryImpl.login', () {
    test('returns UserEntity on successful sign in', () async {
      final mockCred = MockUserCredential();
      final mockUser = MockUser();

      when(() => mockAuth.signInWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => mockCred);
      when(() => mockCred.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('uid1');
      when(() => mockUser.email).thenReturn('a@b.com');

      final result = await repo.login('a@b.com', 'pass');
      expect(result, isA<UserEntity>());
      expect(result?.uid, 'uid1');
      expect(result?.email, 'a@b.com');
    });

    test('returns null and shows toast on FirebaseAuthException', () async {
      when(() => mockAuth.signInWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(FirebaseAuthException(code: 'user-not-found', message: 'not found'));

      final result = await repo.login('x@x.com', 'bad');
      expect(result, isNull);
    });
  });

  group('AuthRepositoryImpl.signUp', () {
    test('returns UserEntity on successful createUser', () async {
      final mockCred = MockUserCredential();
      final mockUser = MockUser();

      when(() => mockAuth.createUserWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => mockCred);
      when(() => mockCred.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('uid2');
      when(() => mockUser.email).thenReturn('c@d.com');

      final result = await repo.signUp('c@d.com', 'pass');
      expect(result, isA<UserEntity>());
      expect(result?.uid, 'uid2');
      expect(result?.email, 'c@d.com');
    });

    test('returns null and shows toast on FirebaseAuthException', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(FirebaseAuthException(code: 'invalid', message: 'bad'));

      final result = await repo.signUp('y@y.com', 'bad');
      expect(result, isNull);
    });
  });
}
