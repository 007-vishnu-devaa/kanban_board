import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanbanboard/kanban_board/presentation/widgets/task_card.dart';
import 'domain/model/task_entity.dart';
import 'presentation/providers/task_provider.dart';


class KanbanBoardPage extends ConsumerWidget {
  const KanbanBoardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskNotifierProvider);
    final columns = ['To Do', 'In Progress', 'Completed'];

    return Scaffold(
      appBar: AppBar(title: const Text('Kanban Board')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: columns.map((column) {
            final columnTasks = tasks.where((t) => t.status == column).toList();

            return Container(
              width: MediaQuery.of(context).size.width * 0.8, // make column wider
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DragTarget<Task>(
                onWillAccept: (data) => data != null && data.status != column,
                onAccept: (data) {
                  ref
                      .read(taskNotifierProvider.notifier)
                      .changeTaskStatus(data.id, column);
                },
                builder: (context, candidateData, rejectedData) {
                  return Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(column,
                      textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView(
                          children: columnTasks
                              .map(
                                (task) => Draggable<Task>(
                                  data: task,
                                  feedback: Material(
                                      elevation: 6, child: TaskCard(task: task)),
                                  childWhenDragging:
                                      Opacity(opacity: 0.5, child: TaskCard(task: task)),
                                  child: TaskCard(task: task),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
