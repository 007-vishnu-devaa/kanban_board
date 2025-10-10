import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanbanboard/core/widgets/confirmation_dialog.dart';
import 'package:kanbanboard/core/widgets/toast.dart';
import 'package:kanbanboard/kanban_board/presentation/widgets/task_card.dart';
import 'package:kanbanboard/login/presentation/login_page.dart';
import 'package:kanbanboard/core/auth_storage.dart';
import '../core/widgets/circular_indicator.dart';
import 'domain/model/task_entity.dart';
import 'presentation/providers/task_provider.dart';
import '../../core/connectivity/connectivity_service.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

void okayBtnFunc(BuildContext context){
  AuthStorage.clear();
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  FlutterToast(toastMsg: "Signed out successfully").toast();
}
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskNotifierProvider);
    ref.listen<String?>(firestoreErrorProvider, (prev, next) {
      if (next != null && next.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Firestore error: $next')));
      }
    });

    final columns = ['To Do', 'In Progress', 'Completed'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: SizedBox.shrink(),
        title: const Text('Kanban Board'),actions: [
        IconButton(onPressed: (){
         ConfirmationDialog().showConfirmationDialog(context: context, title: 'Confirmation!', okayBtnText: 'Yes', cancelBtnText: 'No', isCancelBtnVisible: true, contentMsg: 'Are you sure you want to Sign out ?',
          onOkayBtnPressed: () => okayBtnFunc(context));
        }, icon: Icon(Icons.logout_rounded, size: 22))
      ],),
      body: Consumer(
        builder: (context, ref, _) {
          final isLoading = ref.watch(tasksLoadingProvider);
          final refresh = ref.read(refreshTasksProvider);

          return Stack(
            children: [
               RefreshIndicator(
            onRefresh: refresh,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Row(
                children: columns.map((column) {
                  final columnTasks = tasks.where((t) => t.status == column).toList();

                  return Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.85,
                    margin: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Color(0xfff1f6f8),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))
                    ),
                    child: DragTarget<Task>(
                      onWillAccept: (data) => data != null && data.status != column,
                      onAccept: (data) {
                         final isOnline = ref.read(connectivityStatusProvider).asData?.value ?? true;
                        if (!isOnline) {
                          FlutterToast(toastMsg: 'No internet connection.').toast();
                          return;
                        }
                     
                          final repo = ref.read(taskRepositoryProvider);
                          final notifier = ref.read(taskNotifierProvider.notifier);
                          final loadingNotifier = ref.read(tasksLoadingProvider.notifier);
                          final oldStatus = data.status;
                          
                          notifier.changeTaskStatus(data.id, column);
                          loadingNotifier.state = true;

                         
                          () async {
                            try {
                              await repo.updateTask(data.copyWith(status: column));
                            } catch (e) {
                              notifier.changeTaskStatus(data.id, oldStatus);
                              FlutterToast(toastMsg: '${data.title} Failed to move task due to: $e').toast();
                            } finally {
                              loadingNotifier.state = false;
                            }
                          }();
                        },
                      builder: (context, candidateData, rejectedData) {
                        return Column(
                          children: [
                            SizedBox(height: 12),
                            Text(
                              column,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: columnTasks.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No Data Available',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    )
                                  : ListView(
                                      children: columnTasks
                                          .map((task) => Draggable<Task>(
                                                data: task,
                                                feedback: Material(
                                                  elevation: 6,
                                                  child: TaskCard(task: task),
                                                ),
                                                childWhenDragging: Opacity(
                                                  opacity: 0.5,
                                                  child: TaskCard(task: task),
                                                ),
                                                child: TaskCard(task: task),
                                              ))
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
          ),
           if (isLoading)
                 Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: CircularIndicator().loading(),
                ),
            ],
          ) ;
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _showAddTaskDialog(context, ref),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        var isSubmitting = false;

        return StatefulBuilder(builder: (context, setState) {
          return Stack(children: [
            AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            title: const Text('Add Task', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: titleController,
                      enabled: !isSubmitting,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
                      )),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
                    ),
                    maxLines: 3,
                  ),
                ])),
                 
            actions: [
              TextButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.teal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 2),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final title = titleController.text.trim();
                        final description = descriptionController.text.trim();

                        if (title.isEmpty) return;

                        // Check connectivity before attempting to add
                        final isOnline = ref.read(connectivityStatusProvider).asData?.value ?? true;
                        if (!isOnline) {
                          FlutterToast(toastMsg: 'No internet connection. Cannot add task.').toast();
                          return;
                        }
                        final repo = ref.read(taskRepositoryProvider);

                        // Create task with empty id and let repository assign id
                        final task = Task(id: '', title: title, description: description, status: 'To Do');

                        setState(() => isSubmitting = true);
                        try {
                          await repo.addTask(task);
                          // Close dialog on success
                          if (Navigator.canPop(context)) Navigator.pop(context);
                        } catch (e) {
                          // Keep dialog open and re-enable inputs
                          setState(() => isSubmitting = false);
                           FlutterToast(toastMsg: 'Failed to add task: $e').toast();
                        }
                      },
                child:  const Text('Save'),
              ),
            ],
          ),
          if (isSubmitting)
                  Positioned.fill(
                    child: CircularIndicator().loading(),
                  )
          ],);
        });
      },
    );
  }
}
