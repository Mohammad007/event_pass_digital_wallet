import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/event_pass.dart';

/// Verifiable Presentation - Cryptographic proof for verification
class VerifiablePresentation {
  final String id;
  final String type;
  final String holder; // Holder DID
  final EventPass credential;
  final String nonce; // Anti-replay
  final DateTime timestamp;
  final String proof; // Cryptographic signature

  VerifiablePresentation({
    required this.id,
    required this.type,
    required this.holder,
    required this.credential,
    required this.nonce,
    required this.timestamp,
    required this.proof,
  });

  Map<String, dynamic> toJson() {
    return {
      '@context': ['https://www.w3.org/2018/credentials/v1'],
      'id': id,
      'type': [type],
      'holder': holder,
      'verifiableCredential': credential.toJson(),
      'nonce': nonce,
      'timestamp': timestamp.toIso8601String(),
      'proof': {
        'type': 'Ed25519Signature2020',
        'created': timestamp.toIso8601String(),
        'proofPurpose': 'authentication',
        'verificationMethod': '$holder#keys-1',
        'proofValue': proof,
      },
    };
  }

  factory VerifiablePresentation.fromJson(Map<String, dynamic> json) {
    return VerifiablePresentation(
      id: json['id'] as String,
      type: (json['type'] as List).first as String,
      holder: json['holder'] as String,
      credential: EventPass.fromJson(json['verifiableCredential']),
      nonce: json['nonce'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      proof: json['proof']['proofValue'] as String,
    );
  }

  String toQRString() {
    return jsonEncode(toJson());
  }

  /// Check if presentation is still valid (not expired)
  bool get isValid {
    final age = DateTime.now().difference(timestamp);
    return age.inSeconds < 60; // Valid for 60 seconds
  }
}

/// Presentation Service - Generate & Verify Verifiable Presentations
class PresentationService {
  static final PresentationService _instance = PresentationService._internal();
  factory PresentationService() => _instance;
  PresentationService._internal();

  /// Generate Verifiable Presentation from EventPass
  VerifiablePresentation generatePresentation({
    required EventPass credential,
    required String holderDID,
    required String privateKey,
  }) {
    final nonce = _generateNonce();
    final timestamp = DateTime.now();

    // Create presentation data
    final presentationData = {
      'credential': credential.toJson(),
      'holder': holderDID,
      'nonce': nonce,
      'timestamp': timestamp.toIso8601String(),
    };

    // Generate proof (simplified - in production use proper signing)
    final proof = _generateProof(presentationData, privateKey);

    return VerifiablePresentation(
      id: 'urn:uuid:${_generateNonce()}',
      type: 'VerifiablePresentation',
      holder: holderDID,
      credential: credential,
      nonce: nonce,
      timestamp: timestamp,
      proof: proof,
    );
  }

  /// Verify Verifiable Presentation
  Future<VerificationResult> verifyPresentation({
    required VerifiablePresentation presentation,
    required String expectedEventId,
  }) async {
    try {
      // 1. Check presentation validity (timestamp)
      if (!presentation.isValid) {
        return VerificationResult(
          isValid: false,
          message: 'Presentation expired',
          status: VerificationStatus.expired,
          timestamp: DateTime.now(),
        );
      }

      // 2. Verify credential is for correct event
      if (presentation.credential.id != expectedEventId) {
        return VerificationResult(
          isValid: false,
          message: 'Invalid event credential',
          status: VerificationStatus.invalid,
          timestamp: DateTime.now(),
        );
      }

      // 3. Check if credential is valid
      if (!presentation.credential.isValid) {
        if (presentation.credential.isUsed) {
          return VerificationResult(
            isValid: false,
            message: 'Ticket already used',
            status: VerificationStatus.alreadyUsed,
            timestamp: DateTime.now(),
            passId: presentation.credential.id,
          );
        }

        if (presentation.credential.isExpired) {
          return VerificationResult(
            isValid: false,
            message: 'Ticket expired',
            status: VerificationStatus.expired,
            timestamp: DateTime.now(),
            passId: presentation.credential.id,
          );
        }

        return VerificationResult(
          isValid: false,
          message: 'Invalid ticket',
          status: VerificationStatus.invalid,
          timestamp: DateTime.now(),
          passId: presentation.credential.id,
        );
      }

      // 4. Verify cryptographic proof (simplified)
      final isProofValid = _verifyProof(presentation);

      if (!isProofValid) {
        return VerificationResult(
          isValid: false,
          message: 'Invalid cryptographic proof',
          status: VerificationStatus.invalid,
          timestamp: DateTime.now(),
          passId: presentation.credential.id,
        );
      }

      // All checks passed
      return VerificationResult(
        isValid: true,
        message: 'Valid ticket - Entry granted',
        status: VerificationStatus.valid,
        timestamp: DateTime.now(),
        passId: presentation.credential.id,
      );
    } catch (e) {
      return VerificationResult(
        isValid: false,
        message: 'Verification error: $e',
        status: VerificationStatus.error,
        timestamp: DateTime.now(),
        errorDetails: e.toString(),
      );
    }
  }

  /// Generate nonce for anti-replay
  String _generateNonce() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.toString() + DateTime.now().microsecond.toString();
    final hash = sha256.convert(utf8.encode(random)).toString();
    // Take first 16 characters or full hash if shorter
    return hash.length >= 16 ? hash.substring(0, 16) : hash;
  }

  /// Generate cryptographic proof (simplified for MVP)
  String _generateProof(Map<String, dynamic> data, String privateKey) {
    final dataString = jsonEncode(data);
    final combined = '$dataString$privateKey';
    return sha256.convert(utf8.encode(combined)).toString();
  }

  /// Verify cryptographic proof (simplified for MVP)
  bool _verifyProof(VerifiablePresentation presentation) {
    // In production, use proper signature verification
    // For MVP, we check if proof exists and is not empty
    return presentation.proof.isNotEmpty && presentation.proof.length == 64;
  }
}

/// Verification Result Model (already exists, but importing for reference)
class VerificationResult {
  final bool isValid;
  final String message;
  final VerificationStatus status;
  final DateTime timestamp;
  final String? passId;
  final String? errorDetails;

  VerificationResult({
    required this.isValid,
    required this.message,
    required this.status,
    required this.timestamp,
    this.passId,
    this.errorDetails,
  });
}

enum VerificationStatus { valid, invalid, expired, alreadyUsed, revoked, error }
