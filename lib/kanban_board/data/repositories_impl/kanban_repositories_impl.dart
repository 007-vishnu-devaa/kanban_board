import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/model/task_dto.dart';
import '../../domain/model/kanban_repository.dart';
import '../../domain/model/task_entity.dart';

class KanbanBoardRepositoryImpl extends KanbanBoardRepositories {
  final FirebaseFirestore firestore;
  KanbanBoardRepositoryImpl({required this.firestore});

  @override
  Future<List<kanbanTaskEntity>> getTasks() async {
    try {
      final snapshot = await firestore.collection('tasks').get();
      return snapshot.docs
          .map((doc) => TaskDTO.fromDocument(doc).toEntity())
          .toList()
          .cast<kanbanTaskEntity>();
    } on Exception catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }
  
@override
  Future<void> addTask(kanbanTaskEntity task) async {
    try {
      final collection = firestore.collection('tasks');
      final docRef = (task.id.isEmpty) ? collection.doc() : collection.doc(task.id);
      final assignedId = docRef.id;
      final taskWithId = kanbanTaskEntity(
        id: assignedId,
        title: task.title,
        description: task.description,
        status: task.status,
      );
      final dto = TaskDTO.fromEntity(taskWithId);
      await docRef.set(dto.toMap());
    } on Exception catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      final docRef = firestore.collection('tasks').doc(id);
      await docRef.delete();
    } on Exception catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

   @override
  Future<void> updateTask(kanbanTaskEntity task) async {
    try {
      final docRef = firestore.collection('tasks').doc(task.id);
      final dto = TaskDTO.fromEntity(task);
      await docRef.set(dto.toMap());
    } on Exception catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }
}
