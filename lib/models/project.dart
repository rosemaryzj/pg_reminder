import 'module.dart';
import 'todo_item.dart';

enum ProjectStatus { planning, active, onHold, completed, cancelled }

class Project {
  final String id;
  final String name;
  final String description;
  final ProjectStatus status;
  final String owner;
  final List<String> teamMembers;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime deadline;
  final List<Module> modules;
  final List<TodoItem> todos;
  final String repositoryUrl;
  final Map<String, String> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    this.description = '',
    this.status = ProjectStatus.planning,
    required this.owner,
    this.teamMembers = const [],
    DateTime? startDate,
    this.endDate,
    required this.deadline,
    this.modules = const [],
    this.todos = const [],
    this.repositoryUrl = '',
    this.metadata = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : startDate = startDate ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Project copyWith({
    String? id,
    String? name,
    String? description,
    ProjectStatus? status,
    String? owner,
    List<String>? teamMembers,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? deadline,
    List<Module>? modules,
    List<TodoItem>? todos,
    String? repositoryUrl,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      owner: owner ?? this.owner,
      teamMembers: teamMembers ?? this.teamMembers,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      deadline: deadline ?? this.deadline,
      modules: modules ?? this.modules,
      todos: todos ?? this.todos,
      repositoryUrl: repositoryUrl ?? this.repositoryUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // 计算项目整体进度
  double get overallProgress {
    if (modules.isEmpty) return 0.0;
    return modules.fold(0.0, (sum, module) => sum + module.progress) /
        modules.length;
  }

  // 获取项目总Bug数
  int get totalBugs {
    return modules.fold(0, (sum, module) => sum + module.totalBugs);
  }

  // 获取项目测试覆盖率
  double get overallTestCoverage {
    final totalTests = modules.fold(
      0,
      (sum, module) => sum + module.testCaseCount,
    );
    if (totalTests == 0) return 0.0;
    final passedTests = modules.fold(
      0,
      (sum, module) => sum + module.passedTestCount,
    );
    return passedTests / totalTests;
  }

  // 获取模块状态统计
  Map<ModuleStatus, int> get moduleStatusStats {
    final stats = <ModuleStatus, int>{};
    for (final status in ModuleStatus.values) {
      stats[status] = modules.where((module) => module.status == status).length;
    }
    return stats;
  }

  // 获取待办事项统计
  Map<TodoStatus, int> get todoStats {
    final stats = <TodoStatus, int>{};
    for (final status in TodoStatus.values) {
      final projectTodos = todos.where((todo) => todo.status == status).length;
      final moduleTodos = modules.fold(
        0,
        (sum, module) =>
            sum + module.todos.where((todo) => todo.status == status).length,
      );
      stats[status] = projectTodos + moduleTodos;
    }
    return stats;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'owner': owner,
      'teamMembers': teamMembers,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'modules': modules.map((m) => m.toJson()).toList(),
      'todos': todos.map((t) => t.toJson()).toList(),
      'repositoryUrl': repositoryUrl,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      status: ProjectStatus.values.firstWhere((e) => e.name == json['status']),
      owner: json['owner'],
      teamMembers: List<String>.from(json['teamMembers'] ?? []),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      deadline: DateTime.parse(json['deadline']),
      modules:
          (json['modules'] as List?)?.map((m) => Module.fromJson(m)).toList() ??
          [],
      todos:
          (json['todos'] as List?)?.map((t) => TodoItem.fromJson(t)).toList() ??
          [],
      repositoryUrl: json['repositoryUrl'] ?? '',
      metadata: Map<String, String>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
