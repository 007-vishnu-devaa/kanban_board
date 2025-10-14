class kanbanTaskEntity {
  String id;
  String title;
  String description;
  String status;

  kanbanTaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
  });

  kanbanTaskEntity copyWith({
    String? title,
    String? description,
    String? status,
  }) {
    return kanbanTaskEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }
}
