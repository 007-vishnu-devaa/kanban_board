import 'package:flutter_riverpod/legacy.dart';
import 'package:kanbanboard/kanban_board/presentation/state/kanban_board_state.dart';
import '../../domain/model/kanban_repository.dart';
import '../../domain/model/task_entity.dart';

class KanbanTaskNotifier extends StateNotifier<KanbanBoardState> {
  final KanbanBoardRepositories repository;
  KanbanTaskNotifier(this.repository) : super(const KanbanBoardState.initial());

  Future<void> fetchTasks() async {
    state = state.copyWith(state: KanbanBoardApiStatus.loading);
    try {
      final tasks = await repository.getTasks();
      state = state.copyWith(
        state: KanbanBoardApiStatus.success,
        kanbanBoardData: tasks);
    } catch (e) {
      state = state.copyWith(state: KanbanBoardApiStatus.failure);
    }
  } 
  Future<void> addTask(kanbanTaskEntity task) async {
    state = state.copyWith(dataState: KanbanBoardApiStatus.loading);
    try {
      await repository.addTask(task);
      state = state.copyWith(dataState: KanbanBoardApiStatus.success);
    } catch (e) {
      state = state.copyWith(dataState: KanbanBoardApiStatus.failure);
    }
  }
  Future<void> updateTask(kanbanTaskEntity task) async {
    state = state.copyWith(dataState: KanbanBoardApiStatus.loading);
    try {
      await repository.updateTask(task);
      state = state.copyWith(dataState: KanbanBoardApiStatus.success);
    } catch (e) {
      state = state.copyWith(dataState: KanbanBoardApiStatus.failure);
    }
  }
  Future<void> deleteTask(String id) async {
    state = state.copyWith(dataState: KanbanBoardApiStatus.loading);
    try {
      await repository.deleteTask(id);
      state = state.copyWith(dataState: KanbanBoardApiStatus.success);
    } catch (e) { 
      state = state.copyWith(dataState: KanbanBoardApiStatus.failure);
    }
  }
  Future<void> changeTaskStatus(String taskId, String newStatus) {
    final task = state.kanbanBoardData?.firstWhere((t) => t.id == taskId);
    if (task != null) {
      final updatedTask = task.copyWith(status: newStatus);
      return updateTask(updatedTask);
    }
    return Future.value();
  }
}
