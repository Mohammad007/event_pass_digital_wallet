import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

/// Biometric Authentication Service - Production-grade
class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric hardware is available
  Future<bool> isBiometricAvailable() async {
    try {
      // Check if device supports biometrics
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        debugPrint('BiometricService: Device does not support biometrics');
        return false;
      }

      // Check if biometrics can be checked
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) {
        debugPrint('BiometricService: Cannot check biometrics');
        return false;
      }

      // Check if any biometric is enrolled
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      debugPrint(
        'BiometricService: Available biometrics: $availableBiometrics',
      );

      return availableBiometrics.isNotEmpty;
    } on PlatformException catch (e) {
      debugPrint(
        'BiometricService: PlatformException checking availability: ${e.message}',
      );
      return false;
    } catch (e) {
      debugPrint('BiometricService: Error checking availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint(
        'BiometricService: Error getting available biometrics: ${e.message}',
      );
      return [];
    }
  }

  /// Authenticate with biometric or device credentials
  Future<bool> authenticate({
    String reason = 'Please authenticate to access your wallet',
    bool biometricOnly = false,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();

      if (!isAvailable && biometricOnly) {
        debugPrint(
          'BiometricService: Biometric not available and biometricOnly is true',
        );
        return false;
      }

      debugPrint('BiometricService: Starting authentication...');

      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      debugPrint('BiometricService: Authentication result: $result');
      return result;
    } on PlatformException catch (e) {
      debugPrint(
        'BiometricService: PlatformException during auth: ${e.code} - ${e.message}',
      );

      // Common error codes:
      // NotAvailable - biometric not available
      // NotEnrolled - no biometrics enrolled
      // LockedOut - too many attempts
      // PermanentlyLockedOut - device locked

      return false;
    } catch (e) {
      debugPrint('BiometricService: Error during authentication: $e');
      return false;
    }
  }

  /// Check if device supports any form of authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      debugPrint(
        'BiometricService: Error checking device support: ${e.message}',
      );
      return false;
    }
  }

  /// Get human-readable biometric type name
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }
}
