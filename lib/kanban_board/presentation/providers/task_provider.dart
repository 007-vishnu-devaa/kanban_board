import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/repositories_impl/task_repositories_impl.dart';
import '../../domain/model/task_entity.dart';
import '../../domain/notifier/task_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;

final taskRepositoryProvider = Provider<TaskRepository>((ref) => TaskRepository());

/// Holds the latest Firestore error message (if any). UI can watch this to display
/// user-friendly errors (permission denied, network issues, etc.).
final firestoreErrorProvider = StateProvider<String?>((ref) => null);

/// Loading flag for manual operations like pull-to-refresh.
final tasksLoadingProvider = StateProvider<bool>((ref) => false);

/// Provides a function that refreshes tasks once from the repository.
final refreshTasksProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final repo = ref.read(taskRepositoryProvider);
    ref.read(tasksLoadingProvider.notifier).state = true;
    try {
      final tasks = await repo.getTasksOnce();
      ref.read(taskNotifierProvider.notifier).setTasks(tasks);
      ref.read(firestoreErrorProvider.notifier).state = null;
    } catch (e) {
      ref.read(firestoreErrorProvider.notifier).state = e.toString();
    } finally {
      ref.read(tasksLoadingProvider.notifier).state = false;
    }
  };
});

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  final notifier = TaskNotifier(<Task>[]);

  final sub = repo.getTasksStream().listen((tasks) {
    notifier.setTasks(tasks);
    // Clear any previous Firestore errors on successful data
    ref.read(firestoreErrorProvider.notifier).state = null;
  });

  sub.onError((err) {
    // Try to get a friendly message for FirebaseException
    String message;
    if (err is FirebaseException) {
      message = err.message ?? err.toString();
    } else {
      message = err.toString();
    }
    ref.read(firestoreErrorProvider.notifier).state = message;
  });

  ref.onDispose(() {
    sub.cancel();
  });

  return notifier;
});
