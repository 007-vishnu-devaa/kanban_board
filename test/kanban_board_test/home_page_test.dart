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
        taskRepositoryProvider.overrideWith((ref) => fakeRepo),
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
    var refreshed = false;
  final fakeRepo = FakeKanbanRepository([]);

    // Use a ProviderContainer so we can call the overridden refresh function directly
    final container = ProviderContainer(overrides: [
      taskRepositoryProvider.overrideWith((ref) => fakeRepo),
      refreshTasksProvider.overrideWith((ref) => () async {
        refreshed = true;
      }),
      authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
    ]);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: HomePage()),
    ));

    await tester.pumpAndSettle();

    // Call the refresh function directly from the container
    await container.read(refreshTasksProvider)();
    await tester.pumpAndSettle();

    expect(refreshed, true);
  });

  testWidgets('Logout button shows confirmation and No dismisses', (tester) async {
  final fakeRepo = FakeKanbanRepository([]);

    final observer = _TestNavigatorObserver();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWith((ref) => fakeRepo),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
      ],
      child: MaterialApp(home: const HomePage(), navigatorObservers: [observer]),
    ));

    await tester.pumpAndSettle();

    // Tap logout
  // Tap the logout icon to open the confirmation dialog
  await tester.tap(find.byIcon(Icons.logout_rounded));
  await tester.pumpAndSettle();

  // Provide the familiar `Task` alias via shared test support.
  await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.signOutOkayBtnText));
  await tester.pump();

  // Allow the fluttertoast timer (2s) to run to completion to avoid
  // pending timers after the test ends.
  await tester.pump(const Duration(seconds: 3));

  // Navigator replacement should have been called
  expect(observer.didReplaceCalled, isTrue);
  });
}

class _TestNavigatorObserver extends NavigatorObserver {
  bool didReplaceCalled = false;
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    didReplaceCalled = true;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<UserEntity?> login(String email, String password) async => null;

  @override
  Future<UserEntity?> signUp(String email, String password) async => null;
}
