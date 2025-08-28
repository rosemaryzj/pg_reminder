import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/app_state.dart';

class ProgressControlDialog extends ConsumerStatefulWidget {
  final String projectId;
  final String? moduleId;
  final String title;
  final double initialProgress;

  const ProgressControlDialog({
    super.key,
    required this.projectId,
    this.moduleId,
    required this.title,
    required this.initialProgress,
  });

  @override
  ConsumerState<ProgressControlDialog> createState() =>
      _ProgressControlDialogState();
}

class _ProgressControlDialogState extends ConsumerState<ProgressControlDialog> {
  late double _progress;
  late TextEditingController _progressController;

  @override
  void initState() {
    super.initState();
    _progress = widget.initialProgress;
    _progressController = TextEditingController(
      text: (_progress * 100).toInt().toString(),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _updateProgress(double value) {
    setState(() {
      _progress = value;
      _progressController.text = (value * 100).toInt().toString();
    });
  }

  void _updateProgressFromText() {
    final text = _progressController.text;
    final value = double.tryParse(text);
    if (value != null && value >= 0 && value <= 100) {
      setState(() {
        _progress = value / 100;
      });
    }
  }

  void _saveProgress() {
    if (widget.moduleId != null) {
      // 更新模块进度
      ref
          .read(appStateProvider.notifier)
          .updateModuleProgress(widget.projectId, widget.moduleId!, _progress);
    } else {
      // 更新项目进度
      ref
          .read(appStateProvider.notifier)
          .updateProjectProgress(widget.projectId, _progress);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.trending_up, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '调整进度 - ${widget.title}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 当前进度显示
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '当前进度',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getProgressColor(_progress),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(_progress),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 滑块控制
            Text(
              '拖动滑块调整进度',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _progress,
              onChanged: _updateProgress,
              divisions: 20,
              label: '${(_progress * 100).toInt()}%',
              activeColor: _getProgressColor(_progress),
            ),
            const SizedBox(height: 16),

            // 精确输入
            Text(
              '或直接输入百分比',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _progressController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '0-100',
                      suffixText: '%',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _updateProgressFromText(),
                  ),
                ),
                const SizedBox(width: 12),
                // 快捷按钮
                Wrap(
                  spacing: 4,
                  children: [0, 25, 50, 75, 100].map((value) {
                    return SizedBox(
                      width: 40,
                      height: 32,
                      child: OutlinedButton(
                        onPressed: () => _updateProgress(value / 100),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: BorderSide(
                            color: _progress == value / 100
                                ? theme.colorScheme.primary
                                : Colors.grey,
                          ),
                        ),
                        child: Text(
                          '$value',
                          style: TextStyle(
                            fontSize: 10,
                            color: _progress == value / 100
                                ? theme.colorScheme.primary
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saveProgress,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            foregroundColor: theme.colorScheme.onSurface,
            elevation: 2,
          ),
          child: const Text('保存'),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) {
      return Colors.red;
    } else if (progress < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}

// 显示进度控制对话框的便捷方法
void showProgressControlDialog(
  BuildContext context,
  String projectId,
  String title,
  double initialProgress, {
  String? moduleId,
}) {
  showDialog(
    context: context,
    builder: (context) => ProgressControlDialog(
      projectId: projectId,
      moduleId: moduleId,
      title: title,
      initialProgress: initialProgress,
    ),
  );
}
