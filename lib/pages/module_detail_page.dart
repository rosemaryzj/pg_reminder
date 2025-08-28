import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind/widgets/create_module_dialog.dart';
import '../services/app_state.dart';
import '../models/module.dart';
import '../models/middleware.dart';
import '../models/todo_item.dart';
import '../widgets/create_middleware_dialog.dart';
import '../widgets/create_todo_dialog.dart';
import 'package:remind/widgets/app_bar_widget.dart';
import 'package:go_router/go_router.dart';

class ModuleDetailPage extends ConsumerStatefulWidget {
  final String projectId;
  final String moduleId;

  const ModuleDetailPage({
    super.key,
    required this.projectId,
    required this.moduleId,
  });

  @override
  ConsumerState<ModuleDetailPage> createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends ConsumerState<ModuleDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final project = appState.projects.firstWhere(
      (p) => p.id == widget.projectId,
    );
    final module = project.modules.firstWhere((m) => m.id == widget.moduleId);

    return Scaffold(
      appBar: MeoAppBar(
        title: module.name,
        showBackButton: true,
        onBackPressed: () => context.pop(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildModuleInfoCard(context, ref, widget.projectId, module),
          ),
          Expanded(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '待办事项'),
                    Tab(text: '中间件'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTodoCard(context, ref, widget.projectId, module),
                      _buildMiddlewareCard(
                        context,
                        ref,
                        widget.projectId,
                        module,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleInfoCard(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    Module module,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('模块信息', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showEditModuleDialog(context, ref, projectId, module),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (module.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.description, size: 20),
                  title: const Text('描述', style: TextStyle(fontSize: 14)),
                  subtitle: Text(module.description, style: const TextStyle(fontSize: 13)),
                ),
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.people, size: 20),
              title: const Text('团队成员', style: TextStyle(fontSize: 14)),
              subtitle: Text(
                module.teamMembers.isEmpty
                    ? '暂无团队成员'
                    : module.teamMembers.join(', '),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const Divider(),
            _buildBugAndTestInfo(context, module),
          ],
        ),
      ),
    );
  }

  Widget _buildBugAndTestInfo(BuildContext context, Module module) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Bug 统计', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, '严重', module.severeBugs.toString(), Colors.red),
            _buildStatItem(context, '一般', module.generalBugs.toString(), Colors.orange),
            _buildStatItem(context, '次要', module.minorBugs.toString(), Colors.yellow),
          ],
        ),
        const SizedBox(height: 12),
        Text('测试用例', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, '总数', module.testCaseCount.toString(), theme.colorScheme.onSurface),
            _buildStatItem(context, '通过', module.passedTestCount.toString(), Colors.green),
            _buildStatItem(
              context,
              '覆盖率',
              module.testCaseCount > 0
                  ? '${((module.passedTestCount / module.testCaseCount) * 100).toStringAsFixed(1)}%'
                  : 'N/A',
              theme.colorScheme.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  void _showEditModuleDialog(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    Module module,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateModuleDialog(
        module: module,
        onModuleCreated: (updatedModule) {
          ref
              .read(appStateProvider.notifier)
              .updateModule(projectId, updatedModule);
        },
      ),
    );
  }

  Widget _buildMiddlewareCard(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    Module module,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '中间件列表',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ElevatedButton.icon(
                onPressed: () => _createMiddleware(context, ref, projectId, module.id),
                icon: const Icon(Icons.add),
                label: const Text('新建中间件'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (module.middlewares.isEmpty)
            const Expanded(child: Center(child: Text('暂无中间件')))
          else
            Expanded(
              child: ListView.builder(
                itemCount: module.middlewares.length,
                itemBuilder: (context, index) {
                  final middleware = module.middlewares[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text(middleware.name),
                      subtitle: Text(
                        '类型: ${middleware.type.toString().split('.').last}\n版本: ${middleware.version}',
                      ),
                      onTap: () => _viewMiddleware(
                        context,
                        ref,
                        projectId,
                        module.id,
                        middleware,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editMiddleware(
                              context,
                              ref,
                              projectId,
                              module.id,
                              middleware,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteMiddleware(
                              context,
                              ref,
                              projectId,
                              module.id,
                              middleware,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _createMiddleware(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    String moduleId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateMiddlewareDialog(
        onMiddlewareCreated: (newMiddleware) {
          final appState = ref.read(appStateProvider);
          final project = appState.projects.firstWhere(
            (p) => p.id == projectId,
          );
          final module = project.modules.firstWhere((m) => m.id == moduleId);
          final updatedMiddlewares = List<Middleware>.from(module.middlewares)
            ..add(newMiddleware);
          final updatedModule = module.copyWith(
            middlewares: updatedMiddlewares,
          );
          ref
              .read(appStateProvider.notifier)
              .updateModule(projectId, updatedModule);
        },
      ),
    );
  }

  void _viewMiddleware(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    String moduleId,
    Middleware middleware,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateMiddlewareDialog(
        middleware: middleware,
        isReadOnly: true,
        onMiddlewareCreated: (updatedMiddleware) {
          // 查看模式，不需要保存
        },
      ),
    );
  }

  void _editMiddleware(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    String moduleId,
    Middleware middleware,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateMiddlewareDialog(
        middleware: middleware,
        onMiddlewareCreated: (updatedMiddleware) {
          final appState = ref.read(appStateProvider);
          final project = appState.projects.firstWhere(
            (p) => p.id == projectId,
          );
          final module = project.modules.firstWhere((m) => m.id == moduleId);
          final updatedMiddlewares = List<Middleware>.from(module.middlewares);
          final index = updatedMiddlewares.indexWhere((m) => m.id == middleware.id);
          if (index != -1) {
            updatedMiddlewares[index] = updatedMiddleware;
          }
          final updatedModule = module.copyWith(
            middlewares: updatedMiddlewares,
          );
          ref
              .read(appStateProvider.notifier)
              .updateModule(projectId, updatedModule);
        },
      ),
    );
  }

  void _deleteMiddleware(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    String moduleId,
    Middleware middleware,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除中间件'),
        content: Text('确定要删除中间件 "${middleware.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final appState = ref.read(appStateProvider);
              final project = appState.projects.firstWhere(
                (p) => p.id == projectId,
              );
              final module = project.modules.firstWhere(
                (m) => m.id == moduleId,
              );

              final updatedMiddlewares = List<Middleware>.from(
                module.middlewares,
              )..removeWhere((m) => m.id == middleware.id);

              final updatedModule = module.copyWith(
                middlewares: updatedMiddlewares,
              );
              ref
                  .read(appStateProvider.notifier)
                  .updateModule(projectId, updatedModule);

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已删除中间件 "${middleware.name}"')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoCard(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    Module module,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '待办事项列表',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ElevatedButton.icon(
                onPressed: () => _createTodo(context, ref, projectId, module.id),
                icon: const Icon(Icons.add),
                label: const Text('新建待办'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (module.todos.isEmpty)
            const Expanded(child: Center(child: Text('暂无待办事项')))
          else
            Expanded(
              child: ListView.builder(
                itemCount: module.todos.length,
                itemBuilder: (context, index) {
                  final todo = module.todos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: IconButton(
                        icon: Icon(
                          todo.status == TodoStatus.done
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: todo.status == TodoStatus.done
                              ? Colors.green
                              : Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: () {
                          final updatedTodo = todo.copyWith(
                            status: todo.status == TodoStatus.done
                                ? TodoStatus.todo
                                : TodoStatus.done,
                          );
                          final updatedTodos = List<TodoItem>.from(
                            module.todos,
                          );
                          updatedTodos[index] = updatedTodo;
                          final updatedModule = module.copyWith(
                            todos: updatedTodos,
                          );
                          ref
                              .read(appStateProvider.notifier)
                              .updateModule(projectId, updatedModule);
                        },
                      ),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration: todo.status == TodoStatus.done
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editTodo(
                              context,
                              ref,
                              projectId,
                              module.id,
                              todo,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteTodo(
                              context,
                              ref,
                              projectId,
                              module.id,
                              todo,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _viewTodo(
                        context,
                        ref,
                        projectId,
                        module.id,
                        todo,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _createTodo(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    String moduleId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateTodoDialog(
        onTodoCreated: (newTodo) {
          final appState = ref.read(appStateProvider);
          final project = appState.projects.firstWhere(
            (p) => p.id == projectId,
          );
          final module = project.modules.firstWhere((m) => m.id == moduleId);
          final updatedTodos = List<TodoItem>.from(module.todos)..add(newTodo);
          final updatedModule = module.copyWith(todos: updatedTodos);
          ref
              .read(appStateProvider.notifier)
              .updateModule(projectId, updatedModule);
        },
      ),
    );
  }

  void _editTodo(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    String moduleId,
    TodoItem todo,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateTodoDialog(
        todo: todo,
        onTodoCreated: (updatedTodo) {
          final appState = ref.read(appStateProvider);
          final project = appState.projects.firstWhere(
            (p) => p.id == projectId,
          );
          final module = project.modules.firstWhere((m) => m.id == moduleId);
          final updatedTodos = List<TodoItem>.from(module.todos);
          final index = updatedTodos.indexWhere((t) => t.id == todo.id);
          if (index != -1) {
            updatedTodos[index] = updatedTodo;
          }
          final updatedModule = module.copyWith(todos: updatedTodos);
          ref
              .read(appStateProvider.notifier)
              .updateModule(projectId, updatedModule);
        },
      ),
    );
  }

  void _viewTodo(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    String moduleId,
    TodoItem todo,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateTodoDialog(
         isReadOnly: true,
         todo: todo,
       ),
    );
  }

  void _deleteTodo(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    String moduleId,
    TodoItem todo,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除待办事项'),
        content: Text('确定要删除待办事项 "${todo.title}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final appState = ref.read(appStateProvider);
              final project = appState.projects.firstWhere(
                (p) => p.id == projectId,
              );
              final module = project.modules.firstWhere(
                (m) => m.id == moduleId,
              );
              final updatedTodos = List<TodoItem>.from(module.todos)
                ..removeWhere((t) => t.id == todo.id);
              final updatedModule = module.copyWith(todos: updatedTodos);
              ref
                  .read(appStateProvider.notifier)
                  .updateModule(projectId, updatedModule);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已删除待办事项 "${todo.title}"')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
