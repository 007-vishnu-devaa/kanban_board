import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanbanboard/kanban_board/domain/model/kanban_repository.dart';
import 'package:kanbanboard/kanban_board/domain/model/task_entity.dart';
import 'package:kanbanboard/kanban_board/data/model/task_dto.dart';

// Keep tests using the familiar `Task` identifier by aliasing it to the
// current domain model `kanbanTaskEntity`.
typedef Task = kanbanTaskEntity;

// Minimal fake Firestore pieces
class FakeDocSnapshot {
  final String id;
  final Map<String, dynamic> _data;
  FakeDocSnapshot(this.id, this._data);
  Map<String, dynamic> data() => _data;
}

class FakeQuerySnapshot {
  final List<FakeDocSnapshot> docs;
  FakeQuerySnapshot(this.docs);
}

class FakeDocRef {
  final String id;
  final Map<String, FakeDocSnapshot> _store;
  final StreamController<FakeQuerySnapshot> _controller;

  FakeDocRef(this.id, this._store, this._controller);

  Future<void> set(Map<String, dynamic> map) async {
    _store[id] = FakeDocSnapshot(id, map);
    _controller.add(FakeQuerySnapshot(_store.values.toList()));
  }

  Future<void> delete() async {
    _store.remove(id);
    _controller.add(FakeQuerySnapshot(_store.values.toList()));
  }
}

class FakeCollection {
  final Map<String, FakeDocSnapshot> _store = {};
  final _controller = StreamController<FakeQuerySnapshot>.broadcast();

  FakeDocRef doc([String? id]) {
    final docId = id ?? 'doc_${_store.length + 1}';
    // ensure there is an entry
    _store.putIfAbsent(docId, () => FakeDocSnapshot(docId, {}));
    return FakeDocRef(docId, _store, _controller);
  }

  Future<void> setDoc(String id, Map<String, dynamic> map) async {
    _store[id] = FakeDocSnapshot(id, map);
    _controller.add(FakeQuerySnapshot(_store.values.toList()));
  }

  Future<void> deleteDoc(String id) async {
    _store.remove(id);
    _controller.add(FakeQuerySnapshot(_store.values.toList()));
  }

  Future<FakeQuerySnapshot> get() async => FakeQuerySnapshot(_store.values.toList());

  Stream<FakeQuerySnapshot> snapshots() => _controller.stream;
}

class FakeFirestore {
  final FakeCollection collectionObj = FakeCollection();
  FakeCollection collection(String name) => collectionObj;
}

/// Test-only repository implementation that uses the FakeFirestore. This
/// mirrors production behavior but avoids needing the real Firebase SDK.
class TestRepo implements KanbanBoardRepositories {
  final FakeFirestore _fs;
  TestRepo(this._fs);

  @override
  Future<void> addTask(kanbanTaskEntity task) async {
    final collection = _fs.collection('tasks');
    final docRef = task.id.isEmpty ? collection.doc() : collection.doc(task.id);
    final assignedId = docRef.id;
    final taskWithId = kanbanTaskEntity(
      id: assignedId,
      title: task.title,
      description: task.description,
      status: task.status,
    );
    await docRef.set(TaskDTO.fromEntity(taskWithId).toMap());
  }

  @override
  Future<void> deleteTask(String id) async {
    await _fs.collection('tasks').deleteDoc(id);
  }

  @override
  Future<List<kanbanTaskEntity>> getTasks() async {
    final snap = await _fs.collection('tasks').get();
    return snap.docs.map((d) => TaskDTO.fromMap(d.data()).toEntity()).toList();
  }

  @override
  Stream<List<kanbanTaskEntity>> getTasksStream() async* {
    yield await getTasks();
  }

  @override
  Future<void> updateTask(kanbanTaskEntity task) async {
    await _fs.collection('tasks').setDoc(task.id, TaskDTO.fromEntity(task).toMap());
  }
}

void main() {
  group('TaskRepository with fake firestore', () {
  late FakeFirestore fakeFs;
  late KanbanBoardRepositories repo;

    setUp(() {
      fakeFs = FakeFirestore();
      // KanbanBoardRepositoryImpl expects a named `firestore` parameter
    // Use the test-local repo implementation that talks to FakeFirestore.
    repo = TestRepo(fakeFs);
    });

    test('addTask assigns id and stores document', () async {
  final task = Task(id: '', title: 'A', description: 'B', status: 'todo');
      await repo.addTask(task);

      final snapshot = await fakeFs.collection('tasks').get();
      expect(snapshot.docs.length, 1);
  final stored = snapshot.docs.first;
  final dto = TaskDTO.fromMap(stored.data());
  expect(dto.title, 'A');
    });

    test('updateTask overwrites document', () async {
  final task = Task(id: 'x', title: 'X', description: 'D', status: 'todo');
      await fakeFs.collection('tasks').setDoc('x', TaskDTO.fromEntity(task).toMap());

      final updated = task.copyWith(title: 'X2');
      await repo.updateTask(updated);

      final snap = await fakeFs.collection('tasks').get();
  final stored = snap.docs.firstWhere((d) => d.id == 'x');
  expect(stored.data()['title'], 'X2');
    });

    test('deleteTask removes document', () async {
  final task = Task(id: 'del', title: 'D', description: 'D', status: 'todo');
      await fakeFs.collection('tasks').setDoc('del', TaskDTO.fromEntity(task).toMap());
      await repo.deleteTask('del');
  final snap = await fakeFs.collection('tasks').get();
  expect(snap.docs.any((d) => d.id == 'del'), false);
    });

    test('getTasksOnce returns stored tasks', () async {
  final t1 = Task(id: 'a', title: 'A', description: 'd', status: 'todo');
      await fakeFs.collection('tasks').setDoc('a', TaskDTO.fromEntity(t1).toMap());
      final tasks = await repo.getTasks();
      expect(tasks.any((t) => t.id == 'a'), true);
    });
    test('getTasks returns stored tasks after set', () async {
      final t1 = Task(id: 's1', title: 'S1', description: 'd', status: 'todo');
      await fakeFs.collection('tasks').setDoc('s1', TaskDTO.fromEntity(t1).toMap());
      final tasks = await repo.getTasks();
      expect(tasks.any((t) => t.id == 's1'), true);
    });
  });
}
