/// Verification Result Model
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

  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'message': message,
      'status': status.toString(),
      'timestamp': timestamp.toIso8601String(),
      'passId': passId,
      'errorDetails': errorDetails,
    };
  }

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    return VerificationResult(
      isValid: json['isValid'] as bool,
      message: json['message'] as String,
      status: _parseStatus(json['status'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      passId: json['passId'] as String?,
      errorDetails: json['errorDetails'] as String?,
    );
  }

  static VerificationStatus _parseStatus(String status) {
    return VerificationStatus.values.firstWhere(
      (e) => e.toString() == status,
      orElse: () => VerificationStatus.invalid,
    );
  }
}

enum VerificationStatus { valid, invalid, expired, alreadyUsed, revoked, error }
