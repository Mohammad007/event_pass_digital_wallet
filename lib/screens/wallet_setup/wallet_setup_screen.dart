import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../services/biometric_service.dart';
import '../home/home_screen.dart';

/// Wallet Setup Screen - Production-grade PIN and biometric setup
class WalletSetupScreen extends StatefulWidget {
  const WalletSetupScreen({super.key});

  @override
  State<WalletSetupScreen> createState() => _WalletSetupScreenState();
}

class _WalletSetupScreenState extends State<WalletSetupScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _walletNameController = TextEditingController();
  final _biometricService = BiometricService();

  int _currentStep = 0;
  bool _isBiometricAvailable = false;
  bool _enableBiometric = false;
  bool _isLoading = false;
  String? _pinError;
  String? _confirmError;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (mounted) {
      setState(() => _isBiometricAvailable = isAvailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Your Wallet'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator
              _buildProgressIndicator(),

              const SizedBox(height: 32),

              // Step Content
              if (_currentStep == 0) _buildPinStep(),
              if (_currentStep == 1) _buildConfirmPinStep(),
              if (_currentStep == 2) _buildBiometricStep(),

              const SizedBox(height: 40),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= _currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (index < 2) const SizedBox(width: 8),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPinStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Secure Your Wallet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Step 1 of 3',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Give your wallet a name and create a 6-digit PIN to secure your wallet.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        // Wallet Name Field
        TextField(
          controller: _walletNameController,
          decoration: const InputDecoration(
            labelText: 'Wallet Name',
            prefixIcon: Icon(Icons.account_balance_wallet_outlined),
            hintText: 'e.g. My Primary Wallet',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: 'Enter 6-digit PIN',
            prefixIcon: const Icon(Icons.pin),
            counterText: '',
            errorText: _pinError,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) {
            if (_pinError != null) {
              setState(() => _pinError = null);
            }
          },
        ),
      ],
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildConfirmPinStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm PIN',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Step 2 of 3',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Re-enter your PIN to confirm. Make sure you remember it!',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _confirmPinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: 'Confirm PIN',
            prefixIcon: const Icon(Icons.pin),
            counterText: '',
            errorText: _confirmError,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) {
            if (_confirmError != null) {
              setState(() => _confirmError = null);
            }
          },
        ),
      ],
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildBiometricStep() {
    return Column(
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
              child: const Icon(Icons.fingerprint, color: AppColors.accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biometric Security',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Step 3 of 3 (Optional)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_isBiometricAvailable) ...[
          Text(
            'Enable fingerprint or face recognition for quick and secure access to your wallet.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Card(
            child: SwitchListTile(
              secondary: const Icon(
                Icons.fingerprint,
                color: AppColors.primary,
              ),
              title: const Text('Enable Biometric'),
              subtitle: const Text('Use fingerprint or face ID'),
              value: _enableBiometric,
              onChanged: (value) {
                setState(() => _enableBiometric = value);
              },
              activeColor: AppColors.primary,
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Biometric authentication is not available on this device.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(_currentStep == 2 ? 'Create Wallet' : 'Continue'),
          ),
        ),
        if (_currentStep > 0) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() => _currentStep--);
                    },
              child: const Text('Back'),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleNext() async {
    if (_currentStep == 0) {
      // Validate PIN
      if (_pinController.text.length != 6) {
        setState(() => _pinError = 'PIN must be 6 digits');
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      // Validate confirm PIN
      if (_confirmPinController.text != _pinController.text) {
        setState(() => _confirmError = 'PINs do not match');
        return;
      }
      setState(() => _currentStep = 2);
    } else {
      // Create wallet
      await _createWallet();
    }
  }

  Future<void> _createWallet() async {
    setState(() => _isLoading = true);

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);

      debugPrint('WalletSetup: Creating wallet...');
      final success = await appProvider.createWallet(
        pin: _pinController.text,
        name: _walletNameController.text.trim().isNotEmpty
            ? _walletNameController.text.trim()
            : null,
      );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create wallet'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      debugPrint('WalletSetup: Wallet created successfully');

      // Enable biometric if selected (optional - don't block on failure)
      if (_enableBiometric && _isBiometricAvailable) {
        debugPrint('WalletSetup: Attempting biometric setup...');
        try {
          final authenticated = await _biometricService.authenticate(
            reason: 'Authenticate to enable biometric login',
            biometricOnly: false, // Allow PIN/pattern fallback
          );

          if (authenticated) {
            await appProvider.enableBiometric();
            debugPrint('WalletSetup: Biometric enabled');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Biometric authentication enabled!'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 1),
                ),
              );
            }
          } else {
            debugPrint('WalletSetup: Biometric auth failed, skipping');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Biometric skipped - you can enable it later in settings',
                  ),
                  backgroundColor: AppColors.info,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        } catch (e) {
          debugPrint('WalletSetup: Biometric error: $e');
          // Don't block wallet creation if biometric fails
        }
      }

      if (!mounted) return;

      // Navigate to home
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('WalletSetup: Error creating wallet: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }
}
