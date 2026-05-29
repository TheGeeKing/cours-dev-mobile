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
  final DateTime? reminderAt;

  const Todo({
    this.id,
    required this.title,
    this.completed = false,
    this.subTasks = const [],
    this.reminderAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json['_id'] as String?,
        title: json['title'] as String,
        completed: json['completed'] as bool? ?? false,
        subTasks: (json['subTasks'] as List<dynamic>?)
                ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        reminderAt: _parseReminderAt(json['reminderAt']),
      );

  /// Excludes _id because the API manages document identifiers separately.
  Map<String, dynamic> toJson() => {
        'title': title,
        'completed': completed,
        'subTasks': subTasks.map((e) => e.toJson()).toList(),
        if (reminderAt != null) 'reminderAt': reminderAt!.toIso8601String(),
      };

  Todo copyWith({
    String? id,
    String? title,
    bool? completed,
    List<SubTask>? subTasks,
    DateTime? reminderAt,
    bool clearReminder = false,
  }) =>
      Todo(
        id: id ?? this.id,
        title: title ?? this.title,
        completed: completed ?? this.completed,
        subTasks: subTasks ?? this.subTasks,
        reminderAt: clearReminder ? null : reminderAt ?? this.reminderAt,
      );
}

DateTime? _parseReminderAt(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}
