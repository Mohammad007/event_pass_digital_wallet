import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/event_pass.dart';

/// Credential Service - Manages Verifiable Credentials (Event Passes)
class CredentialService {
  static final CredentialService _instance = CredentialService._internal();
  factory CredentialService() => _instance;
  CredentialService._internal();

  Database? _database;

  /// Initialize database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/event_passes.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE event_passes (
            id TEXT PRIMARY KEY,
            eventName TEXT NOT NULL,
            eventDescription TEXT NOT NULL,
            eventDate TEXT NOT NULL,
            venue TEXT NOT NULL,
            seatZone TEXT NOT NULL,
            ticketId TEXT NOT NULL,
            organizerDID TEXT NOT NULL,
            organizerName TEXT NOT NULL,
            holderDID TEXT NOT NULL,
            credentialType TEXT NOT NULL,
            issuedAt TEXT NOT NULL,
            expiresAt TEXT,
            isUsed INTEGER NOT NULL DEFAULT 0,
            usedAt TEXT,
            qrData TEXT,
            status TEXT NOT NULL,
            imageUrl TEXT
          )
        ''');
      },
    );
  }

  /// Save event pass
  Future<void> savePass(EventPass pass) async {
    final db = await database;
    await db.insert(
      'event_passes',
      _passToMap(pass),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all passes
  Future<List<EventPass>> getAllPasses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'event_passes',
      orderBy: 'eventDate DESC',
    );

    return List.generate(maps.length, (i) => _mapToPass(maps[i]));
  }

  /// Get pass by ID
  Future<EventPass?> getPassById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'event_passes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _mapToPass(maps.first);
  }

  /// Get upcoming passes
  Future<List<EventPass>> getUpcomingPasses() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'event_passes',
      where: 'eventDate >= ? AND status = ?',
      whereArgs: [now, PassStatus.active.toString()],
      orderBy: 'eventDate ASC',
    );

    return List.generate(maps.length, (i) => _mapToPass(maps[i]));
  }

  /// Get past passes
  Future<List<EventPass>> getPastPasses() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'event_passes',
      where: 'eventDate < ? OR status = ? OR status = ?',
      whereArgs: [
        now,
        PassStatus.used.toString(),
        PassStatus.expired.toString(),
      ],
      orderBy: 'eventDate DESC',
    );

    return List.generate(maps.length, (i) => _mapToPass(maps[i]));
  }

  /// Update pass
  Future<void> updatePass(EventPass pass) async {
    final db = await database;
    await db.update(
      'event_passes',
      _passToMap(pass),
      where: 'id = ?',
      whereArgs: [pass.id],
    );
  }

  /// Mark pass as used
  Future<void> markPassAsUsed(String passId) async {
    final pass = await getPassById(passId);
    if (pass == null) return;

    final updatedPass = pass.copyWith(
      isUsed: true,
      usedAt: DateTime.now(),
      status: PassStatus.used,
    );

    await updatePass(updatedPass);
  }

  /// Delete pass
  Future<void> deletePass(String id) async {
    final db = await database;
    await db.delete('event_passes', where: 'id = ?', whereArgs: [id]);
  }

  /// Generate QR data for pass
  String generateQRData(EventPass pass) {
    final qrPayload = {
      'passId': pass.id,
      'ticketId': pass.ticketId,
      'holderDID': pass.holderDID,
      'eventName': pass.eventName,
      'eventDate': pass.eventDate.toIso8601String(),
      'timestamp': DateTime.now().toIso8601String(),
      // In production, add cryptographic signature here
    };

    return jsonEncode(qrPayload);
  }

  /// Verify QR data
  Future<bool> verifyQRData(String qrData) async {
    try {
      final data = jsonDecode(qrData);
      final passId = data['passId'] as String;

      final pass = await getPassById(passId);
      if (pass == null) return false;

      // Check if pass is valid
      if (!pass.isValid) return false;

      // In production, verify cryptographic signature here

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Convert EventPass to Map
  Map<String, dynamic> _passToMap(EventPass pass) {
    return {
      'id': pass.id,
      'eventName': pass.eventName,
      'eventDescription': pass.eventDescription,
      'eventDate': pass.eventDate.toIso8601String(),
      'venue': pass.venue,
      'seatZone': pass.seatZone,
      'ticketId': pass.ticketId,
      'organizerDID': pass.organizerDID,
      'organizerName': pass.organizerName,
      'holderDID': pass.holderDID,
      'credentialType': pass.credentialType,
      'issuedAt': pass.issuedAt.toIso8601String(),
      'expiresAt': pass.expiresAt?.toIso8601String(),
      'isUsed': pass.isUsed ? 1 : 0,
      'usedAt': pass.usedAt?.toIso8601String(),
      'qrData': pass.qrData,
      'status': pass.status.toString(),
      'imageUrl': pass.imageUrl,
    };
  }

  /// Convert Map to EventPass
  EventPass _mapToPass(Map<String, dynamic> map) {
    return EventPass(
      id: map['id'] as String,
      eventName: map['eventName'] as String,
      eventDescription: map['eventDescription'] as String,
      eventDate: DateTime.parse(map['eventDate'] as String),
      venue: map['venue'] as String,
      seatZone: map['seatZone'] as String,
      ticketId: map['ticketId'] as String,
      organizerDID: map['organizerDID'] as String,
      organizerName: map['organizerName'] as String,
      holderDID: map['holderDID'] as String,
      credentialType: map['credentialType'] as String,
      issuedAt: DateTime.parse(map['issuedAt'] as String),
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expiresAt'] as String)
          : null,
      isUsed: map['isUsed'] == 1,
      usedAt: map['usedAt'] != null
          ? DateTime.parse(map['usedAt'] as String)
          : null,
      qrData: map['qrData'] as String?,
      status: _parseStatus(map['status'] as String),
      imageUrl: map['imageUrl'] as String?,
    );
  }

  PassStatus _parseStatus(String status) {
    return PassStatus.values.firstWhere(
      (e) => e.toString() == status,
      orElse: () => PassStatus.active,
    );
  }
}
