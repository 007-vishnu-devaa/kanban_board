import 'package:flutter_riverpod/legacy.dart';
import '../model/task_entity.dart';

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier(super.initialTasks);

  void updateTask(Task updatedTask) {
    state = [
      for (final task in state)
        if (task.id == updatedTask.id) updatedTask else task
    ];
  }

  void changeTaskStatus(String taskId, String newStatus) {
    state = [
      for (final task in state)
        if (task.id == taskId) task.copyWith(status: newStatus) else task
    ];
  }
}
