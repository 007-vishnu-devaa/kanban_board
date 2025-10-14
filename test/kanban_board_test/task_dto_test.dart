import 'package:flutter_test/flutter_test.dart';
import 'package:kanbanboard/kanban_board/data/model/task_dto.dart';
import 'package:kanbanboard/kanban_board/domain/model/task_entity.dart';

// Keep tests using the familiar `Task` identifier by aliasing it to the
// current domain model `kanbanTaskEntity`.
typedef Task = kanbanTaskEntity;

class FakeDoc {
  final Map<String, dynamic> _data;
  FakeDoc(this._data);
  Map<String, dynamic> data() => _data;
}

void main() {
  group('TaskDTO', () {
    test('toMap and fromMap roundtrip preserves fields', () {
      final task = Task(id: '1', title: 'Test', description: 'Desc', status: 'todo');
      final dto = TaskDTO.fromEntity(task);
      final map = dto.toMap();

      final dto2 = TaskDTO.fromMap(map);
      expect(dto2.id, equals(task.id));
      expect(dto2.title, equals(task.title));
      expect(dto2.description, equals(task.description));
      expect(dto2.status, equals(task.status));
    });

    test('toEntity returns equivalent Task', () {
      final dto = TaskDTO(id: '2', title: 'T2', description: 'D2', status: 'doing');
      final task = dto.toEntity();
      expect(task.id, '2');
      expect(task.title, 'T2');
      expect(task.description, 'D2');
      expect(task.status, 'doing');
    });

    test('fromDocument uses DocumentSnapshot.data()', () {
      final map = {
        'id': '3',
        'title': 'FromDoc',
        'description': 'FromDocDesc',
        'status': 'done',
      };

  final mockDoc = FakeDoc(map);

  // TaskDTO.fromDocument expects a DocumentSnapshot, but only uses
  // .data(), so passing a dynamic object that exposes data() is fine
  // for tests.
  final dto = TaskDTO.fromDocument(mockDoc as dynamic);
      expect(dto.id, '3');
      expect(dto.title, 'FromDoc');
      expect(dto.description, 'FromDocDesc');
      expect(dto.status, 'done');
    });
  });

  group('Task entity', () {
    test('copyWith updates provided fields only', () {
      final task = Task(id: 'x', title: 'Old', description: 'OldDesc', status: 'todo');
      final updated = task.copyWith(title: 'New', status: 'doing');
      expect(updated.id, 'x');
      expect(updated.title, 'New');
      expect(updated.description, 'OldDesc');
      expect(updated.status, 'doing');
    });
  });
}
