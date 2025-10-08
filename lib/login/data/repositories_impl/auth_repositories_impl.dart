import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
      Fluttertoast.showToast(
        msg: e.message ?? 'Sign In failed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.teal,
        textColor: Colors.white,
        fontSize: 16.0
    );
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
       Fluttertoast.showToast(
        msg: e.message ?? 'Sign Up failed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.teal,
        textColor: Colors.white,
        fontSize: 16.0
    );
    }
    return null;
  }
}
