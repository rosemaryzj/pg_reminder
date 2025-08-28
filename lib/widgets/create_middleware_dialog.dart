import 'package:flutter/material.dart';
import '../models/middleware.dart';

class CreateMiddlewareDialog extends StatefulWidget {
  final Function(Middleware) onMiddlewareCreated;
  final Middleware? middleware;
  final bool isReadOnly;

  const CreateMiddlewareDialog({
    super.key,
    required this.onMiddlewareCreated,
    this.middleware,
    this.isReadOnly = false,
  });

  @override
  State<CreateMiddlewareDialog> createState() => _CreateMiddlewareDialogState();
}

class _CreateMiddlewareDialogState extends State<CreateMiddlewareDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _versionController = TextEditingController();
  final _addressController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _databaseController = TextEditingController();
  MiddlewareType _selectedType = MiddlewareType.mysql;

  @override
  void initState() {
    super.initState();
    if (widget.middleware != null) {
      _nameController.text = widget.middleware!.name;
      _descriptionController.text = widget.middleware!.description;
      _versionController.text = widget.middleware!.version;
      _selectedType = widget.middleware!.type;

      // 加载连接信息
      final connectionInfo = widget.middleware!.connectionInfo;
      _addressController.text = connectionInfo['address'] ?? '';
      _usernameController.text = connectionInfo['username'] ?? '';
      _passwordController.text = connectionInfo['password'] ?? '';
      _databaseController.text = connectionInfo['database'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _versionController.dispose();
    _addressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _databaseController.dispose();
    super.dispose();
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
                  widget.middleware == null
                      ? '创建中间件'
                      : (widget.isReadOnly ? '查看中间件' : '编辑中间件'),
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
                      controller: _nameController,
                      readOnly: widget.isReadOnly,
                      decoration: const InputDecoration(
                        labelText: '中间件名称',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入中间件名称';
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
                    TextFormField(
                      controller: _versionController,
                      readOnly: widget.isReadOnly,
                      decoration: const InputDecoration(
                        labelText: '版本',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<MiddlewareType>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: '中间件类型',
                        border: OutlineInputBorder(),
                      ),
                      items: MiddlewareType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: widget.isReadOnly
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedType = value;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      readOnly: widget.isReadOnly,
                      decoration: const InputDecoration(
                        labelText: '地址（支持多行，可包含端口）',
                        border: OutlineInputBorder(),
                        hintText:
                            '例如：\nredis://localhost:6379\nmysql://user:pass@host:3306/db',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      readOnly: widget.isReadOnly,
                      decoration: const InputDecoration(
                        labelText: '用户名',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      readOnly: widget.isReadOnly,
                      decoration: const InputDecoration(
                        labelText: '密码',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    if (_needsDatabase(_selectedType)) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _databaseController,
                        readOnly: widget.isReadOnly,
                        decoration: const InputDecoration(
                          labelText: '数据库名称',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
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
                            onPressed: _saveMiddleware,
                            child: const Text('保存'),
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

  bool _needsDatabase(MiddlewareType type) {
    return type == MiddlewareType.mysql ||
        type == MiddlewareType.postgresql ||
        type == MiddlewareType.mongodb;
  }

  void _saveMiddleware() {
    if (_formKey.currentState!.validate()) {
      final connectionInfo = <String, dynamic>{
        'address': _addressController.text,
        'username': _usernameController.text,
        'password': _passwordController.text,
      };

      if (_needsDatabase(_selectedType) &&
          _databaseController.text.isNotEmpty) {
        connectionInfo['database'] = _databaseController.text;
      }

      final middleware = Middleware(
        id:
            widget.middleware?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _selectedType,
        version: _versionController.text,
        connectionInfo: connectionInfo,
        description: _descriptionController.text,
      );
      widget.onMiddlewareCreated(middleware);
      Navigator.of(context).pop();
    }
  }
}
