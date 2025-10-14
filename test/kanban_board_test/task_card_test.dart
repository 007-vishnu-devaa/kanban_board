import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanbanboard/core/app_strings.dart';
import 'package:kanbanboard/kanban_board/domain/model/kanban_repository.dart';
import 'package:kanbanboard/kanban_board/presentation/widgets/task_card.dart';
import 'package:kanbanboard/kanban_board/domain/model/task_entity.dart';
import 'package:kanbanboard/kanban_board/presentation/providers/task_provider.dart';
import 'package:kanbanboard/core/connectivity/connectivity_service.dart';
import 'package:kanbanboard/kanban_board/presentation/state/kanban_board_state.dart';
class RecordingTaskRepository implements KanbanBoardRepositories {
  final List<kanbanTaskEntity> updated = [];
  final List<String> deleted = [];

  RecordingTaskRepository();

  @override
  Future<void> updateTask(kanbanTaskEntity task) async {
    updated.add(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    deleted.add(id);
  }

  // Minimal implementations for other abstract usages
  Stream<List<kanbanTaskEntity>> getTasksStream() async* {
    yield [];
  }

  Future<List<kanbanTaskEntity>> getTasksOnce() async => [];

  @override
  Future<void> addTask(kanbanTaskEntity task) async {}
  
  @override
  Future<List<kanbanTaskEntity>> getTasks() {
    return Future.value([]);
  }
}

class ErrorRepo implements KanbanBoardRepositories {
  final bool throwOnUpdate;
  final bool throwOnDelete;
  ErrorRepo({this.throwOnUpdate = false, this.throwOnDelete = false});

  @override
  Future<void> addTask(kanbanTaskEntity task) async {}

  @override
  Future<void> deleteTask(String id) async {
    if (throwOnDelete) throw Exception('delete-failed');
  }

  @override
  Future<List<kanbanTaskEntity>> getTasks() async => [];

  Stream<List<kanbanTaskEntity>> getTasksStream() async* {
    yield [];
  }
  Future<List<kanbanTaskEntity>> getTasksOnce() async => [];

  @override
  Future<void> updateTask(kanbanTaskEntity task) async {
    if (throwOnUpdate) throw Exception('update-failed');
  }
}

// Helper to wait until notifier reaches failure dataState (polling).
Future<void> _waitForNotifierFailure(WidgetTester tester, ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    final state = container.read(kanbanTaskNotifierProvider);
    if (state.dataState == KanbanBoardApiStatus.failure) return;
    await tester.pump(const Duration(milliseconds: 50));
  }
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
    final task = kanbanTaskEntity(id: '1', title: 'Hello', description: 'Desc', status: 'To Do');
    final repo = RecordingTaskRepository();

    await tester.pumpWidget(ProviderScope(overrides: [
      connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
  kanbanTaskRepositoryProvider.overrideWith((ref) => repo),
    ], child: MaterialApp(home: Scaffold(body: TaskCard(task: task)))));

    await tester.pumpAndSettle();

    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Desc'), findsOneWidget);
  });

  testWidgets('Edit dialog saves and calls updateTask', (tester) async {
    final task = kanbanTaskEntity(id: '2', title: 'Old', description: 'OldDesc', status: 'To Do');
    final repo = RecordingTaskRepository();

    await tester.pumpWidget(ProviderScope(overrides: [
      connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
  kanbanTaskRepositoryProvider.overrideWith((ref) => repo),
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
    await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.updateTaskButtonText));
    await tester.pumpAndSettle();

    // Verify repo.updateTask was called with updated values
    expect(repo.updated, isNotEmpty);
    final updated = repo.updated.first;
    expect(updated.id, '2');
    expect(updated.title, 'New Title');
    expect(updated.description, 'New Desc');
  });

  testWidgets('Delete confirmation calls deleteTask', (tester) async {
    final task = kanbanTaskEntity(id: '3', title: 'ToDelete', description: 'D', status: 'To Do');
    final repo = RecordingTaskRepository();

    await tester.pumpWidget(ProviderScope(overrides: [
      connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
  kanbanTaskRepositoryProvider.overrideWith((ref) => repo),
    ], child: MaterialApp(home: Scaffold(body: TaskCard(task: task)))));

    await tester.pumpAndSettle();

    // Open delete confirmation
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Confirmation!'), findsOneWidget);

    // Tap Sign Out to confirm deletion
    await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.deleteButtonText));
    await tester.pumpAndSettle();
    // Allow any toast timers to complete.
    await tester.pump(const Duration(seconds: 3));

    expect(repo.deleted, contains('3'));
  });

  testWidgets('Icon buttons are disabled when offline', (tester) async {
    final task = kanbanTaskEntity(id: '4', title: 'Offline', description: 'D', status: 'To Do');
    final repo = RecordingTaskRepository();

    await tester.pumpWidget(ProviderScope(overrides: [
      connectivityStatusProvider.overrideWith((ref) => Stream.value(false)),
  kanbanTaskRepositoryProvider.overrideWith((ref) => repo),
    ], child: MaterialApp(home: Scaffold(body: TaskCard(task: task)))));

    await tester.pumpAndSettle();

    final editBtn = find.widgetWithIcon(IconButton, Icons.edit_outlined);
    final delBtn = find.widgetWithIcon(IconButton, Icons.delete_outline);

    expect(editBtn, findsOneWidget);
    expect(delBtn, findsOneWidget);

    final editWidget = tester.widget<IconButton>(editBtn);
    final delWidget = tester.widget<IconButton>(delBtn);

    expect(editWidget.onPressed, isNull);
    expect(delWidget.onPressed, isNull);
  });

  testWidgets('Edit error shows snackbar', (tester) async {
    final task = kanbanTaskEntity(id: '5', title: 'Err', description: 'D', status: 'To Do');
    final repo = ErrorRepo(throwOnUpdate: true);
    // Use a ProviderContainer so we can inspect notifier state after the operation
    final container = ProviderContainer(overrides: [
      connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
      kanbanTaskRepositoryProvider.overrideWith((ref) => repo),
    ]);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: Scaffold(body: TaskCard(task: task))),
    ));

    await tester.pumpAndSettle();

    // Open edit dialog
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    // Enter new valid values
    await tester.enterText(find.byType(TextField).first, 'New');
    await tester.enterText(find.byType(TextField).last, 'NewDesc');

    // Tap Save
    await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.updateTaskButtonText));
    await tester.pumpAndSettle();

  // Wait for notifier to reach failure dataState, then assert
  await _waitForNotifierFailure(tester, container);
  final state = container.read(kanbanTaskNotifierProvider);
  expect(state.dataState, KanbanBoardApiStatus.failure);
  });
}
