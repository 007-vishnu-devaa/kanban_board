class KanbanTaskEntity {
  String id;
  String title;
  String description;
  String status;

  KanbanTaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
  });

  KanbanTaskEntity copyWith({
    String? title,
    String? description,
    String? status,
  }) {
    return KanbanTaskEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }
}
