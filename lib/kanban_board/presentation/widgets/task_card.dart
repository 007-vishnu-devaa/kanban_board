import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../domain/model/task_entity.dart';
import '../providers/task_provider.dart';
import '../../../core/connectivity/connectivity_service.dart';

class TaskCard extends ConsumerWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

void showEditTaskDialog(BuildContext context, WidgetRef ref, Task task) {
  final titleController = TextEditingController(text: task.title);
  final descController = TextEditingController(text: task.description);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: Text('Edit Task', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration:  InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration:  InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
              ),
              maxLines: 3,
            ),
          ],
        )),
        actions: [
          TextButton(
            style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 14), 
                  ),
            onPressed: () => Navigator.pop(context), // Close without saving
            child: const Text('Cancel')),
            SizedBox(width: 2),
          ElevatedButton(
             style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, 
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                      ),
            onPressed: () {
              final isOnline = ref.read(connectivityStatusProvider).asData?.value ?? true;
              if (!isOnline) {
                Fluttertoast.showToast(
                  msg: 'No internet connection. Cannot save changes.',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
                return;
              }

              ref.read(taskNotifierProvider.notifier).updateTask(
                    task.copyWith(
                      title: titleController.text,
                      description: descController.text
                    )
                  );
              Navigator.pop(context); 
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}


void showConfirmationDialog(BuildContext context, WidgetRef ref, Task task) {
  final title = task.title;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: const Text('Confirmation!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
  content:SizedBox(
  width: MediaQuery.of(context).size.width,
  child: Text('Are you sure you want to delete $title?')),
        actions: [
          TextButton(
            style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 14), 
                  ),
            onPressed: () => Navigator.pop(context), // Close without saving
            child: const Text('No')),
            SizedBox(width: 2),
          ElevatedButton(
             style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, 
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                      ),
            onPressed: () async {
              // Capture provider values and messenger now (avoid using ref/context after await)
              final repo = ref.read(taskRepositoryProvider);
              final notifier = ref.read(taskNotifierProvider.notifier);

              final isOnline = ref.read(connectivityStatusProvider).asData?.value ?? true;
              if (!isOnline) {
                Fluttertoast.showToast(
                  msg: 'No internet connection. Cannot delete task.',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
                return;
              }

              // Optimistically remove from local state
              notifier.removeTask(task.id);
              Navigator.pop(context);

              try {
                await repo.deleteTask(task.id);
                Fluttertoast.showToast(
                  msg: '${task.title} deleted successfully',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.teal,
                  textColor: Colors.white);
              } catch (e) {
                // Revert local deletion on error
                notifier.updateTask(task);
                 Fluttertoast.showToast(
                  msg: '${task.title} Failed to delete task: $e',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.teal,
                  textColor: Colors.white);
              }
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: Colors.grey.shade300)),
      color: Colors.white,
      child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(task.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                      IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () {
                    showEditTaskDialog(context, ref, task);
                  },
                ),
                 IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () {
                    showConfirmationDialog(context, ref, task);
                  },
                )
                    ],)
                     ]),
          Padding(
            padding:  const EdgeInsets.only(left: 8, bottom: 8, right: 8), 
          child: Text(task.description,
                textAlign: TextAlign.start,
                maxLines: 3, overflow: TextOverflow.ellipsis)),
          ],
        ));
  }
}