/// User Role Enum
enum UserRole {
  attendee, // Ticket holder
  organizer, // Event creator & issuer
  verifier, // Gate authority
}

/// User Profile Model
class UserProfile {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String did;
  final DateTime createdAt;
  final String? organizationName;
  final String? organizationDID;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.did,
    required this.createdAt,
    this.organizationName,
    this.organizationDID,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString(),
      'did': did,
      'createdAt': createdAt.toIso8601String(),
      'organizationName': organizationName,
      'organizationDID': organizationDID,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: _parseRole(json['role'] as String),
      did: json['did'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      organizationName: json['organizationName'] as String?,
      organizationDID: json['organizationDID'] as String?,
    );
  }

  static UserRole _parseRole(String role) {
    return UserRole.values.firstWhere(
      (e) => e.toString() == role,
      orElse: () => UserRole.attendee,
    );
  }

  bool get isOrganizer => role == UserRole.organizer;
  bool get isVerifier => role == UserRole.verifier;
  bool get isAttendee => role == UserRole.attendee;

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? did,
    DateTime? createdAt,
    String? organizationName,
    String? organizationDID,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      did: did ?? this.did,
      createdAt: createdAt ?? this.createdAt,
      organizationName: organizationName ?? this.organizationName,
      organizationDID: organizationDID ?? this.organizationDID,
    );
  }
}
