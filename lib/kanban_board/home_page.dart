import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanbanboard/core/app_strings.dart';
import 'package:kanbanboard/core/widgets/confirmation_dialog.dart';
import 'package:kanbanboard/core/widgets/toast.dart';
import 'package:kanbanboard/kanban_board/presentation/state/kanban_board_state.dart';
import 'package:kanbanboard/kanban_board/presentation/widgets/task_card.dart';
import 'package:kanbanboard/login/presentation/login_page.dart';
import 'package:kanbanboard/core/auth_storage.dart';
import '../core/widgets/circular_indicator.dart';
import 'domain/model/task_entity.dart';
import 'presentation/providers/task_provider.dart';
import '../core/connectivity/connectivity_service.dart';


class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

 class _HomePageState extends ConsumerState<HomePage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(kanbanTaskNotifierProvider.notifier).fetchTasks();
    });
  }

void okayBtnFunc(BuildContext context){
  AuthStorage.clear();
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  FlutterToast(toastMsg: AppStrings.signOutMessageText).toast();
}
  @override
  Widget build(BuildContext context) {
    final kanbanBoardState = ref.watch(kanbanTaskNotifierProvider);
    ref.listen<String?>(firestoreErrorProvider, (prev, next) {
      if (next != null && next.isNotEmpty) {
        FlutterToast(toastMsg: 'Firestore error: $next').toast();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: SizedBox.shrink(),
        title: const Text(AppStrings.homePageTitleText),actions: [
        IconButton(onPressed: (){
         ConfirmationDialog().showConfirmationDialog(
           context: context,
           title: AppStrings.confirmationDialogTitleText,
           okayBtnText: AppStrings.signOutOkayBtnText,
           cancelBtnText: AppStrings.cancelBtnText,
           isCancelBtnVisible: true,
           contentMsg: AppStrings.signOutConfirmationText,
           onOkayBtnPressed: () => okayBtnFunc(context),
         );
        }, icon: Icon(Icons.logout_rounded, size: 22))
      ],),
      body: Consumer(
        builder: (context, ref, _) {
          final errorMsg = ref.watch(firestoreErrorProvider);

          Widget content = RefreshIndicator(
            onRefresh: () async {
              await ref.read(kanbanTaskNotifierProvider.notifier).fetchTasks();
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Row(
                children: (kanbanBoardState.kanbanBoardSections ?? []).map((column) {
                  final columnTasks = kanbanBoardState.kanbanBoardData?.where((t) => t.status == column).toList();

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
                    child: DragTarget<kanbanTaskEntity>(
                      onWillAccept: (data) => data != null && data.status != column,
                      onAccept: (data) {
                         final isOnline = ref.read(connectivityStatusProvider).asData?.value ?? true;
                        if (!isOnline) {
                          FlutterToast(toastMsg: AppStrings.noInternetConnection).toast();
                          return;
                        }
                        final notifier = ref.read(kanbanTaskNotifierProvider.notifier);
                        notifier.changeTaskStatus(data.id, column);
                        notifier.fetchTasks();
                      },
                      builder: (context, candidateData, rejectedData) {
                        final isColumnEmpty = columnTasks ?? [];
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
                              child: isColumnEmpty.isEmpty
                                  ? Center(
                                      child: Text(
                                        AppStrings.noDataAvailable,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    )
                                  : ListView(
                                      children: isColumnEmpty
                                          .map((task) => Draggable<kanbanTaskEntity>(
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

          switch (kanbanBoardState.state) {
            case KanbanBoardApiStatus.failure:
              return SizedBox(
                width: double.infinity,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(errorMsg ?? 'Something went wrong'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.read(kanbanTaskNotifierProvider.notifier).fetchTasks(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            case KanbanBoardApiStatus.loading:
              return Stack(
                children: [
                  content,
                 CircularIndicator().loading()
                ],
              );
            case KanbanBoardApiStatus.initial:
            case KanbanBoardApiStatus.success:
              return content;
          }
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
          final dialog = AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              title: const Text(AppStrings.addTaskText, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              content: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: titleController,
                        enabled: !isSubmitting,
                        decoration: InputDecoration(
                          labelText: AppStrings.taskTitleText,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
                        )),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      enabled: !isSubmitting,
                      decoration: InputDecoration(
                        labelText: AppStrings.taskDescriptionText,
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
                  child: const Text(AppStrings.cancelBtnText),
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
              if(titleController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {
                FlutterToast(toastMsg: AppStrings.titleAndDescriptionFieldValidation).toast();
              } else {
                          final title = titleController.text.trim();
                          final description = descriptionController.text.trim();

                          final isOnline = ref.read(connectivityStatusProvider).asData?.value ?? true;
                          if (!isOnline) {
                            FlutterToast(toastMsg: AppStrings.noInternetConnection).toast();
                            return;
                          }

                          final task = kanbanTaskEntity(id: '', title: title, description: description, status: 'To Do');
                          setState(() => isSubmitting = true);
                            try {
                            final notifier = ref.read(kanbanTaskNotifierProvider.notifier);
                              await notifier.addTask(task);
                              await notifier.fetchTasks();
                            if (Navigator.canPop(context)) Navigator.pop(context);
                          } catch (e) {
                            setState(() => isSubmitting = false);
                             FlutterToast(toastMsg: 'Failed to add task: $e').toast();
                          }
                        }},
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
                            Text(AppStrings.addTaskText),
                          ],
                        )
                      : const Text(AppStrings.addTaskText),
                ),
              ],
            );
          return dialog;
        });
      },
    );
  }
  
}
