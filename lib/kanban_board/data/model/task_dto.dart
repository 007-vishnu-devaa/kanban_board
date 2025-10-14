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

  factory TaskDTO.fromEntity(kanbanTaskEntity task) {
    return TaskDTO(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
    );
  }

  kanbanTaskEntity toEntity() {
    return kanbanTaskEntity(
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

  factory TaskDTO.fromDocument(Object? doc) {
  Map<String, dynamic>? data;

  
  if (doc is DocumentSnapshot) {
    final rawData = doc.data();
    if (rawData == null) {
      throw ArgumentError('Document ${doc.id} has no data');
    }
    if (rawData is! Map<String, dynamic>) {
      throw ArgumentError('Document ${doc.id} contains invalid data type');
    }
    data = rawData;
  }

  else if (doc is Map<String, dynamic>) {
    data = doc;
  }


  else if (doc != null) {
    try {
      final dyn = doc as dynamic;
      final dynamic maybeData =
          (dyn.data is Function) ? dyn.data() : dyn.data;

      if (maybeData == null) {
        throw ArgumentError('Dynamic document returned null data');
      }
      if (maybeData is! Map<String, dynamic>) {
        throw ArgumentError('Dynamic document returned non-map data');
      }

      data = maybeData;
    } catch (e) {
      throw ArgumentError('Unsupported or invalid document type for TaskDTO.fromDocument: $e');
    }
  }
 
  else {
    throw ArgumentError('Document must not be null');
  }
  return TaskDTO.fromMap(data);
}

}
