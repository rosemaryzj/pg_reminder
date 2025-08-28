import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/module.dart';

class CreateModuleDialog extends StatefulWidget {
  final Module? module;
  final Function(Module) onModuleCreated;

  const CreateModuleDialog({
    super.key,
    this.module,
    required this.onModuleCreated,
  });

  @override
  State<CreateModuleDialog> createState() => _CreateModuleDialogState();
}

class _CreateModuleDialogState extends State<CreateModuleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _severeBugs = 0;
  int _generalBugs = 0;
  int _minorBugs = 0;
  final _testCaseCountController = TextEditingController();
  int _passedTestCount = 0;

  ModuleStatus _status = ModuleStatus.planning;
  double _progress = 0.0;
  DateTime? _deadline;
  final List<String> _teamMembers = [];
  final _teamMemberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.module != null) {
      _nameController.text = widget.module!.name;
      _descriptionController.text = widget.module!.description;
      _status = widget.module!.status;
      _progress = widget.module!.progress;
      _deadline = widget.module!.deadline;
      _teamMembers.addAll(widget.module!.teamMembers);
      _severeBugs = widget.module!.severeBugs;
      _generalBugs = widget.module!.generalBugs;
      _minorBugs = widget.module!.minorBugs;
      _testCaseCountController.text = widget.module!.testCaseCount.toString();
      _passedTestCount = widget.module!.passedTestCount;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _teamMemberController.dispose();
    _testCaseCountController.dispose();
    super.dispose();
  }

  void _addTeamMember() {
    final member = _teamMemberController.text.trim();
    if (member.isNotEmpty && !_teamMembers.contains(member)) {
      setState(() {
        _teamMembers.add(member);
        _teamMemberController.clear();
      });
    }
  }

  void _removeTeamMember(String member) {
    setState(() {
      _teamMembers.remove(member);
    });
  }

  void _saveModule() {
    if (!_formKey.currentState!.validate()) return;

    final testCaseCount = int.tryParse(_testCaseCountController.text) ?? 0;

    final module = Module(
      id: widget.module?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _status,
      progress: _progress,
      deadline: _deadline,
      teamMembers: List.from(_teamMembers),
      middlewares: widget.module?.middlewares ?? [],
      environments: widget.module?.environments ?? [],
      todos: widget.module?.todos ?? [],
      severeBugs: _severeBugs,
      generalBugs: _generalBugs,
      minorBugs: _minorBugs,
      testCaseCount: testCaseCount,
      passedTestCount: _passedTestCount > testCaseCount ? testCaseCount : _passedTestCount,
      createdAt: widget.module?.createdAt,
    );

    widget.onModuleCreated(module);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.module != null;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              // 拖拽指示器
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 标题栏
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isEditing ? Icons.edit : Icons.add,
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? '编辑模块' : '新增模块',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // 表单内容
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 模块名称
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: '模块名称',
                            hintText: '输入模块名称',
                            prefixIcon: Icon(Icons.widgets),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '请输入模块名称';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // 模块描述
                        TextFormField(
                          controller: _descriptionController,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: '模块描述',
                            hintText: '输入模块描述',
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // 模块状态
                        DropdownButtonFormField<ModuleStatus>(
                          initialValue: _status,
                          decoration: const InputDecoration(
                            labelText: '模块状态',
                            prefixIcon: Icon(Icons.flag),
                          ),
                          items: ModuleStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(_getStatusText(status)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _status = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // 进度滑块
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('开发进度', style: theme.textTheme.titleSmall),
                                Text(
                                  '${(_progress * 100).toInt()}%',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: _progress,
                              onChanged: (value) {
                                setState(() {
                                  _progress = value;
                                });
                              },
                              divisions: 20,
                              label: '${(_progress * 100).toInt()}%',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 截止日期
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  _deadline ??
                                  DateTime.now().add(const Duration(days: 30)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (date != null) {
                              setState(() {
                                _deadline = date;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: '截止日期（可选）',
                              prefixIcon: const Icon(Icons.calendar_today),
                              suffixIcon: _deadline != null
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _deadline = null;
                                        });
                                      },
                                    )
                                  : const Icon(Icons.arrow_drop_down),
                            ),
                            child: Text(
                              _deadline != null
                                  ? '${_deadline!.year}-${_deadline!.month.toString().padLeft(2, '0')}-${_deadline!.day.toString().padLeft(2, '0')}'
                                  : '点击选择日期',
                              style: TextStyle(
                                color: _deadline != null
                                    ? null
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                        // 团队成员
                        Text('团队成员', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _teamMemberController,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: '输入成员姓名',
                                  prefixIcon: Icon(Icons.person_add),
                                ),
                                onFieldSubmitted: (_) => _addTeamMember(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _addTeamMember,
                              child: const Text('添加'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // 成员列表
                        if (_teamMembers.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _teamMembers.map((member) {
                              return Chip(
                                label: Text(member),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () => _removeTeamMember(member),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 16),

                        // Bug 统计
                        Text('Bug 统计', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        _buildBugCounter('严重 Bug', _severeBugs, Colors.red, (newValue) {
                          setState(() => _severeBugs = newValue);
                        }),
                        const SizedBox(height: 8),
                        _buildBugCounter('一般 Bug', _generalBugs, Colors.orange, (newValue) {
                          setState(() => _generalBugs = newValue);
                        }),
                        const SizedBox(height: 8),
                        _buildBugCounter('次要 Bug', _minorBugs, Colors.yellow.shade700, (newValue) {
                          setState(() => _minorBugs = newValue);
                        }),
                        const SizedBox(height: 16),

                        // 测试覆盖率
                        Text('测试用例', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _testCaseCountController,
                          decoration: const InputDecoration(
                            labelText: '测试用例总数',
                            prefixIcon: Icon(Icons.list_alt),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              // Ensure passed test cases do not exceed total test cases
                              final total = int.tryParse(value) ?? 0;
                              if (_passedTestCount > total) {
                                _passedTestCount = total;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Builder(builder: (context) {
                          final totalCases = int.tryParse(_testCaseCountController.text) ?? 0;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('通过用例数', style: theme.textTheme.titleSmall),
                                  Text(
                                    '$_passedTestCount / $totalCases',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: _passedTestCount.toDouble().clamp(0.0, totalCases.toDouble()),
                                min: 0,
                                max: totalCases.toDouble(),
                                divisions: totalCases > 0 ? totalCases : null,
                                label: _passedTestCount.toString(),
                                onChanged: totalCases > 0
                                    ? (value) {
                                        setState(() {
                                          _passedTestCount = value.toInt();
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('取消'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _saveModule,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                foregroundColor: theme.colorScheme.onSurface,
                                elevation: 2,
                              ),
                              child: Text(isEditing ? '保存' : '创建'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBugCounter(String label, int value, Color color, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.bug_report, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                if (value > 0) {
                  onChanged(value - 1);
                }
              },
            ),
            Text(value.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                onChanged(value + 1);
              },
            ),
          ],
        ),
      ],
    );
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
}
