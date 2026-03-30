class SubTask {
  final String id;
  final String title;
  final bool completed;

  const SubTask({
    required this.id,
    required this.title,
    this.completed = false,
  });

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
        id: json['id'] as String,
        title: json['title'] as String,
        completed: json['completed'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'completed': completed,
      };

  SubTask copyWith({String? id, String? title, bool? completed}) => SubTask(
        id: id ?? this.id,
        title: title ?? this.title,
        completed: completed ?? this.completed,
      );
}

class Todo {
  final String? id;
  final String title;
  final bool completed;
  final List<SubTask> subTasks;

  const Todo({
    this.id,
    required this.title,
    this.completed = false,
    this.subTasks = const [],
  });

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json['_id'] as String?,
        title: json['title'] as String,
        completed: json['completed'] as bool? ?? false,
        subTasks: (json['subTasks'] as List<dynamic>?)
                ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  /// Excludes _id — crudcrud rejects it in PUT/POST bodies.
  Map<String, dynamic> toJson() => {
        'title': title,
        'completed': completed,
        'subTasks': subTasks.map((e) => e.toJson()).toList(),
      };

  Todo copyWith({
    String? id,
    String? title,
    bool? completed,
    List<SubTask>? subTasks,
  }) =>
      Todo(
        id: id ?? this.id,
        title: title ?? this.title,
        completed: completed ?? this.completed,
        subTasks: subTasks ?? this.subTasks,
      );
}
