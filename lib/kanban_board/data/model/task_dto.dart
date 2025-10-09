import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/model/task_entity.dart';

class TaskDTO {
  final String id;
  final String title;
  final String description;
  final String status;

  TaskDTO({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
  });

  factory TaskDTO.fromEntity(Task task) {
    return TaskDTO(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
    );
  }

  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      status: status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
    };
  }

  factory TaskDTO.fromMap(Map<String, dynamic> map) {
    return TaskDTO(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
    );
  }

  factory TaskDTO.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskDTO.fromMap(data);
  }
}
