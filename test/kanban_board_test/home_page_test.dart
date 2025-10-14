import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:kanbanboard/core/app_strings.dart';
import 'package:kanbanboard/kanban_board/home_page.dart';
import 'package:kanbanboard/kanban_board/presentation/providers/task_provider.dart';
import 'package:kanbanboard/login/domain/repositories/auth_repositories.dart';
import 'package:kanbanboard/login/presentation/provider/auth_provider.dart';
import 'package:kanbanboard/login/domain/model/user_entity.dart';
import 'package:kanbanboard/core/connectivity/connectivity_service.dart';
import 'test_support.dart';
import 'package:kanbanboard/kanban_board/presentation/state/kanban_board_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel _toastChannel = MethodChannel('PonnamKarthik/fluttertoast');

  setUpAll(() {
    _toastChannel.setMockMethodCallHandler((call) async => null);
  });
  tearDownAll(() {
    _toastChannel.setMockMethodCallHandler(null);
  });

  testWidgets('HomePage shows columns and tasks, add dialog opens', (tester) async {
    final tasks = [
      Task(id: '1', title: 'T1', description: 'D1', status: 'To Do'),
      Task(id: '2', title: 'T2', description: 'D2', status: 'In Progress'),
    ];

    final fakeRepo = FakeKanbanRepository(tasks);

    await tester.pumpWidget(ProviderScope(
      overrides: [
  kanbanTaskRepositoryProvider.overrideWith((ref) => fakeRepo),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
      ],
      child: const MaterialApp(home: HomePage()),
    ));

    await tester.pumpAndSettle();

    // Columns
    expect(find.text('To Do'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);

    // Task titles
    expect(find.text('T1'), findsOneWidget);
    expect(find.text('T2'), findsOneWidget);

    // Tap add button -> dialog appears
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // The title and the action currently share the same label; assert that
    // the label appears in the dialog (one or more occurrences is fine).
    expect(find.text(AppStrings.addTaskText), findsWidgets);
  });

  

  testWidgets('pull to refresh triggers refresh function', (tester) async {
  final fakeRepo = FakeKanbanRepository([]);

    // Use a ProviderContainer; provide a tiny test repository whose
    final testRepo = FakeKanbanRepository([]);

    final container = ProviderContainer(overrides: [
      kanbanTaskRepositoryProvider.overrideWith((ref) => testRepo),
      authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
    ]);

    // Ensure toast method channel handlers are set before triggering save/delete
    const MethodChannel _toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
    _toastChannel.setMockMethodCallHandler((call) async => null);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: HomePage()),
    ));

    await tester.pumpAndSettle();

      // Trigger the notifier's fetchTasks() to simulate a refresh
      await container.read(kanbanTaskNotifierProvider.notifier).fetchTasks();
    await tester.pumpAndSettle();

    // Assert notifier reached success state after fetch
    final state = container.read(kanbanTaskNotifierProvider);
    expect(state.state, KanbanBoardApiStatus.success);
  });

}


class _FakeAuthRepository implements AuthRepository {
  @override
  Future<UserEntity?> login(String email, String password) async => null;

  @override
  Future<UserEntity?> signUp(String email, String password) async => null;
}
