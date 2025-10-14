import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kanbanboard/kanban_board/presentation/state/kanban_board_state.dart';
import '../../data/repositories_impl/kanban_repositories_impl.dart';
import '../../domain/model/kanban_repository.dart';
import '../notifier/task_notifier.dart';

final kanbanTaskRepositoryProvider = Provider<KanbanBoardRepositories>((ref) => KanbanBoardRepositoryImpl());
final firestoreErrorProvider = StateProvider<String?>((ref) => null);
final kanbanTaskNotifierProvider = StateNotifierProvider<KanbanTaskNotifier, KanbanBoardState>((ref) {
 final repository = ref.read(kanbanTaskRepositoryProvider);
  return KanbanTaskNotifier(repository);
});
