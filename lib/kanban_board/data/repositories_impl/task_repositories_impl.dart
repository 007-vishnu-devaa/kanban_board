import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/model/task_dto.dart';
import '../../domain/model/task_entity.dart';

class TaskRepository {
  // Use a getter so `FirebaseFirestore.instance` is accessed lazily.
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<void> addTask(Task task) async {
    try {
      final collection = _firestore.collection('tasks');
      final docRef = (task.id.isEmpty) ? collection.doc() : collection.doc(task.id);
      final assignedId = docRef.id;
      final taskWithId = Task(
        id: assignedId,
        title: task.title,
        description: task.description,
        status: task.status,
      );
      final dto = TaskDTO.fromEntity(taskWithId);
      await docRef.set(dto.toMap());
    } on Exception catch (e) {
      // Re-throw as a generic exception with message for UI handling
      throw Exception('Failed to add task: $e');
    }
  }

  /// Deletes a task document by [id]. Throws an exception on failure.
  Future<void> deleteTask(String id) async {
    try {
      final docRef = _firestore.collection('tasks').doc(id);
      await docRef.delete();
    } on Exception catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  /// Update an existing task document by overwriting the data.
  Future<void> updateTask(Task task) async {
    try {
      final docRef = _firestore.collection('tasks').doc(task.id);
      final dto = TaskDTO.fromEntity(task);
      await docRef.set(dto.toMap());
    } on Exception catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  /// Fetch tasks once (useful for pull-to-refresh).
  Future<List<Task>> getTasksOnce() async {
    try {
      final snapshot = await _firestore.collection('tasks').get();
      return snapshot.docs.map((doc) => TaskDTO.fromDocument(doc).toEntity()).toList();
    } on Exception catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  Stream<List<Task>> getTasksStream() {
    try {
      return _firestore.collection('tasks').snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => TaskDTO.fromDocument(doc).toEntity())
            .toList();
      }).handleError((error) {
        // Let callers handle the error; also log for debugging
        // debugPrint('getTasksStream error: $error');
      });
    } catch (e) {
      // If accessing instance threw synchronously, return an empty stream with an error.
      return Stream.error(e);
    }
  }
}
