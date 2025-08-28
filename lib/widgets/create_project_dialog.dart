import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';

class CreateProjectDialog extends StatefulWidget {
  final Project? project;
  final Function(Project) onProjectCreated;

  const CreateProjectDialog({
    super.key,
    this.project,
    required this.onProjectCreated,
  });

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _repositoryController = TextEditingController();

  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  ProjectStatus _status = ProjectStatus.planning;
  final List<String> _teamMembers = [];
  final _teamMemberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _ownerController.text = widget.project!.owner;
      _repositoryController.text = widget.project!.repositoryUrl;
      _deadline = widget.project!.deadline;
      _status = widget.project!.status;
      _teamMembers.addAll(widget.project!.teamMembers);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _repositoryController.dispose();
    _teamMemberController.dispose();
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

  void _saveProject() {
    if (!_formKey.currentState!.validate()) return;

    final project = Project(
      id: widget.project?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      description: '',
      owner: _ownerController.text.trim(),
      repositoryUrl: _repositoryController.text.trim(),
      deadline: _deadline,
      status: _status,
      teamMembers: List.from(_teamMembers),
      modules: widget.project?.modules ?? [],
      todos: widget.project?.todos ?? [],
      createdAt: widget.project?.createdAt,
    );

    widget.onProjectCreated(project);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.project != null;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
      child: Column(
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
                    isEditing ? '编辑项目' : '创建新项目',
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
                      // 项目名称
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          labelText: '项目名称',
                          hintText: '输入项目名称',
                          prefixIcon: Icon(Icons.folder),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入项目名称';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 项目负责人
                      TextFormField(
                        controller: _ownerController,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          labelText: '项目负责人',
                          hintText: '输入负责人姓名',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入项目负责人';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 仓库地址
                      TextFormField(
                        controller: _repositoryController,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          labelText: '代码仓库',
                          hintText: '输入Git仓库地址',
                          prefixIcon: Icon(Icons.code),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 项目状态
                      DropdownButtonFormField<ProjectStatus>(
                        initialValue: _status,
                        decoration: const InputDecoration(
                          labelText: '项目状态',
                          prefixIcon: Icon(Icons.flag),
                        ),
                        items: ProjectStatus.values.map((status) {
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

                      // 截止日期
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _deadline,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 2),
                            ),
                          );
                          if (date != null) {
                            setState(() {
                              _deadline = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '截止日期',
                            prefixIcon: Icon(Icons.calendar_today),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                          ),
                          child: Text(
                            '${_deadline.year}-${_deadline.month.toString().padLeft(2, '0')}-${_deadline.day.toString().padLeft(2, '0')}',
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
                    ],
                  ),
                ),
              ),
            ),

            // 底部按钮
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      foregroundColor: theme.colorScheme.onSurface,
                      elevation: 2,
                    ),
                    child: Text(isEditing ? '保存' : '创建'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(ProjectStatus status) {
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
}
