import 'package:flutter/material.dart';
import '../models/middleware.dart';

class MiddlewareManagementDialog extends StatefulWidget {
  final List<Middleware> middlewares;
  final Function(List<Middleware>) onMiddlewaresChanged;

  const MiddlewareManagementDialog({
    super.key,
    required this.middlewares,
    required this.onMiddlewaresChanged,
  });

  @override
  State<MiddlewareManagementDialog> createState() =>
      _MiddlewareManagementDialogState();
}

class _MiddlewareManagementDialogState
    extends State<MiddlewareManagementDialog> {
  late List<Middleware> _middlewares;

  @override
  void initState() {
    super.initState();
    _middlewares = List.from(widget.middlewares);
  }

  void _addMiddleware() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateMiddlewareDialog(
        onMiddlewareCreated: (middleware) {
          setState(() {
            _middlewares.add(middleware);
          });
        },
      ),
    );
  }

  void _editMiddleware(Middleware middleware) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateMiddlewareDialog(
        middleware: middleware,
        onMiddlewareCreated: (updatedMiddleware) {
          setState(() {
            final index = _middlewares.indexWhere((m) => m.id == middleware.id);
            if (index != -1) {
              _middlewares[index] = updatedMiddleware;
            }
          });
        },
      ),
    );
  }

  void _deleteMiddleware(Middleware middleware) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('删除中间件'),
          content: Text('确定要删除中间件 "${middleware.name}" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _middlewares.removeWhere((m) => m.id == middleware.id);
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
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
                    Icons.storage,
                    color: theme.colorScheme.onSurface,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '中间件管理',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _addMiddleware,
                    icon: Icon(
                      Icons.add,
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    tooltip: '添加中间件',
                  ),
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

            // 中间件列表
            Expanded(
              child: _middlewares.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.storage_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '还没有中间件',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '点击右上角的 + 按钮添加中间件',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _middlewares.length,
                      itemBuilder: (context, index) {
                        final middleware = _middlewares[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getMiddlewareColor(
                                middleware.type,
                              ).withValues(alpha: 0.1),
                              child: Icon(
                                _getMiddlewareIcon(middleware.type),
                                color: _getMiddlewareColor(middleware.type),
                              ),
                            ),
                            title: Text(
                              middleware.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              '${_getMiddlewareTypeName(middleware.type)} v${middleware.version}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _editMiddleware(middleware),
                                  icon: Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  tooltip: '编辑中间件',
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _deleteMiddleware(middleware),
                                  icon: Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: theme.colorScheme.error,
                                  ),
                                  tooltip: '删除中间件',
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
                    child: const Text('取消', style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      widget.onMiddlewaresChanged(_middlewares);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      foregroundColor: theme.colorScheme.onSurface,
                      elevation: 2,
                    ),
                    child: const Text('保存', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMiddlewareColor(MiddlewareType type) {
    switch (type) {
      case MiddlewareType.mysql:
        return Colors.blue;
      case MiddlewareType.postgresql:
        return Colors.indigo;
      case MiddlewareType.mongodb:
        return Colors.green;
      case MiddlewareType.redis:
        return Colors.red;
      case MiddlewareType.elasticsearch:
        return Colors.orange;
      case MiddlewareType.kafka:
        return Colors.purple;
      case MiddlewareType.rabbitmq:
        return Colors.teal;
      case MiddlewareType.etcd:
        return Colors.brown;
      case MiddlewareType.nginx:
        return Colors.cyan;
      case MiddlewareType.docker:
        return Colors.blueGrey;
    }
  }

  IconData _getMiddlewareIcon(MiddlewareType type) {
    switch (type) {
      case MiddlewareType.mysql:
      case MiddlewareType.postgresql:
        return Icons.storage;
      case MiddlewareType.mongodb:
        return Icons.account_tree;
      case MiddlewareType.redis:
        return Icons.memory;
      case MiddlewareType.elasticsearch:
        return Icons.search;
      case MiddlewareType.kafka:
        return Icons.stream;
      case MiddlewareType.rabbitmq:
        return Icons.message;
      case MiddlewareType.etcd:
        return Icons.settings;
      case MiddlewareType.nginx:
        return Icons.web;
      case MiddlewareType.docker:
        return Icons.developer_board;
    }
  }

  String _getMiddlewareTypeName(MiddlewareType type) {
    switch (type) {
      case MiddlewareType.mysql:
        return 'MySQL';
      case MiddlewareType.postgresql:
        return 'PostgreSQL';
      case MiddlewareType.mongodb:
        return 'MongoDB';
      case MiddlewareType.redis:
        return 'Redis';
      case MiddlewareType.elasticsearch:
        return 'Elasticsearch';
      case MiddlewareType.kafka:
        return 'Kafka';
      case MiddlewareType.rabbitmq:
        return 'RabbitMQ';
      case MiddlewareType.etcd:
        return 'etcd';
      case MiddlewareType.nginx:
        return 'Nginx';
      case MiddlewareType.docker:
        return 'Docker';
    }
  }
}

class CreateMiddlewareDialog extends StatefulWidget {
  final Middleware? middleware;
  final Function(Middleware) onMiddlewareCreated;

  const CreateMiddlewareDialog({
    super.key,
    this.middleware,
    required this.onMiddlewareCreated,
  });

  @override
  State<CreateMiddlewareDialog> createState() => _CreateMiddlewareDialogState();
}

class _CreateMiddlewareDialogState extends State<CreateMiddlewareDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _versionController = TextEditingController();
  final _descriptionController = TextEditingController();

  MiddlewareType _type = MiddlewareType.mysql;
  final Map<String, TextEditingController> _connectionControllers = {};
  final Map<String, List<TextEditingController>> _multiAddressControllers = {};

  @override
  void initState() {
    super.initState();
    if (widget.middleware != null) {
      _nameController.text = widget.middleware!.name;
      _versionController.text = widget.middleware!.version;
      _descriptionController.text = widget.middleware!.description;
      _type = widget.middleware!.type;

      for (final entry in widget.middleware!.connectionInfo.entries) {
        if (entry.value is List) {
          // 如果是多地址字段，创建多个控制器
          if (entry.key == 'hosts' ||
              entry.key == 'endpoints' ||
              entry.key == 'bootstrap_servers' ||
              entry.key == 'upstream_servers') {
            final addresses = entry.value as List;
            _multiAddressControllers[entry.key] = addresses
                .map((addr) => TextEditingController(text: addr.toString()))
                .toList();
          } else {
            final displayValue = (entry.value as List).join(', ');
            _connectionControllers[entry.key] = TextEditingController(
              text: displayValue,
            );
          }
        } else {
          _connectionControllers[entry.key] = TextEditingController(
            text: entry.value.toString(),
          );
        }
      }
    }
    _initializeConnectionFields();
  }

  void _initializeConnectionFields() {
    final fields = _getConnectionFields(_type);
    for (final field in fields) {
      final isMultiAddressField =
          field == 'hosts' ||
          field == 'endpoints' ||
          field == 'bootstrap_servers' ||
          field == 'upstream_servers';

      if (isMultiAddressField) {
        if (!_multiAddressControllers.containsKey(field)) {
          _multiAddressControllers[field] = [TextEditingController()];
        }
      } else {
        if (!_connectionControllers.containsKey(field)) {
          _connectionControllers[field] = TextEditingController();
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    _descriptionController.dispose();
    for (final controller in _connectionControllers.values) {
      controller.dispose();
    }
    for (final controllers in _multiAddressControllers.values) {
      for (final controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  List<String> _getConnectionFields(MiddlewareType type) {
    switch (type) {
      case MiddlewareType.mysql:
      case MiddlewareType.postgresql:
        return ['hosts', 'port', 'database', 'username', 'password'];
      case MiddlewareType.mongodb:
        return [
          'hosts',
          'port',
          'database',
          'username',
          'password',
          'replica_set',
        ];
      case MiddlewareType.redis:
        return ['hosts', 'port', 'password', 'cluster_mode'];
      case MiddlewareType.elasticsearch:
        return [
          'hosts',
          'port',
          'index',
          'username',
          'password',
          'cluster_name',
        ];
      case MiddlewareType.kafka:
        return ['bootstrap_servers', 'topic', 'group_id', 'security_protocol'];
      case MiddlewareType.rabbitmq:
        return [
          'hosts',
          'port',
          'vhost',
          'username',
          'password',
          'cluster_name',
        ];
      case MiddlewareType.etcd:
        return ['endpoints', 'username', 'password', 'cluster_token'];
      case MiddlewareType.nginx:
        return ['hosts', 'port', 'config_path', 'upstream_servers'];
      case MiddlewareType.docker:
        return ['hosts', 'port', 'registry', 'swarm_mode'];
    }
  }

  List<Widget> _buildOptimizedConnectionFields(MiddlewareType type) {
    final fields = _getConnectionFields(type);
    final widgets = <Widget>[];
    final processedFields = <String>{};

    // 合并主机地址和端口字段
    if (fields.contains('hosts') && fields.contains('port')) {
      widgets.add(_buildCombinedHostPortField());
      processedFields.addAll(['hosts', 'port']);
    } else if (fields.contains('host') && fields.contains('port')) {
      widgets.add(_buildCombinedHostPortField(isSingleHost: true));
      processedFields.addAll(['host', 'port']);
    }

    // 处理其他字段
    for (final field in fields) {
      if (!processedFields.contains(field)) {
        widgets.add(_buildConnectionField(field));
      }
    }

    return widgets;
  }

  Widget _buildCombinedHostPortField({bool isSingleHost = false}) {
    final theme = Theme.of(context);
    final hostKey = isSingleHost ? 'host' : 'hosts';

    // 确保多地址控制器存在
    if (!isSingleHost && !_multiAddressControllers.containsKey(hostKey)) {
      _multiAddressControllers[hostKey] = [TextEditingController()];
    }

    final hostControllers = isSingleHost
        ? [_connectionControllers[hostKey] ?? TextEditingController()]
        : _multiAddressControllers[hostKey] ?? [TextEditingController()];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '服务器连接',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (!isSingleHost)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _multiAddressControllers[hostKey]!.add(
                        TextEditingController(),
                      );
                    });
                  },
                  icon: Icon(
                    Icons.add,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  tooltip: '添加服务器地址',
                ),
            ],
          ),
          const SizedBox(height: 12),
          // 主机地址输入框列表
          ...hostControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      style: theme.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        labelText: isSingleHost ? '主机地址' : '服务器地址 ${index + 1}',
                        hintText: '例如: 192.168.1.33',
                        prefixIcon: const Icon(Icons.computer),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (index == 0 &&
                            (value == null || value.trim().isEmpty)) {
                          return '请至少输入一个服务器地址';
                        }
                        return null;
                      },
                    ),
                  ),
                  if (!isSingleHost && hostControllers.length > 1)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          controller.dispose();
                          _multiAddressControllers[hostKey]!.removeAt(index);
                        });
                      },
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      tooltip: '删除地址',
                    ),
                ],
              ),
            );
          }),
          if (!isSingleHost) ...[
            const SizedBox(height: 8),
            Text(
              '提示：每个输入框输入一个服务器地址，支持动态添加多个地址',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMultiAddressField(String field) {
    final theme = Theme.of(context);
    final controllers =
        _multiAddressControllers[field] ?? [TextEditingController()];

    if (_multiAddressControllers[field] == null) {
      _multiAddressControllers[field] = controllers;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getFieldIcon(field),
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getFieldLabel(field),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _multiAddressControllers[field]!.add(
                      TextEditingController(),
                    );
                  });
                },
                icon: Icon(
                  Icons.add,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                tooltip: '添加地址',
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...controllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      style: theme.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        labelText: '地址 ${index + 1}',
                        hintText: _getFieldHint(field),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (index == 0 &&
                            (value == null || value.trim().isEmpty)) {
                          return '请至少输入一个地址';
                        }
                        return null;
                      },
                    ),
                  ),
                  if (controllers.length > 1)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          controller.dispose();
                          _multiAddressControllers[field]!.removeAt(index);
                        });
                      },
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      tooltip: '删除地址',
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildConnectionField(String field) {
    final theme = Theme.of(context);

    // 判断是否为多地址字段
    final isMultiAddressField =
        field == 'hosts' ||
        field == 'endpoints' ||
        field == 'bootstrap_servers' ||
        field == 'upstream_servers';

    if (isMultiAddressField) {
      return _buildMultiAddressField(field);
    }

    final controller = _connectionControllers[field] ?? TextEditingController();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: _getFieldLabel(field),
          hintText: _getFieldHint(field),
          prefixIcon: Icon(_getFieldIcon(field)),
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
        ),
        obscureText: field == 'password',
        validator: (value) {
          if (field == 'database' || field == 'topic') {
            if (value == null || value.trim().isEmpty) {
              return '请输入${_getFieldLabel(field)}';
            }
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 中间件名称
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: '中间件名称',
                  hintText: '输入中间件名称',
                  prefixIcon: Icon(Icons.storage),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入中间件名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 中间件类型
              DropdownButtonFormField<MiddlewareType>(
                initialValue: _type,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: '中间件类型',
                  prefixIcon: Icon(Icons.category),
                ),
                items: MiddlewareType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getMiddlewareTypeName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _type = value;
                      _initializeConnectionFields();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 版本
              TextFormField(
                controller: _versionController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: '版本',
                  hintText: '输入版本号',
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入版本号';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 描述
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: '描述',
                  hintText: '输入中间件描述',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // 连接信息
              Text(
                '连接信息',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ..._buildOptimizedConnectionFields(_type),
            ],
          ),
        ),
      ),
    );
  }

  String _getMiddlewareTypeName(MiddlewareType type) {
    switch (type) {
      case MiddlewareType.mysql:
        return 'MySQL';
      case MiddlewareType.postgresql:
        return 'PostgreSQL';
      case MiddlewareType.mongodb:
        return 'MongoDB';
      case MiddlewareType.redis:
        return 'Redis';
      case MiddlewareType.elasticsearch:
        return 'Elasticsearch';
      case MiddlewareType.kafka:
        return 'Kafka';
      case MiddlewareType.rabbitmq:
        return 'RabbitMQ';
      case MiddlewareType.etcd:
        return 'etcd';
      case MiddlewareType.nginx:
        return 'Nginx';
      case MiddlewareType.docker:
        return 'Docker';
    }
  }

  String _getFieldLabel(String field) {
    switch (field) {
      case 'host':
        return '主机地址';
      case 'port':
        return '端口';
      case 'database':
        return '数据库名';
      case 'username':
        return '用户名';
      case 'password':
        return '密码';
      case 'index':
        return '索引';
      case 'bootstrap_servers':
        return 'Bootstrap服务器';
      case 'topic':
        return '主题';
      case 'group_id':
        return '组ID';
      case 'vhost':
        return '虚拟主机';
      case 'endpoints':
        return '端点';
      case 'config_path':
        return '配置路径';
      case 'registry':
        return '镜像仓库';
      default:
        return field;
    }
  }

  String _getFieldHint(String field) {
    switch (field) {
      case 'host':
        return '例如: localhost';
      case 'port':
        return '例如: 3306';
      case 'database':
        return '例如: mydb';
      case 'username':
        return '例如: admin';
      case 'password':
        return '输入密码';
      case 'index':
        return '例如: logs';
      case 'bootstrap_servers':
        return '例如: localhost:9092';
      case 'topic':
        return '例如: my-topic';
      case 'group_id':
        return '例如: my-group';
      case 'vhost':
        return '例如: /';
      case 'endpoints':
        return '例如: localhost:2379';
      case 'config_path':
        return '例如: /etc/nginx/nginx.conf';
      case 'registry':
        return '例如: docker.io';
      default:
        return '输入${_getFieldLabel(field)}';
    }
  }

  IconData _getFieldIcon(String field) {
    switch (field) {
      case 'host':
        return Icons.computer;
      case 'port':
        return Icons.settings_ethernet;
      case 'database':
      case 'index':
        return Icons.storage;
      case 'username':
        return Icons.person;
      case 'password':
        return Icons.lock;
      case 'bootstrap_servers':
      case 'endpoints':
        return Icons.dns;
      case 'topic':
        return Icons.topic;
      case 'group_id':
        return Icons.group;
      case 'vhost':
        return Icons.home;
      case 'config_path':
        return Icons.folder;
      case 'registry':
        return Icons.cloud;
      default:
        return Icons.settings;
    }
  }
}
