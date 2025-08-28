import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/app_state.dart';
import '../models/project.dart';
import '../widgets/project_card.dart';
import '../widgets/create_project_dialog.dart';
import '../widgets/app_bar_widget.dart';

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MeoAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateProjectDialog(context, ref),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 页面标题和统计
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 移除了原来的添加项目按钮
                  const SizedBox(height: 24),

                  // 快速统计卡片
                  _buildQuickStats(appState.projects, theme),
                ],
              ),
            ),
          ),

          // 项目列表
          if (appState.projects.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(context, theme, ref))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final project = appState.projects[index];
                  return ProjectCard(
                    project: project,
                    onTap: () {
                      ref
                          .read(appStateProvider.notifier)
                          .selectProject(project.id);
                      context.go('/project/${project.id}');
                    },
                    onEdit: () => _showEditProjectDialog(context, ref, project),
                    onDelete: () =>
                        _showDeleteConfirmation(context, ref, project),
                  );
                }, childCount: appState.projects.length),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100), // 底部间距
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(List<Project> projects, ThemeData theme) {
    final activeProjects = projects
        .where((p) => p.status == ProjectStatus.active)
        .length;
    final totalModules = projects.fold(0, (sum, p) => sum + p.modules.length);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '项目进行',
            activeProjects.toString(),
            Icons.play_circle_outline,
            theme.colorScheme.primary,
            theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            '模块总数',
            totalModules.toString(),
            Icons.widgets_outlined,
            Colors.orange,
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleText(String title, ThemeData theme) {
    // 将标题按两个字一行进行换行显示
    if (title.length <= 2) {
      return Text(
        title,
        style: theme.textTheme.bodySmall,
        textAlign: TextAlign.center,
      );
    }

    List<String> lines = [];
    for (int i = 0; i < title.length; i += 2) {
      int end = (i + 2 < title.length) ? i + 2 : title.length;
      lines.add(title.substring(i, end));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: lines
          .map(
            (line) => Text(
              line,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          )
          .toList(),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return SizedBox(
      height: 140,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              _buildTitleText(title, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '创建您的第一个项目开始管理',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateProjectDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('创建项目'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CreateProjectDialog(
        onProjectCreated: (project) {
          ref.read(appStateProvider.notifier).addProject(project);
        },
      ),
    );
  }

  void _showEditProjectDialog(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) {
    showDialog(
      context: context,
      builder: (context) => CreateProjectDialog(
        project: project,
        onProjectCreated: (updatedProject) {
          ref.read(appStateProvider.notifier).updateProject(updatedProject);
        },
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除项目'),
        content: Text('确定要删除项目 "${project.name}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(appStateProvider.notifier)
                  .deleteProject(project.id);
              // ignore: use_build_context_synchronously
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
}
