import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/app_state.dart';
import '../models/module.dart';
import '../widgets/module_card.dart';
import '../widgets/create_module_dialog.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/progress_control_dialog.dart';

class ProjectDetailPage extends ConsumerWidget {
  final String projectId;

  const ProjectDetailPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final project = appState.projects.firstWhere((p) => p.id == projectId);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MeoAppBar(
        title: project.name,
        showBackButton: true,
        onBackPressed: () => context.go('/'),
        actions: [
          IconButton(
            onPressed: () => _showCreateModuleDialog(context, ref, projectId),
            icon: const Icon(Icons.add),
            tooltip: '添加模块',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 项目概览
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 项目信息卡片
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '项目信息',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  '负责人',
                                  project.owner,
                                  Icons.person,
                                  theme,
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  '状态',
                                  _getStatusText(project.status),
                                  Icons.flag,
                                  theme,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => showProgressControlDialog(
                                    context,
                                    projectId,
                                    project.name,
                                    project.overallProgress,
                                  ),
                                  child: _buildInfoItem(
                                    '进度',
                                    '${(project.overallProgress * 100).toInt()}%',
                                    Icons.trending_up,
                                    theme,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  '模块数',
                                  project.modules.length.toString(),
                                  Icons.widgets,
                                  theme,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 模块列表
          if (project.modules.isEmpty)
            SliverFillRemaining(child: _buildEmptyModules(context, theme))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final module = project.modules[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ModuleCard(
                      module: module,
                      projectId: projectId,
                      onTap: () {
                        context.go('/project/$projectId/module/${module.id}');
                      },
                      onEdit: () => _showEditModuleDialog(
                        context,
                        ref,
                        projectId,
                        module,
                      ),
                      onDelete: () => _showDeleteModuleConfirmation(
                        context,
                        ref,
                        projectId,
                        module,
                      ),
                    ),
                  );
                }, childCount: project.modules.length),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyModules(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.widgets_outlined, size: 30, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '还没有模块',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '添加第一个模块开始开发',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateModuleDialog(
    BuildContext context,
    WidgetRef ref,
    String projectId,
  ) {
    showDialog(
      context: context,
      builder: (context) => CreateModuleDialog(
        onModuleCreated: (module) {
          ref.read(appStateProvider.notifier).addModule(projectId, module);
        },
      ),
    );
  }

  void _showEditModuleDialog(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    Module module,
  ) {
    showDialog(
      context: context,
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

  void _showDeleteModuleConfirmation(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    Module module,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除模块'),
        content: Text('确定要删除模块 "${module.name}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(appStateProvider.notifier)
                  .deleteModule(projectId, module.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(dynamic status) {
    // 这里应该根据实际的状态枚举返回对应的文本
    return status.toString().split('.').last;
  }
}
