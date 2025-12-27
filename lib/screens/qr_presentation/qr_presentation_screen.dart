import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../models/event_pass.dart';

/// QR Presentation Screen - Production-grade secure QR display
class QRPresentationScreen extends StatefulWidget {
  final EventPass pass;

  const QRPresentationScreen({super.key, required this.pass});

  @override
  State<QRPresentationScreen> createState() => _QRPresentationScreenState();
}

class _QRPresentationScreenState extends State<QRPresentationScreen> {
  late Timer _refreshTimer;
  late Timer _countdownTimer;
  int _remainingSeconds = 30;
  String _qrData = '';

  @override
  void initState() {
    super.initState();
    _generateQRData();

    // Auto-refresh QR every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _generateQRData();
    });

    // Countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remainingSeconds = _remainingSeconds > 0 ? _remainingSeconds - 1 : 30;
      });
    });
  }

  void _generateQRData() {
    // Generate time-based QR data for security
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _qrData = '${widget.pass.id}|$timestamp|${widget.pass.holderDID}';
    setState(() {
      _remainingSeconds = 30;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Entry Pass'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Event Info
              Text(
                widget.pass.eventName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(),

              const SizedBox(height: 8),

              Text(
                widget.pass.venue,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // QR Code Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // QR Code
                    QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      size: 220,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.primary,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Timer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 18,
                          color: _remainingSeconds <= 10
                              ? AppColors.warning
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Refreshes in $_remainingSeconds s',
                          style: TextStyle(
                            color: _remainingSeconds <= 10
                                ? AppColors.warning
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 32),

              // Ticket Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      'Ticket ID',
                      widget.pass.ticketId,
                      Icons.confirmation_number_outlined,
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    _buildInfoRow(
                      context,
                      'Seat/Zone',
                      widget.pass.seatZone,
                      Icons.event_seat_outlined,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // Security Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      size: 20,
                      color: AppColors.warning.withOpacity(0.9),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This QR code refreshes automatically for security. Show this screen to the verifier.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    _countdownTimer.cancel();
    super.dispose();
  }
}
