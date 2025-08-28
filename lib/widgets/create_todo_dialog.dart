import 'package:flutter/material.dart';
import 'package:remind/models/todo_item.dart';
import 'package:uuid/uuid.dart';

class CreateTodoDialog extends StatefulWidget {
  final TodoItem? todo;
  final Function(TodoItem)? onTodoCreated;
  final bool isReadOnly;

  const CreateTodoDialog({
    super.key,
    this.todo,
    this.onTodoCreated,
    this.isReadOnly = false,
  });

  @override
  State<CreateTodoDialog> createState() => _CreateTodoDialogState();
}

class _CreateTodoDialogState extends State<CreateTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assigneeController = TextEditingController();

  Priority _priority = Priority.medium;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description;
      _priority = widget.todo!.priority;
      _assigneeController.text = widget.todo!.assignee;
      _dueDate = widget.todo!.dueDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部拖拽指示器
          SizedBox(height: 20),
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.todo == null
                      ? '创建待办事项'
                      : (widget.isReadOnly ? '查看待办事项' : '编辑待办事项'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (!widget.isReadOnly)
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
          ),
          const Divider(),
          // 表单内容
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      readOnly: widget.isReadOnly,
                      decoration: const InputDecoration(
                        labelText: '标题',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入标题';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      readOnly: widget.isReadOnly,
                      decoration: const InputDecoration(
                        labelText: '描述',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Priority>(
                      initialValue: _priority,
                      decoration: const InputDecoration(
                        labelText: '优先级',
                        border: OutlineInputBorder(),
                      ),
                      items: Priority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(_getPriorityText(priority)),
                        );
                      }).toList(),
                      onChanged: widget.isReadOnly
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _priority = value;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _assigneeController,
                      readOnly: widget.isReadOnly,
                      decoration: const InputDecoration(
                        labelText: '负责人',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          _dueDate == null
                              ? '选择截止日期'
                              : '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}',
                        ),
                        onTap: widget.isReadOnly
                            ? null
                            : () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _dueDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (date != null) {
                                  setState(() {
                                    _dueDate = date;
                                  });
                                }
                              },
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!widget.isReadOnly)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('取消'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final newTodo = TodoItem(
                                  id: widget.todo?.id ?? const Uuid().v4(),
                                  title: _titleController.text,
                                  description: _descriptionController.text,
                                  priority: _priority,
                                  assignee: _assigneeController.text,
                                  dueDate: _dueDate,
                                );
                                widget.onTodoCreated?.call(newTodo);
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(widget.todo == null ? '创建' : '保存'),
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
    );
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.low:
        return '低';
      case Priority.medium:
        return '中';
      case Priority.high:
        return '高';
      case Priority.urgent:
        return '紧急';
    }
  }
}
