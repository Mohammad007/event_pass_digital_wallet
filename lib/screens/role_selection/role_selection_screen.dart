import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_profile.dart';
import '../profile_setup/profile_setup_screen.dart';

/// Role Selection Screen - Production-grade role chooser
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Title Section
              Text(
                'Choose Your Role',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn().slideX(begin: -0.1, end: 0),

              const SizedBox(height: 8),

              Text(
                'Select how you want to use EventPass',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 40),

              // Role Cards
              Expanded(
                child: Column(
                  children: [
                    // Attendee
                    _buildRoleCard(
                      context,
                      role: UserRole.attendee,
                      icon: Icons.confirmation_number_rounded,
                      title: 'Attendee',
                      description:
                          'Store and present your event tickets securely',
                      color: AppColors.primary,
                      delay: 200,
                    ),

                    const SizedBox(height: 16),

                    // Organizer
                    _buildRoleCard(
                      context,
                      role: UserRole.organizer,
                      icon: Icons.business_center_rounded,
                      title: 'Organizer',
                      description:
                          'Create events and issue tickets to attendees',
                      color: AppColors.secondary,
                      delay: 300,
                    ),

                    const SizedBox(height: 16),

                    // Verifier
                    _buildRoleCard(
                      context,
                      role: UserRole.verifier,
                      icon: Icons.verified_user_rounded,
                      title: 'Verifier',
                      description:
                          'Scan and verify tickets at event entry gates',
                      color: AppColors.accent,
                      delay: 400,
                    ),

                    const Spacer(),

                    // Footer Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: AppColors.primary.withOpacity(0.7),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You can change your role later in settings',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required UserRole role,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required int delay,
  }) {
    return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ProfileSetupScreen(selectedRole: role),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: 28, color: color),
                  ),

                  const SizedBox(width: 16),

                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Arrow
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideX(begin: 0.1, end: 0);
  }
}
