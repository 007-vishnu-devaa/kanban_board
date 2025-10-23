import 'package:kanbanboard/kanban_board/domain/model/task_entity.dart';
import 'package:kanbanboard/kanban_board/domain/model/kanban_repository.dart';

// Keep tests using the familiar `Task` identifier by aliasing it to the
// current domain model `KanbanTaskEntity`.
typedef Task = KanbanTaskEntity;

/// A tiny in-memory fake repository implementing the production
/// `KanbanBoardRepositories` interface. Tests can construct it with an
/// initial list of tasks and then pass it into provider overrides.
class FakeKanbanRepository implements KanbanBoardRepositories {
  final List<KanbanTaskEntity> _items;

  FakeKanbanRepository([List<KanbanTaskEntity> initial = const []]) : _items = List.from(initial);

  @override
  Future<void> addTask(KanbanTaskEntity task) async {
    _items.add(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    _items.removeWhere((t) => t.id == id);
  }

  @override
  Future<List<KanbanTaskEntity>> getTasks() async => List.from(_items);

  @override
  Future<void> updateTask(KanbanTaskEntity task) async {
    final idx = _items.indexWhere((t) => t.id == task.id);
    if (idx >= 0) _items[idx] = task;
  }
}
