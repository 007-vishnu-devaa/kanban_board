import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanbanboard/login/domain/model/user_entity.dart';
import 'package:kanbanboard/login/presentation/login_page.dart';
import 'package:kanbanboard/login/presentation/notifier/auth_notifier.dart';
import 'package:kanbanboard/login/presentation/provider/auth_provider.dart';
import 'package:kanbanboard/core/connectivity/connectivity_service.dart';
import 'package:kanbanboard/kanban_board/domain/model/kanban_repository.dart';
import 'package:kanbanboard/kanban_board/presentation/providers/task_provider.dart';
import 'package:kanbanboard/kanban_board/domain/model/task_entity.dart';
 

// Mock Notifier
class MockLoginNotifier extends StateNotifier<AsyncValue<UserEntity?>>
    implements LoginNotifier {
  MockLoginNotifier() : super(const AsyncData(null));

  bool loginCalled = false;
  bool signupCalled = false;

    @override
  Future<void> login(String email, String password) async {
    loginCalled = true;
    state = const AsyncLoading();
    await Future.delayed(const Duration(milliseconds: 300));
    state = AsyncData(UserEntity(
      uid: '1',
      email: email
    ));
  }
  @override
  Future<void> signUp(String email, String password) async {
    signupCalled = true;
    state = const AsyncLoading();
    await Future.delayed(const Duration(milliseconds: 300));
     state = AsyncData(UserEntity(
      uid: '2',
      email: email
    ));
  }
}

// Reuse InMemoryFirestore from test_utils

/// FakeTaskRepository implements the current `KanbanBoardRepositories`
/// interface and keeps tasks in a simple in-memory map so tests don't need
/// the real Firestore SDK.
class FakeTaskRepository implements KanbanBoardRepositories {
  final Map<String, Task> _store = {};

  FakeTaskRepository([List<Task> initial = const []]) {
    for (var t in initial) {
      final id = (t.id.isEmpty) ? 'id_${_store.length + 1}' : t.id;
      _store[id] = Task(id: id, title: t.title, description: t.description, status: t.status);
    }
  }

  @override
  Future<void> addTask(kanbanTaskEntity task) async {
    final id = task.id.isEmpty ? 'id_${_store.length + 1}' : task.id;
    _store[id] = Task(id: id, title: task.title, description: task.description, status: task.status);
  }

  @override
  Future<void> deleteTask(String id) async {
    _store.remove(id);
  }

  @override
  Future<List<kanbanTaskEntity>> getTasks() async {
    return _store.values.map((t) => kanbanTaskEntity(id: t.id, title: t.title, description: t.description, status: t.status)).toList();
  }

  @override
  Stream<List<kanbanTaskEntity>> getTasksStream() async* {
    yield await getTasks();
  }

  @override
  Future<void> updateTask(kanbanTaskEntity task) async {
    if (_store.containsKey(task.id)) {
      _store[task.id] = Task(id: task.id, title: task.title, description: task.description, status: task.status);
    } else {
      throw Exception('Task not found');
    }
  }

  @override
  Future<List<kanbanTaskEntity>> getTasksOnce() async {
    return getTasks();
  }
}

void main() {
  late MockLoginNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockLoginNotifier();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
  // Force connectivity to online to avoid network timers in tests
  connectivityStatusProvider.overrideWith((ref) => Stream.value(true)),
        loginControllerProvider.overrideWith((ref) => mockNotifier),
        // Ensure any task-related providers don't hit real Firestore
        taskRepositoryProvider.overrideWith((ref) => FakeTaskRepository()),
      ],
      child: const MaterialApp(
        home: LoginPage(),
      ),
    );
  }

  testWidgets('renders email and password fields', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('shows loading indicator when login is in progress', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Trigger login
    await tester.enterText(find.byType(TextField).first, 'test@email.com');
    await tester.enterText(find.byType(TextField).last, 'Test123@');
    await tester.tap(find.text('Sign In'));
    await tester.pump(); // Start async loading

    // Expect loading overlay
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Finish loading
    await tester.pumpAndSettle();
  });

  testWidgets('displays error toast when fields are empty', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    // Clear fields to simulate empty input
    await tester.enterText(find.byType(TextField).first, '');
    await tester.enterText(find.byType(TextField).last, '');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pump();

    // Since toast shows outside the widget tree, we can check that login not called
    expect(mockNotifier.loginCalled, false);
  });

  testWidgets('login button disabled when loading', (tester) async {
    mockNotifier.state = const AsyncLoading();
    await tester.pumpWidget(createWidgetUnderTest());

    final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Sign In'));
    expect(button.onPressed, isNull); // Disabled
  });

  testWidgets('signup button calls signUp method', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(TextField).first, 'vishnu123@gmail.com');
    await tester.enterText(find.byType(TextField).last, 'Vishnu123@');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Sign up'));
    await tester.pumpAndSettle();

    expect(mockNotifier.signupCalled, true);
  });
}
