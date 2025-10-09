import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kanbanboard/kanban_board/presentation/widgets/task_card.dart';
import 'package:kanbanboard/login/presentation/login_page.dart';
import 'domain/model/task_entity.dart';
import 'presentation/providers/task_provider.dart';
import '../../core/connectivity/connectivity_service.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

void showConfirmationDialog(BuildContext context) {

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: const Text('Confirmation!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
  content:SizedBox(
  width: MediaQuery.of(context).size.width,
  child: Text('Are you sure you want to Sign out ?')),
        actions: [
          TextButton(
            style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 14), 
                  ),
            onPressed: () => Navigator.pop(context),
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
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              Fluttertoast.showToast(
                  msg: "Signed out successfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.teal,
                  textColor: Colors.white,
                );
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
          showConfirmationDialog(context);
        }, icon: Icon(Icons.logout_outlined))
      ],),
      body: Consumer(
        builder: (context, ref, _) {
          final isLoading = ref.watch(tasksLoadingProvider);
          final refresh = ref.read(refreshTasksProvider);

          return RefreshIndicator(
            onRefresh: refresh,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Row(
                children: columns.map((column) {
                  final columnTasks = tasks.where((t) => t.status == column).toList();

                  return Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.8,
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
                        ref.read(taskNotifierProvider.notifier).changeTaskStatus(data.id, column);
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Column(
                          children: [
                            if (isLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              const SizedBox(height: 4),
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
                              child: ListView(
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
          );
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
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          title: const Text('Add Task', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
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
              )),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 2),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, 
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 14), 
                      ),
              onPressed: () async {
                final title = titleController.text.trim();
                final description = descriptionController.text.trim();
                if (title.isEmpty) return;

                // Check connectivity before attempting to add
                final isOnline = ref.read(connectivityStatusProvider).asData?.value ?? true;
                if (!isOnline) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No internet connection. Cannot add task.')));
                  return;
                }

                // Create task with empty id and let repository assign id
                final task = Task(
                  id: '',
                  title: title,
                  description: description,
                  status: 'To Do',
                );

                // Save via repository (repo will generate id if needed)
                await ref.read(taskRepositoryProvider).addTask(task);

                // Optional: update local Riverpod state (repository stream will update state)
                // ref.read(taskNotifierProvider.notifier).updateTask(task);

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
