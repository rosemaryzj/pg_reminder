import 'package:flutter/material.dart';
import '../models/module.dart';
import 'progress_control_dialog.dart';

class ModuleCard extends StatelessWidget {
  final Module module;
  final String projectId;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ModuleCard({
    super.key,
    required this.module,
    required this.projectId,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = module.progress;
    final testCoverage = module.testCoverage;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 模块标题和菜单
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      module.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 状态标签
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            module.status,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(module.status),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(module.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit?.call();
                              break;
                            case 'delete':
                              onDelete?.call();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('编辑'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text(
                                '删除',
                                style: TextStyle(color: Colors.red),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                        child: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 模块描述
              if (module.description.isNotEmpty) ...[
                Text(
                  module.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],

              // 进度信息
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('开发进度', style: theme.textTheme.bodySmall),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => showProgressControlDialog(
                            context,
                            projectId,
                            module.name,
                            progress,
                            moduleId: module.id,
                          ),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getProgressColor(progress),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('测试覆盖率', style: theme.textTheme.bodySmall),
                            Text(
                              '${(testCoverage * 100).toInt()}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: testCoverage,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getTestCoverageColor(testCoverage),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 底部统计信息
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    Icons.group,
                    '${module.teamMembers.length} 成员',
                    theme,
                  ),
                  _buildStatItem(
                    Icons.bug_report,
                    '${module.totalBugs} Bug',
                    theme,
                    color: module.totalBugs > 0 ? Colors.red : null,
                  ),
                  _buildStatItem(
                    Icons.storage,
                    '${module.middlewares.length} 中间件',
                    theme,
                  ),
                  _buildStatItem(
                    Icons.checklist,
                    '${module.todos.length} 任务',
                    theme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String text,
    ThemeData theme, {
    Color? color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color ?? Colors.grey[600],
            fontWeight: color != null ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ModuleStatus status) {
    switch (status) {
      case ModuleStatus.planning:
        return Colors.blue;
      case ModuleStatus.development:
        return Colors.orange;
      case ModuleStatus.testing:
        return Colors.purple;
      case ModuleStatus.deployment:
        return Colors.teal;
      case ModuleStatus.completed:
        return Colors.green;
      case ModuleStatus.paused:
        return Colors.grey;
    }
  }

  String _getStatusText(ModuleStatus status) {
    switch (status) {
      case ModuleStatus.planning:
        return '规划中';
      case ModuleStatus.development:
        return '开发中';
      case ModuleStatus.testing:
        return '测试中';
      case ModuleStatus.deployment:
        return '部署中';
      case ModuleStatus.completed:
        return '已完成';
      case ModuleStatus.paused:
        return '已暂停';
    }
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }

  Color _getTestCoverageColor(double coverage) {
    if (coverage < 0.5) return Colors.red;
    if (coverage < 0.8) return Colors.orange;
    return Colors.green;
  }
}
