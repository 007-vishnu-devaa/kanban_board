import 'package:kanbanboard/kanban_board/domain/model/task_entity.dart';

abstract class KanbanBoardRepositories{
  Future<List<KanbanTaskEntity>> getTasks();
  Future<void> addTask(KanbanTaskEntity task);
  Future<void> updateTask(KanbanTaskEntity task);
  Future<void> deleteTask(String id);
}