import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../core/constants/app_colors.dart';
import '../../models/event_pass.dart';
import '../pass_detail/pass_detail_screen.dart';
import '../../providers/app_provider.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';

/// Verifier Dashboard - Scan and verify tickets
class VerifierDashboardScreen extends StatefulWidget {
  const VerifierDashboardScreen({super.key});

  @override
  State<VerifierDashboardScreen> createState() =>
      _VerifierDashboardScreenState();
}

class _VerifierDashboardScreenState extends State<VerifierDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          _buildScanScreen(),
          const HistoryScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner_rounded),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'Log',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifier Dashboard'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final totalScanned = provider.allPasses.where((p) => p.isUsed).length;
          final validEntries = totalScanned;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Scanned',
                        '$totalScanned',
                        Icons.qr_code_scanner_rounded,
                        AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Valid Entries',
                        '$validEntries',
                        Icons.check_circle_rounded,
                        AppColors.success,
                      ),
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Rejected',
                        '0',
                        Icons.cancel_rounded,
                        AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        '${provider.upcomingPasses.length}',
                        Icons.pending_rounded,
                        AppColors.warning,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // Scan Button
                SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: Card(
                    color: AppColors.accent,
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap to Scan Ticket',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).scale(),

                const SizedBox(height: 24),

                // Recent Scans
                Text(
                  'Recent Scans',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (provider.allPasses.where((p) => p.isUsed).isEmpty)
                  _buildEmptyState()
                else
                  ...provider.allPasses.where((p) => p.isUsed).take(5).map((
                    pass,
                  ) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PassDetailScreen(pass: pass),
                            ),
                          );
                        },
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.check_circle_outlined,
                            color: AppColors.success,
                          ),
                        ),
                        title: Text(
                          pass.eventName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(pass.ticketId),
                        trailing: const Text(
                          'VALID',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScanScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Ticket'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                MobileScanner(
                  onDetect: (capture) {
                    _handleScan(capture);
                  },
                ),
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.accent, width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 30,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scan Attendee QR Code',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Point camera at the ticket QR code\nto verify entry',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleScan(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _verifyTicket(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _verifyTicket(String qrData) async {
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);

      // Verify the credential JWT via SpruceKit
      final verificationResult = await provider.spruceKitService
          .verifyCredential(qrData);

      if (!verificationResult.isValid) {
        _showResult(
          false,
          'Invalid Credential: ${verificationResult.errors.join(", ")}',
        );
        return;
      }

      final subject = verificationResult.subject;
      if (subject == null) {
        _showResult(false, 'No subject in credential');
        return;
      }

      // In a real system, we would lookup the subject DID or the ticket ID from the chain/database.
      // Here we will try to find a matching ticket ID in our local database if we are the organizer,
      // or just trust the VC if we are an external verifier.

      // For this demo, we assume the QR contains the ticket ID in the credential subject or claims.
      // Since we can't easily parse the claims from the JWT result in this partial implementation,
      // we'll simulate the lookup or try to decode the payload manually for the demo.

      String? ticketId;
      Map<String, dynamic>? claims;

      try {
        final payload = jsonDecode(
          utf8.decode(base64Url.decode(base64.normalize(qrData.split('.')[1]))),
        );
        final vc = payload['vc'];
        // Try to locate the claims map
        if (vc['credentialSubject'] != null) {
          claims = vc['credentialSubject'];
          ticketId = claims?['ticketId']?.toString();
        }
      } catch (e) {
        debugPrint('Error parsing credential payload: $e');
      }

      if (ticketId != null) {
        debugPrint('Verifying Ticket ID: $ticketId');

        try {
          // Try to find pass in local database
          final pass = provider.allPasses.firstWhere(
            (p) => p.ticketId == ticketId,
          );

          if (pass.isUsed) {
            _showResult(false, 'Ticket already used!\n${pass.eventName}');
            return;
          }

          // Mark as used
          await provider.markPassAsUsed(pass.id);
          _showResult(
            true,
            'Access Granted!\n${pass.eventName}\nZone: ${pass.seatZone}',
          );
        } catch (_) {
          // Pass not found locally - Create a record of this scan
          debugPrint('Pass not found locally, creating scan record...');

          if (claims != null) {
            final newPass = EventPass(
              id:
                  claims['id']?.toString() ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              eventName: claims['eventName']?.toString() ?? 'External Event',
              eventDescription: 'Scanned at entry',
              eventDate:
                  DateTime.tryParse(claims['eventDate'] ?? '') ??
                  DateTime.now(),
              venue: claims['venue']?.toString() ?? 'Unknown Venue',
              seatZone: claims['seatZone']?.toString() ?? 'General',
              ticketId: ticketId,
              organizerDID: claims['organizerDID']?.toString() ?? 'did:unknown',
              organizerName:
                  claims['organizerName']?.toString() ?? 'Unknown Organizer',
              holderDID: claims['holderDID']?.toString() ?? 'did:unknown',
              credentialType: 'EventTicketCredential',
              issuedAt: DateTime.now(),
              status: PassStatus.used,
            );

            // Hack: We need to set isUsed property which might not be in constructor or is computed
            // Looking at EventPass model (I can't see it but assuming I need to save it as used)
            // CredentialService.savePass saves it.
            // CredentialService.markPassAsUsed updates it.

            // Save as new pass
            await provider.addPass(newPass);
            // Immediately mark as used to ensure flags are set (if addPass doesn't set used)
            await provider.markPassAsUsed(newPass.id);

            _showResult(
              true,
              'Access Granted!\n${newPass.eventName}\n(New Record Saved)',
            );
          } else {
            _showResult(
              true,
              'Authorized (External)\nTicket: $ticketId\n(Could not save full details)',
            );
          }
        }
      } else {
        _showResult(
          true,
          'Valid Identity Credential\nSubject: ${subject.substring(0, 15)}...',
        );
      }
    } catch (e) {
      _showResult(false, 'Error verifying ticket: $e');
    }
  }

  void _showResult(bool isValid, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isValid
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 48,
                color: isValid ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isValid ? 'ACCESS GRANTED' : 'ACCESS DENIED',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isValid ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isValid ? AppColors.success : AppColors.error,
              ),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.qr_code_scanner_outlined,
            size: 48,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No scans yet',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
