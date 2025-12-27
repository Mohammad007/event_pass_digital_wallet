import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../models/wallet_model.dart';

/// Wallet Service - Manages DID creation and wallet operations
class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  final _secureStorage = const FlutterSecureStorage();
  final _uuid = const Uuid();

  static const String _walletKey = 'wallet_data';
  static const String _privateKeyKey = 'private_key';
  static const String _pinKey = 'wallet_pin';

  WalletModel? _currentWallet;

  /// Check if wallet exists
  Future<bool> hasWallet() async {
    final walletData = await _secureStorage.read(key: _walletKey);
    return walletData != null;
  }

  /// Create new wallet with DID
  Future<WalletModel> createWallet({String? pin, String? name}) async {
    // Generate DID (simplified version - in production use proper DID method)
    final did = _generateDID();

    // Generate key pair (simplified - in production use proper cryptographic keys)
    final keyPair = _generateKeyPair();

    final wallet = WalletModel(
      did: did,
      publicKey: keyPair['publicKey']!,
      createdAt: DateTime.now(),
      pin: pin != null ? _hashPin(pin) : null,
      name: name,
    );

    // Store wallet data
    await _secureStorage.write(
      key: _walletKey,
      value: jsonEncode(wallet.toJson()),
    );

    // Store private key separately
    await _secureStorage.write(
      key: _privateKeyKey,
      value: keyPair['privateKey']!,
    );

    if (pin != null) {
      await _secureStorage.write(key: _pinKey, value: _hashPin(pin));
    }

    _currentWallet = wallet;
    return wallet;
  }

  /// Get current wallet
  Future<WalletModel?> getWallet() async {
    if (_currentWallet != null) return _currentWallet;

    final walletData = await _secureStorage.read(key: _walletKey);
    if (walletData == null) return null;

    _currentWallet = WalletModel.fromJson(jsonDecode(walletData));
    return _currentWallet;
  }

  /// Update wallet
  Future<void> updateWallet(WalletModel wallet) async {
    await _secureStorage.write(
      key: _walletKey,
      value: jsonEncode(wallet.toJson()),
    );
    _currentWallet = wallet;
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    final storedPin = await _secureStorage.read(key: _pinKey);
    if (storedPin == null) return false;
    return storedPin == _hashPin(pin);
  }

  /// Enable biometric authentication
  Future<void> enableBiometric() async {
    if (_currentWallet == null) return;

    final updatedWallet = _currentWallet!.copyWith(isBiometricEnabled: true);
    await updateWallet(updatedWallet);
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    if (_currentWallet == null) return;

    final updatedWallet = _currentWallet!.copyWith(isBiometricEnabled: false);
    await updateWallet(updatedWallet);
  }

  /// Get private key
  Future<String?> getPrivateKey() async {
    return await _secureStorage.read(key: _privateKeyKey);
  }

  /// Delete wallet (for testing/reset)
  Future<void> deleteWallet() async {
    await _secureStorage.delete(key: _walletKey);
    await _secureStorage.delete(key: _privateKeyKey);
    await _secureStorage.delete(key: _pinKey);
    _currentWallet = null;
  }

  /// Generate DID (simplified - did:key method)
  String _generateDID() {
    final uuid = _uuid.v4();
    return 'did:key:z${uuid.replaceAll('-', '')}';
  }

  /// Generate key pair (simplified)
  Map<String, String> _generateKeyPair() {
    final random = _uuid.v4();
    final publicKey = sha256.convert(utf8.encode(random)).toString();
    final privateKey = sha256
        .convert(utf8.encode('$random-private'))
        .toString();

    return {'publicKey': publicKey, 'privateKey': privateKey};
  }

  /// Hash PIN for secure storage
  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  /// Add pass ID to wallet
  Future<void> addPassId(String passId) async {
    if (_currentWallet == null) return;

    final passIds = List<String>.from(_currentWallet!.passIds);
    if (!passIds.contains(passId)) {
      passIds.add(passId);
      final updatedWallet = _currentWallet!.copyWith(passIds: passIds);
      await updateWallet(updatedWallet);
    }
  }

  /// Remove pass ID from wallet
  Future<void> removePassId(String passId) async {
    if (_currentWallet == null) return;

    final passIds = List<String>.from(_currentWallet!.passIds);
    passIds.remove(passId);
    final updatedWallet = _currentWallet!.copyWith(passIds: passIds);
    await updateWallet(updatedWallet);
  }
}
