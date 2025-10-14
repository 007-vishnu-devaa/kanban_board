import 'package:equatable/equatable.dart';
import '../../domain/model/task_entity.dart';

enum KanbanBoardApiStatus { initial, loading, success, failure }

class KanbanBoardState extends Equatable {
  final KanbanBoardApiStatus state;
  final KanbanBoardApiStatus dataState;
  final List<kanbanTaskEntity>? kanbanBoardData;
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
    List<kanbanTaskEntity>? kanbanBoardData,
    List<String>? kanbanBoardSections,
  }) {
    return KanbanBoardState(
      state: state ?? this.state,
      dataState: dataState ?? this.dataState,
      kanbanBoardData: kanbanBoardData ?? this.kanbanBoardData,
      kanbanBoardSections: ['To Do', 'In Progress', 'Completed']
    );
  }

  @override
  List<Object?> get props => [
        state,
        dataState,
        kanbanBoardData,
        kanbanBoardSections,
      ];
}
