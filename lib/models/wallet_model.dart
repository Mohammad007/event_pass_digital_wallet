/// Wallet Model - Represents user's SSI wallet
class WalletModel {
  final String did;
  final String publicKey;
  final DateTime createdAt;
  final bool isBiometricEnabled;
  final String? pin;
  final String? name;
  final List<String> passIds;

  WalletModel({
    required this.did,
    required this.publicKey,
    required this.createdAt,
    this.isBiometricEnabled = false,
    this.pin,
    this.name,
    this.passIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'did': did,
      'publicKey': publicKey,
      'createdAt': createdAt.toIso8601String(),
      'isBiometricEnabled': isBiometricEnabled,
      'pin': pin,
      'name': name,
      'passIds': passIds,
    };
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      did: json['did'] as String,
      publicKey: json['publicKey'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isBiometricEnabled: json['isBiometricEnabled'] as bool? ?? false,
      pin: json['pin'] as String?,
      name: json['name'] as String?,
      passIds: (json['passIds'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  WalletModel copyWith({
    String? did,
    String? publicKey,
    DateTime? createdAt,
    bool? isBiometricEnabled,
    String? pin,
    String? name,
    List<String>? passIds,
  }) {
    return WalletModel(
      did: did ?? this.did,
      publicKey: publicKey ?? this.publicKey,
      createdAt: createdAt ?? this.createdAt,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      pin: pin ?? this.pin,
      name: name ?? this.name,
      passIds: passIds ?? this.passIds,
    );
  }
}
