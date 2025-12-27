import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/event_pass.dart';
import '../pass_detail/pass_detail_screen.dart';

/// History Screen - Production-grade past events view with dynamic status
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Get all passes and show appropriate status
          final allPasses = provider.allPasses;

          if (allPasses.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allPasses.length,
            itemBuilder: (context, index) {
              final pass = allPasses[index];
              return _buildHistoryCard(context, pass, index);
            },
          );
        },
      ),
    );
  }

  /// Calculate dynamic status based on event date and pass properties
  _DynamicStatus _getDynamicStatus(EventPass pass) {
    final now = DateTime.now();
    final eventDate = pass.eventDate;

    // If pass is marked as used
    if (pass.isUsed || pass.status == PassStatus.used) {
      return _DynamicStatus(
        status: PassStatus.used,
        label: 'ATTENDED',
        color: AppColors.info,
        icon: Icons.verified_outlined,
      );
    }

    // If pass is revoked
    if (pass.status == PassStatus.revoked) {
      return _DynamicStatus(
        status: PassStatus.revoked,
        label: 'REVOKED',
        color: AppColors.error,
        icon: Icons.cancel_outlined,
      );
    }

    // If event date has passed
    if (eventDate.isBefore(now)) {
      // Check if it expired (event was yesterday or before)
      final daysDiff = now.difference(eventDate).inDays;
      if (daysDiff >= 1) {
        return _DynamicStatus(
          status: PassStatus.expired,
          label: 'EXPIRED',
          color: AppColors.warning,
          icon: Icons.event_busy_outlined,
        );
      } else {
        // Event was today but time passed
        return _DynamicStatus(
          status: PassStatus.expired,
          label: 'PAST',
          color: AppColors.textSecondary,
          icon: Icons.schedule_outlined,
        );
      }
    }

    // If expiresAt is set and has passed
    if (pass.expiresAt != null && pass.expiresAt!.isBefore(now)) {
      return _DynamicStatus(
        status: PassStatus.expired,
        label: 'EXPIRED',
        color: AppColors.warning,
        icon: Icons.event_busy_outlined,
      );
    }

    // Event is upcoming - show days remaining
    final daysUntil = eventDate.difference(now).inDays;
    if (daysUntil == 0) {
      return _DynamicStatus(
        status: PassStatus.active,
        label: 'TODAY',
        color: AppColors.success,
        icon: Icons.event_available_outlined,
      );
    } else if (daysUntil == 1) {
      return _DynamicStatus(
        status: PassStatus.active,
        label: 'TOMORROW',
        color: AppColors.success,
        icon: Icons.event_available_outlined,
      );
    } else if (daysUntil <= 7) {
      return _DynamicStatus(
        status: PassStatus.active,
        label: 'IN $daysUntil DAYS',
        color: AppColors.primary,
        icon: Icons.upcoming_outlined,
      );
    }

    // Default active
    return _DynamicStatus(
      status: PassStatus.active,
      label: 'UPCOMING',
      color: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }

  Widget _buildHistoryCard(BuildContext context, EventPass pass, int index) {
    final dynamicStatus = _getDynamicStatus(pass);

    return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PassDetailScreen(pass: pass)),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: dynamicStatus.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              dynamicStatus.icon,
                              size: 14,
                              color: dynamicStatus.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dynamicStatus.label,
                              style: TextStyle(
                                color: dynamicStatus.color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('MMM dd, yyyy').format(pass.eventDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Event Name
                  Text(
                    pass.eventName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Venue
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          pass.venue,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Attended Info (if used)
                  if (pass.usedAt != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Attended on ${DateFormat('MMM dd').format(pass.usedAt!)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 30 * index))
        .slideY(begin: 0.05, end: 0);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_outlined,
                size: 48,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Event Passes',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Your event passes will appear here',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class for dynamic status
class _DynamicStatus {
  final PassStatus status;
  final String label;
  final Color color;
  final IconData icon;

  _DynamicStatus({
    required this.status,
    required this.label,
    required this.color,
    required this.icon,
  });
}
