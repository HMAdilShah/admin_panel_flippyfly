class SupportTicket {
  final String avatarUrl;
  final String description;
  final String email;
  final String name;
  final String status;
  final DateTime timestamp;
  final String topic;

  SupportTicket({
    required this.avatarUrl,
    required this.description,
    required this.email,
    required this.name,
    required this.status,
    required this.timestamp,
    required this.topic,
  });

  // Factory constructor to create from Map (e.g., from Firestore)
  factory SupportTicket.fromMap(Map<String, dynamic> map) {
    return SupportTicket(
      avatarUrl: map['avatarUrl'] ?? '',
      description: map['description'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      status: map['status'] ?? '',
      timestamp: map['timestamp'] is DateTime
          ? map['timestamp']
          : DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      topic: map['topic'] ?? '',
    );
  }

  // Convert to JSON/map
  Map<String, dynamic> toJson() {
    return {
      'avatarUrl': avatarUrl,
      'description': description,
      'email': email,
      'name': name,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'topic': topic,
    };
  }

  // Create a copy with optional field overrides
  SupportTicket copyWith({
    String? avatarUrl,
    String? description,
    String? email,
    String? name,
    String? status,
    DateTime? timestamp,
    String? topic,
  }) {
    return SupportTicket(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      description: description ?? this.description,
      email: email ?? this.email,
      name: name ?? this.name,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      topic: topic ?? this.topic,
    );
  }
}
