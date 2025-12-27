/// Event Model for Organizers
class EventModel {
  final String id;
  final String name;
  final String description;
  final String venue;
  final String address;
  final DateTime startTime;
  final DateTime endTime;
  final String organizerDID;
  final String organizerName;
  final int totalTickets;
  final int issuedTickets;
  final int usedTickets;
  final EventStatus status;
  final DateTime createdAt;
  final String? imageUrl;
  final Map<String, int>?
  ticketCategories; // e.g., {"VIP": 100, "General": 500}

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.venue,
    required this.address,
    required this.startTime,
    required this.endTime,
    required this.organizerDID,
    required this.organizerName,
    required this.totalTickets,
    this.issuedTickets = 0,
    this.usedTickets = 0,
    this.status = EventStatus.draft,
    required this.createdAt,
    this.imageUrl,
    this.ticketCategories,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'venue': venue,
      'address': address,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'organizerDID': organizerDID,
      'organizerName': organizerName,
      'totalTickets': totalTickets,
      'issuedTickets': issuedTickets,
      'usedTickets': usedTickets,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
      'ticketCategories': ticketCategories,
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      venue: json['venue'] as String,
      address: json['address'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      organizerDID: json['organizerDID'] as String,
      organizerName: json['organizerName'] as String,
      totalTickets: json['totalTickets'] as int,
      issuedTickets: json['issuedTickets'] as int? ?? 0,
      usedTickets: json['usedTickets'] as int? ?? 0,
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageUrl: json['imageUrl'] as String?,
      ticketCategories: json['ticketCategories'] != null
          ? Map<String, int>.from(json['ticketCategories'])
          : null,
    );
  }

  static EventStatus _parseStatus(String status) {
    return EventStatus.values.firstWhere(
      (e) => e.toString() == status,
      orElse: () => EventStatus.draft,
    );
  }

  EventModel copyWith({
    String? id,
    String? name,
    String? description,
    String? venue,
    String? address,
    DateTime? startTime,
    DateTime? endTime,
    String? organizerDID,
    String? organizerName,
    int? totalTickets,
    int? issuedTickets,
    int? usedTickets,
    EventStatus? status,
    DateTime? createdAt,
    String? imageUrl,
    Map<String, int>? ticketCategories,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      venue: venue ?? this.venue,
      address: address ?? this.address,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      organizerDID: organizerDID ?? this.organizerDID,
      organizerName: organizerName ?? this.organizerName,
      totalTickets: totalTickets ?? this.totalTickets,
      issuedTickets: issuedTickets ?? this.issuedTickets,
      usedTickets: usedTickets ?? this.usedTickets,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      ticketCategories: ticketCategories ?? this.ticketCategories,
    );
  }

  bool get isActive => status == EventStatus.active;
  bool get canIssueTickets => issuedTickets < totalTickets && isActive;
  int get availableTickets => totalTickets - issuedTickets;
  double get utilizationRate =>
      issuedTickets > 0 ? (usedTickets / issuedTickets) * 100 : 0;
}

enum EventStatus { draft, active, completed, cancelled }
