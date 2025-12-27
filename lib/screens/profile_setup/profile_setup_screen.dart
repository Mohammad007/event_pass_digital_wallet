import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_profile.dart';
import '../../providers/app_provider.dart';
import '../wallet_setup/wallet_setup_screen.dart';

/// Profile Setup Screen - Production-grade profile completion with role saving
class ProfileSetupScreen extends StatefulWidget {
  final UserRole selectedRole;

  const ProfileSetupScreen({super.key, required this.selectedRole});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _orgNameController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getRoleColor().withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getRoleIcon(), color: _getRoleColor(), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _getRoleText(),
                          style: TextStyle(
                            color: _getRoleColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().scale(duration: 300.ms),

                const SizedBox(height: 32),

                // Form Fields
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: 'Enter your full name',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: 'Enter your email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                // Organization Name (for Organizer/Verifier)
                if (widget.selectedRole != UserRole.attendee) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Organization Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _orgNameController,
                    decoration: InputDecoration(
                      labelText: widget.selectedRole == UserRole.organizer
                          ? 'Organization Name'
                          : 'Venue/Gate Name',
                      prefixIcon: const Icon(Icons.business_outlined),
                      hintText: widget.selectedRole == UserRole.organizer
                          ? 'Enter your organization name'
                          : 'Enter venue or gate name',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter organization name';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 40),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getRoleColor(),
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
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Continue to Wallet Setup'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _continue() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Save user role & profile to provider
        final appProvider = Provider.of<AppProvider>(context, listen: false);

        final profile = UserProfile(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID gen
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          role: widget.selectedRole,
          did:
              'did:key:pending', // Will be updated when wallet is created? Or we should have user profile separate from DID?
          // Actually UserProfile has DID. Usually DID comes from Wallet.
          // For now, let's put a placeholder or pending DID, as wallet creation happens NEXT.
          // Or generate a temporary ID.
          createdAt: DateTime.now(),
          organizationName: _orgNameController.text.trim().isNotEmpty
              ? _orgNameController.text.trim()
              : null,
        );

        await appProvider.saveUserProfile(profile);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WalletSetupScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Color _getRoleColor() {
    switch (widget.selectedRole) {
      case UserRole.attendee:
        return AppColors.primary;
      case UserRole.organizer:
        return AppColors.secondary;
      case UserRole.verifier:
        return AppColors.accent;
    }
  }

  IconData _getRoleIcon() {
    switch (widget.selectedRole) {
      case UserRole.attendee:
        return Icons.confirmation_number_rounded;
      case UserRole.organizer:
        return Icons.business_center_rounded;
      case UserRole.verifier:
        return Icons.verified_user_rounded;
    }
  }

  String _getRoleText() {
    switch (widget.selectedRole) {
      case UserRole.attendee:
        return 'Attendee';
      case UserRole.organizer:
        return 'Organizer';
      case UserRole.verifier:
        return 'Verifier';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _orgNameController.dispose();
    super.dispose();
  }
}
