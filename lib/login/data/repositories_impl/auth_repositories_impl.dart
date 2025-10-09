import 'package:firebase_auth/firebase_auth.dart';
import 'package:kanbanboard/core/widgets/toast.dart';
import '../../domain/model/user_entity.dart';
import '../../domain/repositories/auth_repositories.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<UserEntity?> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        return UserEntity(uid: user.uid, email: user.email ?? '');
      }
    } on FirebaseAuthException catch (e) {
      FlutterToast(toastMsg: e.message ?? 'Sign In failed').toast();
    }
    return null;
  }

  @override
  Future<UserEntity?> signUp(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        return UserEntity(uid: user.uid, email: user.email ?? '');
      }
    } on FirebaseAuthException catch (e) {
      FlutterToast(toastMsg: e.message ?? 'Sign Up failed').toast();
    }
    return null;
  }
}
