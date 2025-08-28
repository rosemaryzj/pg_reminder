enum MiddlewareType {
  mysql,
  mongodb,
  elasticsearch,
  redis,
  kafka,
  etcd,
  postgresql,
  rabbitmq,
  nginx,
  docker,
}

class Middleware {
  final String id;
  final String name;
  final MiddlewareType type;
  final String version;
  final Map<String, dynamic> connectionInfo;
  final String description;
  final DateTime createdAt;

  Middleware({
    required this.id,
    required this.name,
    required this.type,
    required this.version,
    required this.connectionInfo,
    this.description = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Middleware copyWith({
    String? id,
    String? name,
    MiddlewareType? type,
    String? version,
    Map<String, dynamic>? connectionInfo,
    String? description,
    DateTime? createdAt,
  }) {
    return Middleware(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      version: version ?? this.version,
      connectionInfo: connectionInfo ?? this.connectionInfo,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'version': version,
      'connectionInfo': connectionInfo,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Middleware.fromJson(Map<String, dynamic> json) {
    return Middleware(
      id: json['id'],
      name: json['name'],
      type: MiddlewareType.values.firstWhere((e) => e.name == json['type']),
      version: json['version'],
      connectionInfo: Map<String, dynamic>.from(json['connectionInfo']),
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
