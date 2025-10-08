import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/repositories_impl/task_repositories_impl.dart';
import '../../domain/model/task_entity.dart';
import '../../domain/notifier/task_notifier.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) => TaskRepository());

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return TaskNotifier(repo.getTasks());
});
