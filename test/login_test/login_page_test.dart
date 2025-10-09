import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanbanboard/login/domain/model/user_entity.dart';
import 'package:kanbanboard/login/presentation/login_page.dart';
import 'package:kanbanboard/login/presentation/notifier/auth_notifier.dart';
import 'package:kanbanboard/login/presentation/provider/auth_provider.dart';
import 'package:kanbanboard/core/connectivity/connectivity_service.dart';
import 'package:kanbanboard/kanban_board/data/repositories_impl/task_repositories_impl.dart';
import 'package:kanbanboard/kanban_board/presentation/providers/task_provider.dart';
import 'package:kanbanboard/kanban_board/domain/model/task_entity.dart';
import '../kanban_board_test/home_page_test.dart';
import '../test_utils.dart';

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

/// FakeTaskRepository passes an in-memory firestore to the real TaskRepository
/// constructor to avoid touching the Firebase SDK during tests.
class FakeTaskRepository extends TaskRepository {
  final InMemoryFirestore _inMemory;
  final List<Task> initial;

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

  factory FakeTaskRepository([List<Task> initial = const []]) {
    final fs = createInMemoryFirestore();
    return FakeTaskRepository._(fs, initial);
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
