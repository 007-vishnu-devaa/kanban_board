import '../../domain/model/task_entity.dart';

enum KanbanBoardApiStatus { initial, loading, success, failure }

class KanbanBoardState {
  final KanbanBoardApiStatus state;
  final KanbanBoardApiStatus dataState;
  final List<KanbanTaskEntity>? kanbanBoardData;
  final List<String>? kanbanBoardSections;


  const KanbanBoardState({
    this.state = KanbanBoardApiStatus.initial,
    this.dataState = KanbanBoardApiStatus.initial,
    this.kanbanBoardData,
    this.kanbanBoardSections,

  });

  const KanbanBoardState.initial({
    this.state = KanbanBoardApiStatus.initial,
    this.dataState = KanbanBoardApiStatus.initial,
    this.kanbanBoardData,
    this.kanbanBoardSections,

  });

  KanbanBoardState copyWith({
    KanbanBoardApiStatus? state,
    KanbanBoardApiStatus? dataState,
    List<KanbanTaskEntity>? kanbanBoardData,
    List<String>? kanbanBoardSections,
  }) {
    return KanbanBoardState(
      state: state ?? this.state,
      dataState: dataState ?? this.dataState,
      kanbanBoardData: kanbanBoardData ?? this.kanbanBoardData,
      kanbanBoardSections: ['To Do', 'In Progress', 'Completed']
    );
  }
}
