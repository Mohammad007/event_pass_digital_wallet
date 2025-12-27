import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/user_profile.dart';
import '../../services/biometric_service.dart';
import '../onboarding/onboarding_screen.dart';

/// Profile/Settings Screen - Production-grade settings view
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _biometricService = BiometricService();
  bool _isBiometricAvailable = false;
  bool _isCheckingBiometric = true;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    try {
      debugPrint('ProfileScreen: Checking biometric availability...');
      final isAvailable = await _biometricService.isBiometricAvailable();
      debugPrint('ProfileScreen: Biometric available = $isAvailable');
      if (mounted) {
        setState(() {
          _isBiometricAvailable = isAvailable;
          _isCheckingBiometric = false;
        });
      }
    } catch (e) {
      debugPrint('ProfileScreen: Error checking biometric: $e');
      if (mounted) {
        setState(() => _isCheckingBiometric = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final wallet = provider.wallet;

          if (wallet == null) {
            return const Center(child: Text('No wallet found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Info Card
              if (provider.userProfile != null) ...[
                _buildUserCard(context, provider),
                const SizedBox(height: 16),
              ],

              // Wallet Info Card
              _buildWalletCard(context, provider),

              const SizedBox(height: 24),

              // Settings Section
              _buildSectionHeader(context, 'Settings'),
              const SizedBox(height: 12),

              // Biometric Toggle - Always show
              _buildBiometricTile(context, provider),

              // Backup Option
              _buildSettingsTile(
                context,
                icon: Icons.backup_outlined,
                title: 'Backup Wallet',
                subtitle: 'Export wallet data',
                onTap: () => _showBackupDialog(context),
              ),

              // About
              _buildSettingsTile(
                context,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),

              const SizedBox(height: 24),

              // Danger Zone
              _buildSectionHeader(context, 'Danger Zone', isDestructive: true),
              const SizedBox(height: 12),

              _buildSettingsTile(
                context,
                icon: Icons.delete_forever_outlined,
                title: 'Reset Wallet',
                subtitle: 'Delete all data and start fresh',
                isDestructive: true,
                onTap: () => _showResetDialog(context, provider),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AppProvider provider) {
    final profile = provider.userProfile!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    profile.name.isNotEmpty
                        ? profile.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        profile.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (profile.organizationName != null)
                        Text(
                          profile.organizationName!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, AppProvider provider) {
    final wallet = provider.wallet!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.name ?? 'My Wallet',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${provider.allPasses.length} passes stored',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildWalletInfoRow(
              context,
              'DID',
              _truncateString(wallet.did, 25),
              wallet.did,
            ),
            const SizedBox(height: 12),
            _buildWalletInfoRow(
              context,
              'Public Key',
              _truncateString(wallet.publicKey, 25),
              wallet.publicKey,
            ),
            const SizedBox(height: 12),
            _buildWalletInfoRow(
              context,
              'Created',
              '${wallet.createdAt.day}/${wallet.createdAt.month}/${wallet.createdAt.year}',
              null,
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildWalletInfoRow(
    BuildContext context,
    String label,
    String displayValue,
    String? copyValue,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: copyValue != null
                ? () {
                    Clipboard.setData(ClipboardData(text: copyValue));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$label copied to clipboard'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                : null,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayValue,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
                if (copyValue != null)
                  const Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: AppColors.textLight,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    bool isDestructive = false,
  }) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildBiometricTile(BuildContext context, AppProvider provider) {
    final wallet = provider.wallet!;

    // Show loading while checking
    if (_isCheckingBiometric) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(
            Icons.fingerprint_rounded,
            color: AppColors.primary,
          ),
          title: const Text('Biometric Authentication'),
          subtitle: const Text('Checking availability...'),
          trailing: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        secondary: Icon(
          Icons.fingerprint_rounded,
          color: _isBiometricAvailable
              ? AppColors.primary
              : AppColors.textLight,
        ),
        title: const Text('Biometric Authentication'),
        subtitle: Text(
          _isBiometricAvailable
              ? 'Use fingerprint or face ID'
              : 'Not available on this device',
          style: TextStyle(
            color: _isBiometricAvailable ? null : AppColors.textLight,
          ),
        ),
        value: wallet.isBiometricEnabled,
        onChanged: _isBiometricAvailable
            ? (value) async {
                try {
                  if (value) {
                    // Show loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Authenticating...'),
                          ],
                        ),
                        duration: Duration(seconds: 10),
                      ),
                    );

                    final authenticated = await _biometricService.authenticate(
                      reason: 'Authenticate to enable biometric login',
                      biometricOnly: false,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    }

                    if (authenticated && mounted) {
                      await provider.enableBiometric();
                      _showSuccessSnackBar('Biometric authentication enabled!');
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Authentication failed or cancelled'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                    }
                  } else {
                    await provider.disableBiometric();
                    if (mounted) _showSuccessSnackBar('Biometric disabled');
                  }
                } catch (e) {
                  debugPrint('Biometric toggle error: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            : null,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
        ),
        title: Text(
          title,
          style: TextStyle(color: isDestructive ? AppColors.error : null),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: isDestructive ? AppColors.error : AppColors.textLight,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.backup_outlined, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Backup Wallet'),
          ],
        ),
        content: const Text(
          'In a production app, this would export your encrypted wallet data for backup purposes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary),
            SizedBox(width: 12),
            Text('About EventPass'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 12),
            Text(
              'A secure digital event credential wallet using SSI technology.',
            ),
            SizedBox(height: 16),
            Text(
              '• Decentralized Identity (DID)\n• Verifiable Credentials\n• QR-based Entry\n• Biometric Security',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, AppProvider provider) {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 12),
            Text('Reset Wallet?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will permanently delete:'),
            const SizedBox(height: 8),
            const Text('• All event passes', style: TextStyle(fontSize: 13)),
            const Text('• Wallet and DID', style: TextStyle(fontSize: 13)),
            const Text('• Private keys', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    size: 20,
                    color: AppColors.error,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone!',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Enter PIN to confirm',
                prefixIcon: Icon(Icons.lock_outline),
                counterText: '',
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              pinController.dispose();
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                _performReset(dialogContext, pinController.text, provider),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _performReset(
    BuildContext dialogContext,
    String pin,
    AppProvider provider,
  ) async {
    if (pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your PIN'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Resetting wallet...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Verify PIN
      final isValidPin = await provider.walletService.verifyPin(pin);

      if (!isValidPin) {
        if (!mounted) return;
        Navigator.pop(context); // Close loading
        Navigator.pop(dialogContext); // Close reset dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid PIN'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Delete all passes
      for (final pass in provider.allPasses) {
        await provider.deletePass(pass.id);
      }

      // Delete wallet
      await provider.walletService.deleteWallet();
      await provider.clearAll();

      if (!mounted) return;

      Navigator.pop(context); // Close loading
      Navigator.pop(dialogContext); // Close reset dialog

      _showSuccessSnackBar('Wallet reset successfully');

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Navigate to onboarding
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Safely truncate string to avoid RangeError
  String _truncateString(String str, int maxLength) {
    if (str.length <= maxLength) return str;
    return '${str.substring(0, maxLength)}...';
  }
}
