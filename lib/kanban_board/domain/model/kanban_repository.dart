import 'package:kanbanboard/kanban_board/domain/model/task_entity.dart';

abstract class KanbanBoardRepositories{
  Future<List<kanbanTaskEntity>> getTasks();
  Future<void> addTask(kanbanTaskEntity task);
  Future<void> updateTask(kanbanTaskEntity task);
  Future<void> deleteTask(String id);
}