import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/event_pass.dart';
import '../models/wallet_model.dart';
import '../models/user_profile.dart';
import '../services/wallet_service.dart';
import '../services/sprucekit_service.dart';
import '../services/credential_service.dart';

/// App State Provider with Role Management
class AppProvider extends ChangeNotifier {
  final WalletService _walletService = WalletService();
  final CredentialService _credentialService = CredentialService();
  final SpruceKitService _spruceKitService = SpruceKitService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  WalletModel? _wallet;
  UserProfile? _userProfile;
  List<EventPass> _allPasses = [];
  bool _isLoading = false;
  UserRole _userRole = UserRole.attendee;

  WalletModel? get wallet => _wallet;
  UserProfile? get userProfile => _userProfile;
  List<EventPass> get allPasses => _allPasses;
  bool get isLoading => _isLoading;
  UserRole get userRole => _userRole;
  SpruceKitService get spruceKitService => _spruceKitService;

  List<EventPass> get upcomingPasses {
    final now = DateTime.now();
    return _allPasses
        .where(
          (pass) =>
              pass.eventDate.isAfter(now) && pass.status == PassStatus.active,
        )
        .toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
  }

  List<EventPass> get pastPasses {
    final now = DateTime.now();
    return _allPasses
        .where(
          (pass) =>
              pass.eventDate.isBefore(now) ||
              pass.status == PassStatus.used ||
              pass.status == PassStatus.expired,
        )
        .toList()
      ..sort((a, b) => b.eventDate.compareTo(a.eventDate));
  }

  /// Initialize app
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _spruceKitService.initialize();
      _wallet = await _walletService.getWallet();
      await _loadUserProfile(); // Load profile

      // Load saved role (fallback if profile load fails or overrides)
      final savedRole = await _secureStorage.read(key: 'user_role');
      if (savedRole != null) {
        _userRole = UserRole.values.firstWhere(
          (e) => e.toString() == savedRole,
          orElse: () => UserRole.attendee,
        );
      } else if (_userProfile != null) {
        _userRole = _userProfile!.role;
      }

      if (_wallet != null) {
        await loadPasses();
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user profile
  Future<void> _loadUserProfile() async {
    try {
      final jsonStr = await _secureStorage.read(key: 'user_profile');
      if (jsonStr != null) {
        _userProfile = UserProfile.fromJson(jsonDecode(jsonStr));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  /// Save user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    _userProfile = profile;
    _userRole = profile.role; // Sync role
    await _secureStorage.write(
      key: 'user_profile',
      value: jsonEncode(profile.toJson()),
    );
    await _secureStorage.write(
      key: 'user_role',
      value: profile.role.toString(),
    );
    notifyListeners();
  }

  /// Set user role
  Future<void> setUserRole(UserRole role) async {
    _userRole = role;
    await _secureStorage.write(key: 'user_role', value: role.toString());
    notifyListeners();
  }

  /// Create wallet
  Future<bool> createWallet({String? pin, String? name}) async {
    try {
      _wallet = await _walletService.createWallet(pin: pin, name: name);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating wallet: $e');
      return false;
    }
  }

  /// Load all passes
  Future<void> loadPasses() async {
    try {
      _allPasses = await _credentialService.getAllPasses();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading passes: $e');
    }
  }

  /// Add new pass
  Future<bool> addPass(EventPass pass) async {
    try {
      await _credentialService.savePass(pass);
      await _walletService.addPassId(pass.id);
      await loadPasses();
      return true;
    } catch (e) {
      debugPrint('Error adding pass: $e');
      return false;
    }
  }

  /// Update pass
  Future<bool> updatePass(EventPass pass) async {
    try {
      await _credentialService.updatePass(pass);
      await loadPasses();
      return true;
    } catch (e) {
      debugPrint('Error updating pass: $e');
      return false;
    }
  }

  /// Delete pass
  Future<bool> deletePass(String passId) async {
    try {
      await _credentialService.deletePass(passId);
      await _walletService.removePassId(passId);
      await loadPasses();
      return true;
    } catch (e) {
      debugPrint('Error deleting pass: $e');
      return false;
    }
  }

  /// Mark pass as used
  Future<bool> markPassAsUsed(String passId) async {
    try {
      await _credentialService.markPassAsUsed(passId);
      await loadPasses();
      return true;
    } catch (e) {
      debugPrint('Error marking pass as used: $e');
      return false;
    }
  }

  /// Get pass by ID
  EventPass? getPassById(String id) {
    try {
      return _allPasses.firstWhere((pass) => pass.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Enable biometric
  Future<void> enableBiometric() async {
    await _walletService.enableBiometric();
    _wallet = await _walletService.getWallet();
    notifyListeners();
  }

  /// Disable biometric
  Future<void> disableBiometric() async {
    await _walletService.disableBiometric();
    _wallet = await _walletService.getWallet();
    notifyListeners();
  }

  /// Get wallet service (for reset functionality)
  WalletService get walletService => _walletService;

  /// Clear all app data
  Future<void> clearAll() async {
    _wallet = null;
    _allPasses = [];
    _isLoading = false;
    _userRole = UserRole.attendee;
    await _secureStorage.delete(key: 'user_role');
    notifyListeners();
  }
}
