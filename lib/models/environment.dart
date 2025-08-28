enum EnvironmentType { development, testing, staging, production }

class Environment {
  final String id;
  final String name;
  final EnvironmentType type;
  final String url;
  final Map<String, String> variables;
  final String description;
  final bool isActive;
  final DateTime createdAt;

  Environment({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.variables,
    this.description = '',
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Environment copyWith({
    String? id,
    String? name,
    EnvironmentType? type,
    String? url,
    Map<String, String>? variables,
    String? description,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Environment(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      url: url ?? this.url,
      variables: variables ?? this.variables,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'url': url,
      'variables': variables,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Environment.fromJson(Map<String, dynamic> json) {
    return Environment(
      id: json['id'],
      name: json['name'],
      type: EnvironmentType.values.firstWhere((e) => e.name == json['type']),
      url: json['url'],
      variables: Map<String, String>.from(json['variables']),
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
