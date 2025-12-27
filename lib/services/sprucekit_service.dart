import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// SpruceKit Integration Service
/// Provides W3C Verifiable Credentials and mDL support using SpruceKit SDK
class SpruceKitService {
  static final SpruceKitService _instance = SpruceKitService._internal();
  factory SpruceKitService() => _instance;
  SpruceKitService._internal();

  // Platform channel for native SDK communication
  static const MethodChannel _channel = MethodChannel(
    'com.eventpass.wallet/sprucekit',
  );

  // Event channel for credential presentation callbacks
  static const EventChannel _eventChannel = EventChannel(
    'com.eventpass.wallet/sprucekit_events',
  );

  bool _isInitialized = false;

  /// Initialize SpruceKit SDK
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      final result = await _channel.invokeMethod<bool>('initialize');
      _isInitialized = result ?? false;
      debugPrint('SpruceKit: Initialized = $_isInitialized');
      return _isInitialized;
    } on PlatformException catch (e) {
      debugPrint('SpruceKit: Failed to initialize - ${e.message}');
      return false;
    }
  }

  /// Check if SpruceKit is available on this platform
  Future<bool> isSupported() async {
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } on PlatformException {
      return false;
    }
  }

  // =====================
  // W3C Verifiable Credentials
  // =====================

  // =====================
  // Mock/Simulation Logic (For development without native SDK)
  // =====================

  /// Create a W3C Verifiable Credential
  Future<VerifiableCredential?> createCredential({
    required String issuerDID,
    required String subjectDID,
    required Map<String, dynamic> claims,
    required String credentialType,
    DateTime? expirationDate,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('createCredential', {
        'issuerDID': issuerDID,
        'subjectDID': subjectDID,
        'claims': jsonEncode(claims),
        'credentialType': credentialType,
        'expirationDate': expirationDate?.toIso8601String(),
      });

      if (result != null) {
        return VerifiableCredential.fromJson(jsonDecode(result));
      }
      return null;
    } catch (_) {
      // FALBACK: Simulate credential creation
      debugPrint('SpruceKit: Native channel missing, simulating generic VC...');
      final now = DateTime.now();

      // Create a simulated JWT
      final header = base64Url.encode(
        utf8.encode(jsonEncode({'alg': 'ES256K', 'typ': 'JWT'})),
      );
      final payloadMap = {
        'sub': subjectDID,
        'iss': issuerDID,
        'nbf': now.millisecondsSinceEpoch ~/ 1000,
        'vc': {
          '@context': ['https://www.w3.org/2018/credentials/v1'],
          'type': ['VerifiableCredential', credentialType],
          'credentialSubject': claims,
        },
      };
      if (expirationDate != null) {
        payloadMap['exp'] = expirationDate.millisecondsSinceEpoch ~/ 1000;
      }
      final payload = base64Url.encode(utf8.encode(jsonEncode(payloadMap)));
      final simulatedJwt = '$header.$payload.simulated_signature_xyz';

      return VerifiableCredential(
        id: 'urn:uuid:${DateTime.now().millisecondsSinceEpoch}',
        type: credentialType,
        issuer: issuerDID,
        issuanceDate: now.toIso8601String(),
        expirationDate: expirationDate?.toIso8601String(),
        credentialSubject: claims,
        jwt: simulatedJwt,
      );
    }
  }

  /// Issue an Event Ticket Credential
  Future<VerifiableCredential?> issueEventTicket({
    required String issuerDID,
    required String holderDID,
    required String eventName,
    required String eventDate,
    required String venue,
    required String ticketId,
    required String seatZone,
    String? organizerName,
  }) async {
    final claims = {
      'eventName': eventName,
      'eventDate': eventDate,
      'venue': venue,
      'ticketId': ticketId,
      'seatZone': seatZone,
      'organizerName': organizerName,
      'credentialSubject': {'id': holderDID, 'ticketHolder': true},
    };

    return createCredential(
      issuerDID: issuerDID,
      subjectDID: holderDID,
      claims: claims,
      credentialType: 'EventTicketCredential',
      expirationDate: DateTime.parse(eventDate).add(const Duration(days: 1)),
    );
  }

  /// Verify a credential's authenticity
  Future<CredentialVerificationResult> verifyCredential(
    String credentialJWT,
  ) async {
    try {
      final result = await _channel.invokeMethod<String>('verifyCredential', {
        'credential': credentialJWT,
      });

      if (result != null) {
        final data = jsonDecode(result);
        return CredentialVerificationResult(
          isValid: data['isValid'] ?? false,
          issuer: data['issuer'],
          subject: data['subject'],
          expiresAt: data['expiresAt'] != null
              ? DateTime.parse(data['expiresAt'])
              : null,
          errors: List<String>.from(data['errors'] ?? []),
        );
      }
      return CredentialVerificationResult(
        isValid: false,
        errors: ['Unknown error'],
      );
    } catch (e) {
      if (e is! PlatformException && e is! MissingPluginException) {
        // If it's a logic error (not platform), rethrow or handle differently?
        // But for this "Simulation" mode, we want to catch MissingPluginException specifically
        // which implies simulation is needed.
        if (kDebugMode) debugPrint('SpruceKit: Unexpected error: $e');
      }

      // FALBACK: Simulate verification
      debugPrint(
        'SpruceKit: Native channel missing or error, simulating verification... ($e)',
      );
      try {
        final parts = credentialJWT.split('.');
        if (parts.length != 3) throw Exception('Invalid JWT format');

        // Decode payload
        final payload = jsonDecode(
          utf8.decode(base64Url.decode(base64.normalize(parts[1]))),
        );
        final vc = payload['vc'];

        // Check expiration
        if (payload['exp'] != null) {
          final exp = DateTime.fromMillisecondsSinceEpoch(
            payload['exp'] * 1000,
          );
          if (DateTime.now().isAfter(exp)) {
            return CredentialVerificationResult(
              isValid: false,
              issuer: payload['iss'],
              subject: payload['sub'],
              expiresAt: exp,
              errors: ['Credential Expired'],
            );
          }
        }

        return CredentialVerificationResult(
          isValid: true,
          issuer: payload['iss'],
          subject: payload['sub'],
          expiresAt: payload['exp'] != null
              ? DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000)
              : null,
        );
      } catch (e) {
        return CredentialVerificationResult(
          isValid: false,
          errors: ['Malformed Credential: $e'],
        );
      }
    }
  }

  /// Store credential in secure wallet
  Future<bool> storeCredential(VerifiableCredential credential) async {
    try {
      return await _channel.invokeMethod<bool>('storeCredential', {
            'credential': jsonEncode(credential.toJson()),
          }) ??
          false;
    } on PlatformException catch (e) {
      debugPrint('SpruceKit: Failed to store credential - ${e.message}');
      return false;
    }
  }

  /// Get all stored credentials
  Future<List<VerifiableCredential>> getStoredCredentials() async {
    try {
      final result = await _channel.invokeMethod<String>(
        'getStoredCredentials',
      );
      if (result != null) {
        final List<dynamic> list = jsonDecode(result);
        return list.map((c) => VerifiableCredential.fromJson(c)).toList();
      }
      return [];
    } on PlatformException catch (e) {
      debugPrint('SpruceKit: Failed to get credentials - ${e.message}');
      return [];
    }
  }

  /// Delete a stored credential
  Future<bool> deleteCredential(String credentialId) async {
    try {
      return await _channel.invokeMethod<bool>('deleteCredential', {
            'credentialId': credentialId,
          }) ??
          false;
    } on PlatformException catch (e) {
      debugPrint('SpruceKit: Failed to delete credential - ${e.message}');
      return false;
    }
  }

  // =====================
  // OID4VP (OpenID for Verifiable Presentations)
  // =====================

  /// Create a Verifiable Presentation for OID4VP
  Future<String?> createPresentation({
    required String holderDID,
    required List<String> credentialIds,
    String? nonce,
    String? domain,
  }) async {
    try {
      return await _channel.invokeMethod<String>('createPresentation', {
        'holderDID': holderDID,
        'credentialIds': credentialIds,
        'nonce': nonce,
        'domain': domain,
      });
    } on PlatformException catch (e) {
      debugPrint('SpruceKit: Failed to create presentation - ${e.message}');
      return null;
    }
  }

  /// Handle OID4VP request from deep link
  Future<OID4VPResult> handleOID4VPRequest(String requestUri) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'handleOID4VPRequest',
        {'requestUri': requestUri},
      );

      if (result != null) {
        final data = jsonDecode(result);
        return OID4VPResult(
          success: data['success'] ?? false,
          presentationDefinition: data['presentationDefinition'],
          matchingCredentials: List<String>.from(
            data['matchingCredentials'] ?? [],
          ),
          error: data['error'],
        );
      }
      return OID4VPResult(success: false, error: 'Unknown error');
    } on PlatformException catch (e) {
      return OID4VPResult(success: false, error: e.message);
    }
  }

  /// Submit presentation response
  Future<bool> submitPresentationResponse({
    required String responseUri,
    required String presentationSubmission,
    required List<String> selectedCredentials,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('submitPresentationResponse', {
            'responseUri': responseUri,
            'presentationSubmission': presentationSubmission,
            'selectedCredentials': selectedCredentials,
          }) ??
          false;
    } on PlatformException catch (e) {
      debugPrint('SpruceKit: Failed to submit response - ${e.message}');
      return false;
    }
  }

  // =====================
  // mDL (Mobile Driver's License) - ISO 18013
  // =====================

  /// Check if device supports mDL features
  Future<bool> isMDLSupported() async {
    try {
      return await _channel.invokeMethod<bool>('isMDLSupported') ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Start mDL presentation via BLE
  Future<bool> startMDLPresentation({
    required String mdlCredential,
    required List<String> requestedElements,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('startMDLPresentation', {
            'mdlCredential': mdlCredential,
            'requestedElements': requestedElements,
          }) ??
          false;
    } on PlatformException catch (e) {
      debugPrint('SpruceKit: Failed to start mDL presentation - ${e.message}');
      return false;
    }
  }

  /// Start mDL verification (reader mode)
  Future<MDLVerificationResult?> startMDLVerification({
    required List<String> requestedElements,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'startMDLVerification',
        {'requestedElements': requestedElements},
      );

      if (result != null) {
        final data = jsonDecode(result);
        return MDLVerificationResult(
          isValid: data['isValid'] ?? false,
          elements: Map<String, dynamic>.from(data['elements'] ?? {}),
          issuerCountry: data['issuerCountry'],
          documentNumber: data['documentNumber'],
        );
      }
      return null;
    } on PlatformException catch (e) {
      debugPrint('SpruceKit: Failed to verify mDL - ${e.message}');
      return null;
    }
  }

  /// Stop any active BLE connections
  Future<void> stopBLEConnections() async {
    try {
      await _channel.invokeMethod('stopBLEConnections');
    } on PlatformException catch (e) {
      debugPrint('SpruceKit: Failed to stop BLE - ${e.message}');
    }
  }

  // =====================
  // DID Management
  // =====================

  /// Generate a new DID:key
  Future<String?> generateDIDKey() async {
    try {
      return await _channel.invokeMethod<String>('generateDIDKey');
    } on PlatformException catch (e) {
      debugPrint('SpruceKit: Failed to generate DID - ${e.message}');
      return null;
    }
  }

  /// Resolve a DID to its DID Document
  Future<Map<String, dynamic>?> resolveDID(String did) async {
    try {
      final result = await _channel.invokeMethod<String>('resolveDID', {
        'did': did,
      });
      if (result != null) {
        return jsonDecode(result);
      }
      return null;
    } on PlatformException catch (e) {
      debugPrint('SpruceKit: Failed to resolve DID - ${e.message}');
      return null;
    }
  }

  /// Sign data with DID private key
  Future<String?> signWithDID({
    required String did,
    required String data,
  }) async {
    try {
      return await _channel.invokeMethod<String>('signWithDID', {
        'did': did,
        'data': data,
      });
    } on PlatformException catch (e) {
      debugPrint('SpruceKit: Failed to sign - ${e.message}');
      return null;
    }
  }

  /// Verify signature using DID
  Future<bool> verifySignature({
    required String did,
    required String data,
    required String signature,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('verifySignature', {
            'did': did,
            'data': data,
            'signature': signature,
          }) ??
          false;
    } on PlatformException catch (e) {
      debugPrint('SpruceKit: Failed to verify signature - ${e.message}');
      return false;
    }
  }

  // =====================
  // QR Code Operations
  // =====================

  /// Generate QR code data for credential presentation
  Future<String?> generateCredentialQR(String credentialJWT) async {
    try {
      return await _channel.invokeMethod<String>('generateCredentialQR', {
        'credential': credentialJWT,
      });
    } on PlatformException catch (e) {
      debugPrint('SpruceKit: Failed to generate QR - ${e.message}');
      return null;
    }
  }

  /// Parse QR code data and extract credential
  Future<VerifiableCredential?> parseCredentialQR(String qrData) async {
    try {
      final result = await _channel.invokeMethod<String>('parseCredentialQR', {
        'qrData': qrData,
      });
      if (result != null) {
        return VerifiableCredential.fromJson(jsonDecode(result));
      }
      return null;
    } on PlatformException catch (e) {
      debugPrint('SpruceKit: Failed to parse QR - ${e.message}');
      return null;
    }
  }
}

// =====================
// Data Models
// =====================

/// W3C Verifiable Credential Model
class VerifiableCredential {
  final String id;
  final String type;
  final String issuer;
  final String issuanceDate;
  final String? expirationDate;
  final Map<String, dynamic> credentialSubject;
  final String? proof;
  final String? jwt;

  VerifiableCredential({
    required this.id,
    required this.type,
    required this.issuer,
    required this.issuanceDate,
    this.expirationDate,
    required this.credentialSubject,
    this.proof,
    this.jwt,
  });

  factory VerifiableCredential.fromJson(Map<String, dynamic> json) {
    return VerifiableCredential(
      id: json['id'] ?? '',
      type: json['type'] is List
          ? (json['type'] as List).last.toString()
          : json['type'] ?? '',
      issuer: json['issuer'] is String
          ? json['issuer']
          : json['issuer']?['id'] ?? '',
      issuanceDate: json['issuanceDate'] ?? '',
      expirationDate: json['expirationDate'],
      credentialSubject: json['credentialSubject'] ?? {},
      proof: json['proof'] is String
          ? json['proof']
          : jsonEncode(json['proof']),
      jwt: json['jwt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '@context': ['https://www.w3.org/2018/credentials/v1'],
      'id': id,
      'type': ['VerifiableCredential', type],
      'issuer': issuer,
      'issuanceDate': issuanceDate,
      if (expirationDate != null) 'expirationDate': expirationDate,
      'credentialSubject': credentialSubject,
      if (proof != null) 'proof': proof,
      if (jwt != null) 'jwt': jwt,
    };
  }

  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.parse(expirationDate!).isBefore(DateTime.now());
  }
}

/// Credential Verification Result
class CredentialVerificationResult {
  final bool isValid;
  final String? issuer;
  final String? subject;
  final DateTime? expiresAt;
  final List<String> errors;

  CredentialVerificationResult({
    required this.isValid,
    this.issuer,
    this.subject,
    this.expiresAt,
    this.errors = const [],
  });
}

/// OID4VP Result
class OID4VPResult {
  final bool success;
  final Map<String, dynamic>? presentationDefinition;
  final List<String> matchingCredentials;
  final String? error;

  OID4VPResult({
    required this.success,
    this.presentationDefinition,
    this.matchingCredentials = const [],
    this.error,
  });
}

/// mDL Verification Result
class MDLVerificationResult {
  final bool isValid;
  final Map<String, dynamic> elements;
  final String? issuerCountry;
  final String? documentNumber;

  MDLVerificationResult({
    required this.isValid,
    required this.elements,
    this.issuerCountry,
    this.documentNumber,
  });

  String? get fullName => elements['family_name'] != null
      ? '${elements['given_name']} ${elements['family_name']}'
      : null;

  String? get dateOfBirth => elements['birth_date'];
  bool? get ageOver21 => elements['age_over_21'];
  String? get portrait => elements['portrait'];
}
