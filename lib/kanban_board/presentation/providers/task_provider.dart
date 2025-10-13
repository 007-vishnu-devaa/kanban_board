import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/repositories_impl/task_repositories_impl.dart';
import '../../domain/usecases/task_usecases.dart';
import '../../domain/model/task_entity.dart';
import '../../domain/notifier/task_notifier.dart';
// Keep data-layer types out of the presentation layer. Errors are handled
// as generic objects/Exceptions so UI doesn't depend on cloud_firestore.

import '../../../core/api_response.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) => TaskRepository());

/// Use-case providers to follow clean architecture boundaries.
final addTaskUseCaseProvider = Provider((ref) => AddTaskUseCase(ref.read(taskRepositoryProvider)));
final updateTaskUseCaseProvider = Provider((ref) => UpdateTaskUseCase(ref.read(taskRepositoryProvider)));
final deleteTaskUseCaseProvider = Provider((ref) => DeleteTaskUseCase(ref.read(taskRepositoryProvider)));
final getTasksOnceUseCaseProvider = Provider((ref) => GetTasksOnceUseCase(ref.read(taskRepositoryProvider)));
final getTasksStreamUseCaseProvider = Provider((ref) => GetTasksStreamUseCase(ref.read(taskRepositoryProvider)));

/// Holds the latest Firestore error message (if any). UI can watch this to display
/// user-friendly errors (permission denied, network issues, etc.).
final firestoreErrorProvider = StateProvider<String?>((ref) => null);

/// Tracks the state of long-running tasks-related operations (refresh, move)
/// using a unified ApiResponse wrapper instead of booleans.
final tasksOperationProvider = StateProvider<ApiResponse<void>>((ref) => const ApiResponse.initial());

/// Provides a function that refreshes tasks once from the repository.
final refreshTasksProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final getOnce = ref.read(getTasksOnceUseCaseProvider);
      ref.read(tasksOperationProvider.notifier).state = const ApiResponse.loading();
    try {
      final tasks = await getOnce();
      ref.read(taskNotifierProvider.notifier).setTasks(tasks);
      ref.read(firestoreErrorProvider.notifier).state = null;
        ref.read(tasksOperationProvider.notifier).state = const ApiResponse.success(null);
      } catch (e) {
        ref.read(firestoreErrorProvider.notifier).state = e.toString();
        ref.read(tasksOperationProvider.notifier).state = ApiResponse.failure(e.toString());
    }
  };
});

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  final notifier = TaskNotifier(<Task>[]);
  final sub = ref.read(getTasksStreamUseCaseProvider)().listen((tasks) {
    notifier.setTasks(tasks);
    // Clear any previous Firestore errors on successful data
    ref.read(firestoreErrorProvider.notifier).state = null;
  });

  sub.onError((err) {
    // Errors can be of varying types depending on the implementation injected
    // into the repository. Convert to a string for display but avoid
    // importing data-layer exception classes here.
    ref.read(firestoreErrorProvider.notifier).state = err?.toString() ?? 'Unknown error';
  });

  ref.onDispose(() {
    sub.cancel();
  });

  return notifier;
});
