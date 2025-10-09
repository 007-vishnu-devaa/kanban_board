import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanbanboard/kanban_board/presentation/widgets/task_card.dart';
import 'package:kanbanboard/kanban_board/domain/model/task_entity.dart';
import 'package:kanbanboard/kanban_board/presentation/providers/task_provider.dart';
import 'package:kanbanboard/kanban_board/data/repositories_impl/task_repositories_impl.dart';
import '../test_utils.dart';
import 'package:kanbanboard/core/connectivity/connectivity_service.dart';

class RecordingTaskRepository extends TaskRepository {
  final List<Task> updated = [];
  final List<String> deleted = [];

  RecordingTaskRepository() : super(firestore: InMemoryFirestore());

  @override
  Future<void> updateTask(Task task) async {
    updated.add(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    deleted.add(id);
  }

  // Minimal implementations for other abstract usages
  @override
  Stream<List<Task>> getTasksStream() async* {
    yield [];
  }

  @override
  Future<List<Task>> getTasksOnce() async => [];

  @override
  Future<void> addTask(Task task) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel _toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
  setUpAll(() {
    _toastChannel.setMockMethodCallHandler((call) async => null);
  });
  tearDownAll(() {
    _toastChannel.setMockMethodCallHandler(null);
  });

  testWidgets('TaskCard shows title and description', (tester) async {
    final task = Task(id: '1', title: 'Hello', description: 'Desc', status: 'To Do');
    final repo = RecordingTaskRepository();

    await tester.pumpWidget(ProviderScope(overrides: [
      connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
      taskRepositoryProvider.overrideWith((ref) => repo),
    ], child: MaterialApp(home: Scaffold(body: TaskCard(task: task)))));

    await tester.pumpAndSettle();

    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Desc'), findsOneWidget);
  });

  testWidgets('Edit dialog saves and calls updateTask', (tester) async {
    final task = Task(id: '2', title: 'Old', description: 'OldDesc', status: 'To Do');
    final repo = RecordingTaskRepository();

    await tester.pumpWidget(ProviderScope(overrides: [
      connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
      taskRepositoryProvider.overrideWith((ref) => repo),
    ], child: MaterialApp(home: Scaffold(body: TaskCard(task: task)))));

    await tester.pumpAndSettle();

    // Open edit dialog
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Edit Task'), findsOneWidget);

    // Enter new title and description
    await tester.enterText(find.byType(TextField).first, 'New Title');
    await tester.enterText(find.byType(TextField).last, 'New Desc');

    // Tap Save
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();

    // Verify repo.updateTask was called with updated values
    expect(repo.updated, isNotEmpty);
    final updated = repo.updated.first;
    expect(updated.id, '2');
    expect(updated.title, 'New Title');
    expect(updated.description, 'New Desc');
  });

  testWidgets('Delete confirmation calls deleteTask', (tester) async {
    final task = Task(id: '3', title: 'ToDelete', description: 'D', status: 'To Do');
    final repo = RecordingTaskRepository();

    await tester.pumpWidget(ProviderScope(overrides: [
      connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
      taskRepositoryProvider.overrideWith((ref) => repo),
    ], child: MaterialApp(home: Scaffold(body: TaskCard(task: task)))));

    await tester.pumpAndSettle();

    // Open delete confirmation
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Confirmation!'), findsOneWidget);

    // Tap Yes to confirm deletion
    await tester.tap(find.widgetWithText(ElevatedButton, 'Yes'));
    await tester.pumpAndSettle();
    // Allow any toast timers to complete.
    await tester.pump(const Duration(seconds: 3));

    expect(repo.deleted, contains('3'));
  });
}
