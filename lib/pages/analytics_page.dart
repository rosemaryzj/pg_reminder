import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../models/todo_item.dart';
import '../models/project.dart';
import '../services/app_state.dart';
import '../widgets/app_bar_widget.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  String? selectedProjectId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final theme = Theme.of(context);

    if (appState.projects.isEmpty) {
      return _buildEmptyState(context, theme);
    }

    // 获取选中的项目或所有项目
    final selectedProjects = selectedProjectId == null
        ? appState.projects
        : appState.projects.where((p) => p.id == selectedProjectId).toList();

    return Scaffold(
      appBar: const MeoAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 页面标题
            Text(
              '数据分析',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '项目和模块的统计分析',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // 项目选择器
            _buildProjectSelector(appState.projects, theme),
            const SizedBox(height: 16),

            // 项目状态分布
            _buildProjectStatusChart(selectedProjects, theme),
            const SizedBox(height: 24),

            // 模块进度分析
            if (selectedProjectId != null)
              _buildModuleProgressChart(selectedProjects, theme),
            const SizedBox(height: 24),

            // 新增：项目健康度
            _buildProjectHealthCard(selectedProjects, theme),
            const SizedBox(height: 24),

            // 团队工作负载
            _buildTeamWorkloadChart(selectedProjects, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSelector(List<Project> projects, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '项目筛选',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: selectedProjectId,
              decoration: const InputDecoration(
                labelText: '选择项目',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('所有项目'),
                ),
                ...projects.map(
                  (project) => DropdownMenuItem<String?>(
                    value: project.id,
                    child: Text(project.name),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedProjectId = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Scaffold(
      appBar: const MeoAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 50,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                '暂无数据分析',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '创建项目并添加任务后，您将在这里看到详细的数据分析和图表。',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // 导航到创建项目的页面或显示创建项目的对话框
                  context.go('/projects');
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('创建您的第一个项目'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectStatusChart(List<Project> projects, ThemeData theme) {
    final statusCounts = <ProjectStatus, int>{};
    for (final status in ProjectStatus.values) {
      statusCounts[status] = projects.where((p) => p.status == status).length;
    }

    final sections = statusCounts.entries
        .where((entry) => entry.value > 0)
        .map(
          (entry) => PieChartSectionData(
            value: entry.value.toDouble(),
            color: _getProjectStatusColor(entry.key),
            title: '${_getProjectStatusText(entry.key)}\n${entry.value}',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        )
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '项目状态分布',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: sections.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            size: 40,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          const Text('暂无数据'),
                        ],
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        sections: sections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleProgressChart(List<Project> projects, ThemeData theme) {
    final allModules = projects.expand((p) => p.modules).toList();

    if (allModules.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                '模块进度分析',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Icon(
                Icons.show_chart_outlined,
                size: 40,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 8),
              const Text('暂无模块数据'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '模块进度分析',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: allModules
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              e.value.progress * 100,
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 4,
                              color: theme.colorScheme.primary,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= allModules.length) {
                            return const Text('');
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              allModules[value.toInt()].name,
                              style: const TextStyle(fontSize: 10),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) =>
                            Text('${value.toInt()}%'),
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamWorkloadChart(List<Project> projects, ThemeData theme) {
    final teamWorkload = <String, int>{};

    for (final project in projects) {
      for (final member in project.teamMembers) {
        teamWorkload[member] = (teamWorkload[member] ?? 0) + 1;
      }
      for (final module in project.modules) {
        for (final member in module.teamMembers) {
          teamWorkload[member] = (teamWorkload[member] ?? 0) + 1;
        }
      }
    }

    if (teamWorkload.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                '团队工作负载',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              const Text('暂无团队数据'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '团队工作负载',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: teamWorkload.entries
                      .map(
                        (entry) => PieChartSectionData(
                          value: entry.value.toDouble(),
                          color: _getTeamMemberColor(entry.key),
                          title: '${entry.key}\n${entry.value}',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                      .toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectHealthCard(List<Project> projects, ThemeData theme) {
    if (projects.isEmpty) {
      return const SizedBox.shrink();
    }

    // 计算总体项目健康度
    final totalProgress = projects.fold<double>(
      0,
      (prev, p) => prev + p.overallProgress,
    );
    final averageProgress = projects.isNotEmpty
        ? totalProgress / projects.length
        : 0;

    // 计算任务完成率
    int totalTasks = 0;
    int completedTasks = 0;
    int overdueTasks = 0;

    for (final project in projects) {
      totalTasks += project.todos.length;
      completedTasks += project.todos
          .where((t) => t.status == TodoStatus.done)
          .length;
      overdueTasks += project.todos
          .where(
            (t) =>
                t.status != TodoStatus.done &&
                t.dueDate != null &&
                t.dueDate!.isBefore(DateTime.now()),
          )
          .length;

      for (final module in project.modules) {
        totalTasks += module.todos.length;
        completedTasks += module.todos
            .where((t) => t.status == TodoStatus.done)
            .length;
        overdueTasks += module.todos
            .where(
              (t) =>
                  t.status != TodoStatus.done &&
                  t.dueDate != null &&
                  t.dueDate!.isBefore(DateTime.now()),
            )
            .length;
      }
    }

    final completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0;

    double overdueFactor = totalTasks > 0
        ? 1 - (overdueTasks / totalTasks)
        : 1.0;
    if (overdueFactor < 0) overdueFactor = 0;

    final healthScore =
        (averageProgress * 100 * 0.4) +
        (completionRate * 100 * 0.4) +
        (overdueFactor * 100 * 0.2);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '项目健康度',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHealthMetric(
                  '健康评分',
                  '${healthScore.toStringAsFixed(1)} / 100',
                  healthScore > 80
                      ? Colors.green
                      : (healthScore > 50 ? Colors.orange : Colors.red),
                  theme,
                ),
                _buildHealthMetric(
                  '完成率',
                  '${(completionRate * 100).toStringAsFixed(1)}%',
                  Colors.blue,
                  theme,
                ),
                _buildHealthMetric(
                  '逾期任务',
                  overdueTasks.toString(),
                  overdueTasks > 0 ? Colors.red : Colors.green,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric(
    String title,
    String value,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Color _getProjectStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Colors.blue;
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.onHold:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.purple;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }

  String _getProjectStatusText(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return '规划中';
      case ProjectStatus.active:
        return '进行中';
      case ProjectStatus.onHold:
        return '暂停';
      case ProjectStatus.completed:
        return '已完成';
      case ProjectStatus.cancelled:
        return '已取消';
    }
  }

  Color _getTeamMemberColor(String memberName) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[memberName.hashCode % colors.length];
  }
}
