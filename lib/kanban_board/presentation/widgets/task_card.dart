import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanbanboard/core/widgets/toast.dart';
import '../../../core/app_strings.dart';
import '../../domain/model/task_entity.dart';
import '../providers/task_provider.dart';
import '../../../core/connectivity/connectivity_service.dart';

class TaskCard extends ConsumerWidget {
  final kanbanTaskEntity task;
  const TaskCard({super.key, required this.task});

  void showEditTaskDialog(BuildContext context, WidgetRef ref, kanbanTaskEntity task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);

    showDialog(
      context: context,
      builder: (context) {
        var isSubmitting = false;
        return StatefulBuilder(builder: (context, setState) {
          final dialog = AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            title: Text(AppStrings.editTaskText, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      labelText: AppStrings.taskTitleText,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      labelText: AppStrings.taskDescriptionText,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.teal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: const Text(AppStrings.cancelBtnText),
              ),
              const SizedBox(width: 2),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (titleController.text.trim().isEmpty || descController.text.trim().isEmpty) {
                          FlutterToast(toastMsg:AppStrings.titleAndDescriptionFieldValidation).toast();
                          return;
                        }

                        final isOnline = ref.read(connectivityStatusProvider).asData?.value ?? true;
                        if (!isOnline) {
                          FlutterToast(toastMsg: AppStrings.noInternetConnection).toast();
                          return;
                        }

                        final updated = task.copyWith(title: titleController.text, description: descController.text);

                        setState(() => isSubmitting = true);
                        try {
                          final notifier = ref.read(kanbanTaskNotifierProvider.notifier);
                           await notifier.updateTask(updated);
                           await notifier.fetchTasks();
                          if (Navigator.canPop(context)) Navigator.pop(context);
                        } catch (e) {
                          setState(() => isSubmitting = false);
                          FlutterToast(toastMsg: 'Failed to update task: $e').toast();
                        }
                      },
                child: isSubmitting
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(AppStrings.updateTaskButtonText),
                        ],
                      )
                    : const Text(AppStrings.updateTaskButtonText),
              ),
            ],
          );
          return dialog;
        });
      },
    );
  }


void showConfirmationDialog(BuildContext context, WidgetRef ref, kanbanTaskEntity task) {
  final title = task.title;

  showDialog(
    context: context,
    builder: (context) {
      var isSubmitting = false;
      return StatefulBuilder(builder: (context, setState) {
        final dialog = AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          title: const Text(AppStrings.confirmationDialogTitleText, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Text('Are you sure you want to delete $title?'),
          ),
          actions: [
            TextButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.teal),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text(AppStrings.cancelBtnText),
            ),
            const SizedBox(width: 2),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 22),
              ),
        onPressed: isSubmitting
                  ? null
                  : () async {
                      final isOnline = ref.read(connectivityStatusProvider).asData?.value ?? true;
                      if (!isOnline) {
                        FlutterToast(toastMsg: AppStrings.noInternetConnection).toast();
                        return;
                      }
                      try {
                       setState(() => isSubmitting = true);
                       final notifier = ref.read(kanbanTaskNotifierProvider.notifier);
                        await notifier.deleteTask(task.id);
                        await notifier.fetchTasks();
                        if (Navigator.canPop(context)) Navigator.pop(context);
                        FlutterToast(toastMsg: '${task.title} deleted successfully').toast();
                      } catch (e) {
                       
                        setState(() => isSubmitting = false);
                        FlutterToast(toastMsg: '${task.title} Failed to delete task: $e').toast();
                      }
                    },
              child: isSubmitting
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(AppStrings.deleteButtonText),
                        ],
                      )
                    : const Text(AppStrings.deleteButtonText),
            ),
          ],
        );
          return dialog;
      });
    },
  );
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityStatusProvider);
    final isOnline = connectivity.asData?.value ?? true;
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
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: isOnline ? () => showEditTaskDialog(context, ref, task) : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: isOnline ? () => showConfirmationDialog(context, ref, task) : null,
                      ),
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