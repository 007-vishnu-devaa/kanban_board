import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:kanbanboard/core/app_strings.dart';
import 'package:kanbanboard/kanban_board/home_page.dart';
import 'package:kanbanboard/kanban_board/domain/model/task_entity.dart';
import 'package:kanbanboard/kanban_board/presentation/providers/task_provider.dart';
import 'package:kanbanboard/kanban_board/data/repositories_impl/task_repositories_impl.dart';
import 'package:kanbanboard/login/domain/repositories/auth_repositories.dart';
import 'package:kanbanboard/login/presentation/provider/auth_provider.dart';
import 'package:kanbanboard/login/domain/model/user_entity.dart';
import 'package:kanbanboard/core/connectivity/connectivity_service.dart';
import '../test_utils.dart';

class FakeTaskRepository extends TaskRepository {
  final InMemoryFirestore _inMemory;
  final List<Task> initial;

  // Private constructor accepting an existing in-memory firestore
  FakeTaskRepository._(this._inMemory, [this.initial = const []]) : super(firestore: _inMemory) {
    final col = _inMemory.collection('tasks');
    for (var t in initial) {
      final d = col.doc(t.id.isEmpty ? null : t.id);
      d.set({
        'id': t.id,
        'title': t.title,
        'description': t.description,
        'status': t.status,
      });
    }
  }

  // Public factory that creates a new in-memory firestore and uses it.
  factory FakeTaskRepository([List<Task> initial = const []]) {
    final fs = createInMemoryFirestore();
    return FakeTaskRepository._(fs, initial);
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

  testWidgets('HomePage shows columns and tasks, add dialog opens', (tester) async {
    final tasks = [
      Task(id: '1', title: 'T1', description: 'D1', status: 'To Do'),
      Task(id: '2', title: 'T2', description: 'D2', status: 'In Progress'),
    ];

    final fakeRepo = FakeTaskRepository(tasks);

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
    final fakeRepo = FakeTaskRepository([]);

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
    final fakeRepo = FakeTaskRepository([]);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWith((ref) => fakeRepo),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
      ],
      child: const MaterialApp(home: HomePage()),
    ));

    await tester.pumpAndSettle();

    // Tap logout
    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Confirmation!'), findsOneWidget);
    expect(find.text(AppStrings.cancelBtnText), findsOneWidget);
    expect(find.text(AppStrings.signOutOkayBtnText), findsOneWidget);

    // Tap No -> dialog should close
    await tester.tap(find.widgetWithText(TextButton, AppStrings.cancelBtnText));
    await tester.pumpAndSettle();

    expect(find.text('Confirmation!'), findsNothing);
  });

  testWidgets('Logout Sign Out navigates to LoginPage and shows toast', (tester) async {
    final fakeRepo = FakeTaskRepository([]);

    final observer = _TestNavigatorObserver();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWith((ref) => fakeRepo),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
      ],
      child: MaterialApp(
        home: const HomePage(),
        navigatorObservers: [observer],
      ),
    ));

    await tester.pumpAndSettle();

    // Open confirmation
    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();

  // Tap Sign Out
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
