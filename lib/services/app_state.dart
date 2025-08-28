import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../models/project.dart';
import '../models/module.dart';
import '../models/todo_item.dart';
import 'storage_service.dart';

class AppState {
  final bool isLoggedIn;
  final String? currentUser;
  final List<Project> projects;
  final String? selectedProjectId;

  AppState({
    this.isLoggedIn = false,
    this.currentUser,
    this.projects = const [],
    this.selectedProjectId,
  });

  AppState copyWith({
    bool? isLoggedIn,
    String? currentUser,
    List<Project>? projects,
    String? selectedProjectId,
  }) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      currentUser: currentUser ?? this.currentUser,
      projects: projects ?? this.projects,
      selectedProjectId: selectedProjectId ?? this.selectedProjectId,
    );
  }

  Project? get selectedProject {
    if (selectedProjectId == null) return null;
    try {
      return projects.firstWhere((p) => p.id == selectedProjectId);
    } catch (e) {
      return null;
    }
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState()) {
    _loadData();
  }

  final _uuid = const Uuid();

  Future<void> _loadData() async {
    final projects = StorageService.loadProjects();
    final isLoggedIn = StorageService.isLoggedIn();
    final currentUser = StorageService.getCurrentUser();

    state = state.copyWith(
      projects: projects,
      isLoggedIn: isLoggedIn,
      currentUser: currentUser,
    );

    // 如果没有项目数据，创建默认的 Hynet 项目
    // if (projects.isEmpty) {
    //   _createHynetProject();
    // } else {
    //   // 检查是否存在混合云项目，如果不存在则创建
    //   final hasHynetProject = projects.any((p) => p.name == 'HyNet');
    //   if (!hasHynetProject) {
    //     _createHynetProject();
    //   }
    // }
  }

  Future<void> _saveData() async {
    await StorageService.saveProjects(state.projects);
  }

  // 认证相关
  void login(String username) {
    state = state.copyWith(isLoggedIn: true, currentUser: username);
    StorageService.setLoggedIn(true);
    StorageService.setCurrentUser(username);
  }

  void logout() {
    state = state.copyWith(
      isLoggedIn: false,
      currentUser: null,
      selectedProjectId: null,
    );
    StorageService.logout();
  }

  // 项目管理
  void addProject(Project project) {
    final newProject = project.copyWith(id: _uuid.v4());
    state = state.copyWith(projects: [...state.projects, newProject]);
    _saveData();
  }

  void updateProject(Project project) {
    final updatedProjects = state.projects.map((p) {
      return p.id == project.id ? project : p;
    }).toList();
    state = state.copyWith(projects: updatedProjects);
    _saveData();
  }

  Future<void> deleteProject(String projectId) async {
    // 找到要删除的项目
    final projectToDelete = state.projects.firstWhere(
      (p) => p.id == projectId,
      orElse: () => throw Exception('Project not found'),
    );

    // 清理项目相关的所有本地存储数据
    // 1. 清理所有模块的中间件数据
    for (final module in projectToDelete.modules) {
      // 清理模块的中间件连接信息和配置
      // ignore: unused_local_variable
      for (final middleware in module.middlewares) {
        // 清理中间件的连接配置数据
        // 这些数据存储在SharedPreferences中，会随着项目数据一起被清理
        // print('清理中间件: ${middleware.name} (${middleware.type})');
      }

      // 清理模块的环境配置
      // 清理模块的待办事项
      // 清理模块的测试数据和bug统计
      // print('清理模块: ${module.name} 及其所有相关数据');
    }

    // 2. 清理项目的待办事项
    // ignore: unused_local_variable
    for (final todo in projectToDelete.todos) {
      // print('清理待办事项: ${todo.title}');
    }

    // 3. 清理项目的元数据
    // print('清理项目元数据: ${projectToDelete.metadata}');

    // 4. 从项目列表中移除项目
    final updatedProjects = state.projects
        .where((p) => p.id != projectId)
        .toList();

    // 5. 如果删除的是当前选中的项目，清除选中状态
    String? newSelectedProjectId = state.selectedProjectId;
    if (state.selectedProjectId == projectId) {
      newSelectedProjectId = null;
    }

    // 6. 更新状态并保存到SharedPreferences
    state = state.copyWith(
      projects: updatedProjects,
      selectedProjectId: newSelectedProjectId,
    );

    // 7. 清理项目在SharedPreferences中的特定数据
    await StorageService.clearProjectData(projectId);

    // 8. 保存更新后的数据到SharedPreferences
    // 这会完全清理被删除项目的所有数据，因为数据是以完整项目列表的形式存储的
    _saveData();
  }

  void selectProject(String? projectId) {
    state = state.copyWith(selectedProjectId: projectId);
  }

  // 模块管理
  void addModule(String projectId, Module module) {
    final newModule = module.copyWith(id: _uuid.v4());
    final updatedProjects = state.projects.map((project) {
      if (project.id == projectId) {
        return project.copyWith(modules: [...project.modules, newModule]);
      }
      return project;
    }).toList();
    state = state.copyWith(projects: updatedProjects);
    _saveData();
  }

  void updateModule(String projectId, Module module) {
    final updatedProjects = state.projects.map((project) {
      if (project.id == projectId) {
        final updatedModules = project.modules.map((m) {
          return m.id == module.id ? module : m;
        }).toList();
        return project.copyWith(modules: updatedModules);
      }
      return project;
    }).toList();
    state = state.copyWith(projects: updatedProjects);
    _saveData();
  }

  void deleteModule(String projectId, String moduleId) {
    final updatedProjects = state.projects.map((project) {
      if (project.id == projectId) {
        final updatedModules = project.modules
            .where((m) => m.id != moduleId)
            .toList();
        return project.copyWith(modules: updatedModules);
      }
      return project;
    }).toList();
    state = state.copyWith(projects: updatedProjects);
    _saveData();
  }

  // Todo管理
  void addTodoToProject(String projectId, TodoItem todo) {
    final newTodo = todo.copyWith(id: _uuid.v4());
    final updatedProjects = state.projects.map((project) {
      if (project.id == projectId) {
        return project.copyWith(todos: [...project.todos, newTodo]);
      }
      return project;
    }).toList();
    state = state.copyWith(projects: updatedProjects);
    _saveData();
  }

  void addTodoToModule(String projectId, String moduleId, TodoItem todo) {
    final newTodo = todo.copyWith(id: _uuid.v4());
    final updatedProjects = state.projects.map((project) {
      if (project.id == projectId) {
        final updatedModules = project.modules.map((module) {
          if (module.id == moduleId) {
            return module.copyWith(todos: [...module.todos, newTodo]);
          }
          return module;
        }).toList();
        return project.copyWith(modules: updatedModules);
      }
      return project;
    }).toList();
    state = state.copyWith(projects: updatedProjects);
    _saveData();
  }

  // 进度控制
  void updateProjectProgress(String projectId, double progress) {
    final updatedProjects = state.projects.map((project) {
      if (project.id == projectId) {
        // 将项目进度平均分配给所有模块
        final updatedModules = project.modules.map((module) {
          return module.copyWith(progress: progress);
        }).toList();
        return project.copyWith(modules: updatedModules);
      }
      return project;
    }).toList();
    state = state.copyWith(projects: updatedProjects);
    _saveData();
  }

  void updateModuleProgress(
    String projectId,
    String moduleId,
    double progress,
  ) {
    final updatedProjects = state.projects.map((project) {
      if (project.id == projectId) {
        final updatedModules = project.modules.map((module) {
          if (module.id == moduleId) {
            return module.copyWith(progress: progress);
          }
          return module;
        }).toList();
        return project.copyWith(modules: updatedModules);
      }
      return project;
    }).toList();
    state = state.copyWith(projects: updatedProjects);
    _saveData();
  }

  // 数据导入/导出
  String exportData() {
    final data = {
      'projects': state.projects.map((p) => p.toJson()).toList(),
    };
    return jsonEncode(data);
  }

  void importData(String jsonString) {
    final data = jsonDecode(jsonString);
    final projects = (data['projects'] as List)
        .map((p) => Project.fromJson(p))
        .toList();
    state = state.copyWith(projects: projects);
    _saveData();
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);
