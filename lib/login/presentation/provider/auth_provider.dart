// coverage:ignore-file
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/repositories_impl/auth_repositories_impl.dart';
import '../../domain/model/user_entity.dart';
import '../../domain/repositories/auth_repositories.dart';
import '../notifier/auth_notifier.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl());

final loginControllerProvider =
    StateNotifierProvider<LoginNotifier, AsyncValue<UserEntity?>>(
  (ref) => LoginNotifier(ref.read(authRepositoryProvider)),
);
