/// Event Pass Model - Represents a Verifiable Credential for event tickets
class EventPass {
  final String id;
  final String eventName;
  final String eventDescription;
  final DateTime eventDate;
  final String venue;
  final String seatZone;
  final String ticketId;
  final String organizerDID;
  final String organizerName;
  final String holderDID;
  final String credentialType;
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final bool isUsed;
  final DateTime? usedAt;
  final String? qrData;
  final PassStatus status;
  final String? imageUrl;

  EventPass({
    required this.id,
    required this.eventName,
    required this.eventDescription,
    required this.eventDate,
    required this.venue,
    required this.seatZone,
    required this.ticketId,
    required this.organizerDID,
    required this.organizerName,
    required this.holderDID,
    required this.credentialType,
    required this.issuedAt,
    this.expiresAt,
    this.isUsed = false,
    this.usedAt,
    this.qrData,
    this.status = PassStatus.active,
    this.imageUrl,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventName': eventName,
      'eventDescription': eventDescription,
      'eventDate': eventDate.toIso8601String(),
      'venue': venue,
      'seatZone': seatZone,
      'ticketId': ticketId,
      'organizerDID': organizerDID,
      'organizerName': organizerName,
      'holderDID': holderDID,
      'credentialType': credentialType,
      'issuedAt': issuedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isUsed': isUsed,
      'usedAt': usedAt?.toIso8601String(),
      'qrData': qrData,
      'status': status.toString(),
      'imageUrl': imageUrl,
    };
  }

  // Create from JSON
  factory EventPass.fromJson(Map<String, dynamic> json) {
    return EventPass(
      id: json['id'] as String,
      eventName: json['eventName'] as String,
      eventDescription: json['eventDescription'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      venue: json['venue'] as String,
      seatZone: json['seatZone'] as String,
      ticketId: json['ticketId'] as String,
      organizerDID: json['organizerDID'] as String,
      organizerName: json['organizerName'] as String,
      holderDID: json['holderDID'] as String,
      credentialType: json['credentialType'] as String,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isUsed: json['isUsed'] as bool? ?? false,
      usedAt: json['usedAt'] != null
          ? DateTime.parse(json['usedAt'] as String)
          : null,
      qrData: json['qrData'] as String?,
      status: _parseStatus(json['status'] as String?),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  static PassStatus _parseStatus(String? status) {
    if (status == null) return PassStatus.active;
    return PassStatus.values.firstWhere(
      (e) => e.toString() == status,
      orElse: () => PassStatus.active,
    );
  }

  // Copy with method for updates
  EventPass copyWith({
    String? id,
    String? eventName,
    String? eventDescription,
    DateTime? eventDate,
    String? venue,
    String? seatZone,
    String? ticketId,
    String? organizerDID,
    String? organizerName,
    String? holderDID,
    String? credentialType,
    DateTime? issuedAt,
    DateTime? expiresAt,
    bool? isUsed,
    DateTime? usedAt,
    String? qrData,
    PassStatus? status,
    String? imageUrl,
  }) {
    return EventPass(
      id: id ?? this.id,
      eventName: eventName ?? this.eventName,
      eventDescription: eventDescription ?? this.eventDescription,
      eventDate: eventDate ?? this.eventDate,
      venue: venue ?? this.venue,
      seatZone: seatZone ?? this.seatZone,
      ticketId: ticketId ?? this.ticketId,
      organizerDID: organizerDID ?? this.organizerDID,
      organizerName: organizerName ?? this.organizerName,
      holderDID: holderDID ?? this.holderDID,
      credentialType: credentialType ?? this.credentialType,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isUsed: isUsed ?? this.isUsed,
      usedAt: usedAt ?? this.usedAt,
      qrData: qrData ?? this.qrData,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // Check if pass is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // Check if pass is valid for use
  bool get isValid {
    return !isUsed && !isExpired && status == PassStatus.active;
  }
}

/// Pass Status Enum
enum PassStatus { active, used, expired, revoked }
