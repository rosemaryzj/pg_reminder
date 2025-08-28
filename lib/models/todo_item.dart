enum Priority { low, medium, high, urgent }

enum TodoStatus { todo, inProgress, done, blocked }

class TodoItem {
  final String id;
  final String title;
  final String description;
  final Priority priority;
  final TodoStatus status;
  final String assignee;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<String> tags;

  TodoItem({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = Priority.medium,
    this.status = TodoStatus.todo,
    this.assignee = '',
    this.dueDate,
    DateTime? createdAt,
    this.completedAt,
    this.tags = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    Priority? priority,
    TodoStatus? status,
    String? assignee,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? completedAt,
    List<String>? tags,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignee: assignee ?? this.assignee,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'assignee': assignee,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'tags': tags,
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      priority: Priority.values.firstWhere((e) => e.name == json['priority']),
      status: TodoStatus.values.firstWhere((e) => e.name == json['status']),
      assignee: json['assignee'] ?? '',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
