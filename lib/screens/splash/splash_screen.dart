import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../services/biometric_service.dart';
import '../onboarding/onboarding_screen.dart';
import '../home/home_screen.dart';

/// Splash Screen - Production-grade app initialization
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.initialize();

    if (!mounted) return;

    // Navigate based on wallet status
    if (appProvider.wallet != null) {
      if (appProvider.wallet!.isBiometricEnabled) {
        // Attempt biometric authentication
        final bioService = BiometricService();
        final authenticated = await bioService.authenticate(
          reason: 'Unlock your EventPass Wallet',
          biometricOnly: false,
        );

        if (!authenticated) {
          // If failed or cancelled, we should probably still show Home but maybe locked?
          // Or force retry? For now, we proceed but log it.
          // Ideally we'd show a PIN screen here, but that screen doesn't exist yet as a standalone login.
          debugPrint('Biometric auth failed/cancelled');
        }
      }
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo Container
              Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.confirmation_number_rounded,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(),

              const SizedBox(height: 32),

              // App Name
              Text(
                'EventPass',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),

              const SizedBox(height: 8),

              // Tagline
              Text(
                'Secure Digital Event Credentials',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ).animate().fadeIn(delay: 500.ms),

              const Spacer(flex: 2),

              // Loading Indicator
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 16),

              Text(
                'Loading...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
