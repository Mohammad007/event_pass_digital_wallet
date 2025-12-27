import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/event_pass.dart';
import '../qr_presentation/qr_presentation_screen.dart';

/// Event Pass Detail Screen - Production-grade single ticket view
class PassDetailScreen extends StatelessWidget {
  final EventPass pass;

  const PassDetailScreen({super.key, required this.pass});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: _getStatusColor(pass.status),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(context),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Description
                  if (pass.eventDescription.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.description_outlined,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'About Event',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              pass.eventDescription,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 12),

                  // Event Details Card
                  _buildDetailsCard(context),

                  const SizedBox(height: 12),

                  // Ticket Details Card
                  _buildTicketCard(context),

                  const SizedBox(height: 12),

                  // Organizer Details Card
                  _buildOrganizerCard(context),

                  const SizedBox(height: 24),

                  // Action Button
                  _buildActionButton(context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _getStatusColor(pass.status)),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusText(pass.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Event Name
            Text(
              pass.eventName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Quick Info
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('EEE, MMM dd, yyyy').format(pass.eventDate),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Event Details',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              Icons.calendar_today_rounded,
              'Date',
              DateFormat('EEEE, MMMM dd, yyyy').format(pass.eventDate),
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              Icons.access_time_rounded,
              'Time',
              DateFormat('hh:mm a').format(pass.eventDate),
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              Icons.location_on_rounded,
              'Venue',
              pass.venue,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              Icons.event_seat_rounded,
              'Seat/Zone',
              pass.seatZone,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildTicketCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.confirmation_number,
                  size: 20,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ticket Information',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(context, Icons.tag, 'Ticket ID', pass.ticketId),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              Icons.verified_rounded,
              'Credential Type',
              pass.credentialType,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              Icons.schedule_rounded,
              'Issued At',
              DateFormat('MMM dd, yyyy • hh:mm a').format(pass.issuedAt),
            ),
            if (pass.expiresAt != null) ...[
              const Divider(height: 24),
              _buildDetailRow(
                context,
                Icons.event_busy_rounded,
                'Expires At',
                DateFormat('MMM dd, yyyy • hh:mm a').format(pass.expiresAt!),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildOrganizerCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, size: 20, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'Organizer',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              Icons.person_rounded,
              'Name',
              pass.organizerName,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              Icons.fingerprint_rounded,
              'DID',
              _truncateString(pass.organizerDID, 30),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (pass.isValid) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QRPresentationScreen(pass: pass),
              ),
            );
          },
          icon: const Icon(Icons.qr_code_2_rounded),
          label: const Text('Show QR Code for Entry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pass.isUsed
                  ? 'This pass has already been used'
                  : 'This pass is no longer valid',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Safely truncate string to avoid RangeError
  String _truncateString(String str, int maxLength) {
    if (str.length <= maxLength) return str;
    return '${str.substring(0, maxLength)}...';
  }

  Color _getStatusColor(PassStatus status) {
    switch (status) {
      case PassStatus.active:
        return AppColors.success;
      case PassStatus.used:
        return AppColors.info;
      case PassStatus.expired:
        return AppColors.warning;
      case PassStatus.revoked:
        return AppColors.error;
    }
  }

  String _getStatusText(PassStatus status) {
    switch (status) {
      case PassStatus.active:
        return 'ACTIVE';
      case PassStatus.used:
        return 'USED';
      case PassStatus.expired:
        return 'EXPIRED';
      case PassStatus.revoked:
        return 'REVOKED';
    }
  }
}
