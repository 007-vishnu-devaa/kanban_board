import 'package:kanbanboard/kanban_board/domain/model/task_entity.dart';
import 'package:kanbanboard/kanban_board/domain/model/kanban_repository.dart';

// Keep tests using the familiar `Task` identifier by aliasing it to the
// current domain model `kanbanTaskEntity`.
typedef Task = kanbanTaskEntity;

/// A tiny in-memory fake repository implementing the production
/// `KanbanBoardRepositories` interface. Tests can construct it with an
/// initial list of tasks and then pass it into provider overrides.
class FakeKanbanRepository implements KanbanBoardRepositories {
  final List<kanbanTaskEntity> _items;

  FakeKanbanRepository([List<kanbanTaskEntity> initial = const []]) : _items = List.from(initial);

  @override
  Future<void> addTask(kanbanTaskEntity task) async {
    _items.add(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    _items.removeWhere((t) => t.id == id);
  }

  @override
  Future<List<kanbanTaskEntity>> getTasks() async => List.from(_items);

  @override
  Stream<List<kanbanTaskEntity>> getTasksStream() async* {
    yield List.from(_items);
  }

  @override
  Future<List<kanbanTaskEntity>> getTasksOnce() async => List.from(_items);

  @override
  Future<void> updateTask(kanbanTaskEntity task) async {
    final idx = _items.indexWhere((t) => t.id == task.id);
    if (idx >= 0) _items[idx] = task;
  }
}
