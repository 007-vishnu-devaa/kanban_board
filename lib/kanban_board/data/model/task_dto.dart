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

  /// Accepts a [DocumentSnapshot] or a raw Map (or any object that exposes
  /// a `data()` method returning a Map). This makes the factory easier to
  /// use in tests where creating a real Firestore [DocumentSnapshot] is
  /// difficult.
  factory TaskDTO.fromDocument(Object? doc) {
    Map<String, dynamic> data;
    if (doc is DocumentSnapshot) {
      data = doc.data() as Map<String, dynamic>;
    } else if (doc is Map<String, dynamic>) {
      data = doc;
    } else if (doc != null) {
      // Try to call .data() dynamically (used by some test fakes).
      try {
        final dyn = doc as dynamic;
        // Some fakes expose a `data` getter, others a `data()` method. Try both.
        try {
          final maybe = dyn.data;
          if (maybe is Map<String, dynamic>) {
            data = maybe;
          } else if (maybe is Function) {
            data = maybe();
          } else {
            // Fallback to calling as a function
            data = dyn.data() as Map<String, dynamic>;
          }
        } catch (_) {
          // If accessing dyn.data threw, try calling as a method
          data = dyn.data() as Map<String, dynamic>;
        }
      } catch (e) {
        throw ArgumentError('Unsupported document type for TaskDTO.fromDocument');
      }
    } else {
      throw ArgumentError('doc must not be null');
    }

    return TaskDTO.fromMap(data);
  }
}
