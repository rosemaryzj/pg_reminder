import 'middleware.dart';
import 'environment.dart';
import 'todo_item.dart';

enum ModuleStatus {
  planning,
  development,
  testing,
  deployment,
  completed,
  paused,
}

class Module {
  final String id;
  final String name;
  final String description;
  final ModuleStatus status;
  final double progress; // 0.0 to 1.0
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? deadline;
  final List<String> teamMembers;
  final List<Middleware> middlewares;
  final List<Environment> environments;
  final List<TodoItem> todos;
  final int severeBugs;
  final int generalBugs;
  final int minorBugs;
  final int testCaseCount;
  final int passedTestCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Module({
    required this.id,
    required this.name,
    this.description = '',
    this.status = ModuleStatus.planning,
    this.progress = 0.0,
    DateTime? startDate,
    this.endDate,
    this.deadline,
    this.teamMembers = const [],
    this.middlewares = const [],
    this.environments = const [],
    this.todos = const [],
    this.severeBugs = 0,
    this.generalBugs = 0,
    this.minorBugs = 0,
    this.testCaseCount = 0,
    this.passedTestCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : startDate = startDate ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Module copyWith({
    String? id,
    String? name,
    String? description,
    ModuleStatus? status,
    double? progress,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? deadline,
    List<String>? teamMembers,
    List<Middleware>? middlewares,
    List<Environment>? environments,
    List<TodoItem>? todos,
    int? severeBugs,
    int? generalBugs,
    int? minorBugs,
    int? testCaseCount,
    int? passedTestCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Module(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      deadline: deadline ?? this.deadline,
      teamMembers: teamMembers ?? this.teamMembers,
      middlewares: middlewares ?? this.middlewares,
      environments: environments ?? this.environments,
      todos: todos ?? this.todos,
      severeBugs: severeBugs ?? this.severeBugs,
      generalBugs: generalBugs ?? this.generalBugs,
      minorBugs: minorBugs ?? this.minorBugs,
      testCaseCount: testCaseCount ?? this.testCaseCount,
      passedTestCount: passedTestCount ?? this.passedTestCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // 计算测试覆盖率
  double get testCoverage {
    if (testCaseCount == 0) return 0.0;
    return passedTestCount / testCaseCount;
  }

  // 获取总Bug数
  int get totalBugs {
    return severeBugs + generalBugs + minorBugs;
  }

  // 获取待办事项统计
  Map<TodoStatus, int> get todoStats {
    final stats = <TodoStatus, int>{};
    for (final status in TodoStatus.values) {
      stats[status] = todos.where((todo) => todo.status == status).length;
    }
    return stats;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'progress': progress,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'teamMembers': teamMembers,
      'middlewares': middlewares.map((m) => m.toJson()).toList(),
      'environments': environments.map((e) => e.toJson()).toList(),
      'todos': todos.map((t) => t.toJson()).toList(),
      'severeBugs': severeBugs,
      'generalBugs': generalBugs,
      'minorBugs': minorBugs,
      'testCaseCount': testCaseCount,
      'passedTestCount': passedTestCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      status: ModuleStatus.values.firstWhere((e) => e.name == json['status']),
      progress: json['progress']?.toDouble() ?? 0.0,
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      teamMembers: List<String>.from(json['teamMembers'] ?? []),
      middlewares:
          (json['middlewares'] as List?)
              ?.map((m) => Middleware.fromJson(m))
              .toList() ??
          [],
      environments:
          (json['environments'] as List?)
              ?.map((e) => Environment.fromJson(e))
              .toList() ??
          [],
      todos:
          (json['todos'] as List?)?.map((t) => TodoItem.fromJson(t)).toList() ??
          [],
      severeBugs: json['severeBugs'] ?? 0,
      generalBugs: json['generalBugs'] ?? 0,
      minorBugs: json['minorBugs'] ?? 0,
      testCaseCount: json['testCaseCount'] ?? 0,
      passedTestCount: json['passedTestCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
