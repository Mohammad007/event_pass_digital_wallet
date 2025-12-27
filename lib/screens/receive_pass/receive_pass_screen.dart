import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/event_pass.dart';

/// Receive Event Pass Screen - Production-grade pass receiver
class ReceivePassScreen extends StatefulWidget {
  const ReceivePassScreen({super.key});

  @override
  State<ReceivePassScreen> createState() => _ReceivePassScreenState();
}

class _ReceivePassScreenState extends State<ReceivePassScreen> {
  final _codeController = TextEditingController();
  final _uuid = const Uuid();
  bool _isScanning = true;
  bool _isProcessing = false;
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event Pass'),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() => _isScanning = !_isScanning);
            },
            icon: Icon(
              _isScanning ? Icons.keyboard : Icons.qr_code_scanner,
              color: Colors.black,
            ),
            label: Text(
              _isScanning ? 'Manual' : 'Scan',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: _isScanning ? _buildScanner() : _buildManualEntry(),
    );
  }

  Widget _buildScanner() {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  if (_isProcessing) return;

                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      _processQRCode(barcode.rawValue!);
                      break;
                    }
                  }
                },
              ),
              // Overlay with frame
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Corner decorations
                      ..._buildCornerDecorations(),
                    ],
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
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Scan QR Code',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Position the event QR code within the frame\nto receive your pass',
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
    );
  }

  List<Widget> _buildCornerDecorations() {
    const cornerSize = 20.0;
    const strokeWidth = 4.0;

    return [
      // Top-left
      Positioned(
        top: -2,
        left: -2,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.primary, width: strokeWidth),
              left: BorderSide(color: AppColors.primary, width: strokeWidth),
            ),
          ),
        ),
      ),
      // Top-right
      Positioned(
        top: -2,
        right: -2,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.primary, width: strokeWidth),
              right: BorderSide(color: AppColors.primary, width: strokeWidth),
            ),
          ),
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: -2,
        left: -2,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.primary, width: strokeWidth),
              left: BorderSide(color: AppColors.primary, width: strokeWidth),
            ),
          ),
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: -2,
        right: -2,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.primary, width: strokeWidth),
              right: BorderSide(color: AppColors.primary, width: strokeWidth),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildManualEntry() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.keyboard_rounded,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Enter Event Code',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Paste the event pass code provided by the organizer',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Code Input
          TextField(
            controller: _codeController,
            decoration: const InputDecoration(
              hintText: 'Paste event pass code here...',
              prefixIcon: Icon(Icons.code),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 24),

          // Add Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isProcessing
                  ? null
                  : () => _processQRCode(_codeController.text),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.add_rounded),
              label: Text(_isProcessing ? 'Processing...' : 'Add Pass'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: 24),

          // Demo Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _addDemoPass,
              icon: const Icon(Icons.science_outlined),
              label: const Text('Add Demo Pass (Testing)'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processQRCode(String qrData) async {
    if (_isProcessing) return;

    final trimmedData = qrData.trim();
    if (trimmedData.isEmpty) {
      _showError('Please enter pass data');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      debugPrint(
        'Processing QR data: ${trimmedData.substring(0, trimmedData.length > 20 ? 20 : trimmedData.length)}...',
      );

      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final wallet = appProvider.wallet;

      if (wallet == null) {
        _showError('Wallet not found. Please create a wallet first.');
        return;
      }

      // Check if it's a JWT (SpruceKit/W3C VC)
      if (trimmedData.contains('.') && trimmedData.split('.').length == 3) {
        debugPrint('Detected JWT Credential');

        // Verify with SpruceKit
        final verification = await appProvider.spruceKitService
            .verifyCredential(trimmedData);
        if (!verification.isValid) {
          _showError('Invalid Credential: ${verification.errors.join(", ")}');
          return;
        }

        // Decode JWT payload to extract pass details
        // In a real implementation, we would use a proper JWT library or SpruceKit's parsed result
        // if it exposed the full claim set. Since verifyCredential currently returns a summary,
        // we'll manually decode the payload part for the UI display.
        final parts = trimmedData.split('.');
        final payload = jsonDecode(
          utf8.decode(base64Url.decode(base64.normalize(parts[1]))),
        );

        final vc = payload['vc'];
        final claims = vc['credentialSubject'];

        final pass = EventPass(
          id:
              claims['id'] ??
              _uuid.v4(), // Use subject ID or generate new local ID
          eventName: claims['eventName']?.toString() ?? 'Event',
          eventDate: DateTime.parse(claims['eventDate']),
          venue: claims['venue']?.toString() ?? 'Venue',
          ticketId: claims['ticketId']?.toString() ?? 'TICKET',
          status: PassStatus.active,
          seatZone: claims['seatZone']?.toString() ?? 'General Admission',
          organizerName: claims['organizerName']?.toString() ?? 'Organizer',
          organizerDID: payload['iss']?.toString() ?? 'did:unknown',
          eventDescription: '',
          credentialType: 'EventTicketCredential',
          issuedAt: DateTime.fromMillisecondsSinceEpoch(
            (payload['nbf'] ?? 0) * 1000,
          ),
          holderDID: payload['sub'],
          expiresAt: payload['exp'] != null
              ? DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000)
              : null,
        );

        // Add pass to wallet
        await appProvider.addPass(pass);

        if (mounted) {
          setState(() => _isProcessing = false);
          Navigator.pop(context); // Close scanner if open
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Accepted: ${pass.eventName}')),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // Fallback to legacy JSON format
      final data = jsonDecode(trimmedData) as Map<String, dynamic>;

      // Parse event date
      final eventDateStr = data['eventDate'] as String?;
      if (eventDateStr == null) {
        _showError('Event date is required');
        return;
      }

      final eventDate = DateTime.parse(eventDateStr);

      // Parse optional expires date
      DateTime? expiresAt;
      if (data['expiresAt'] != null) {
        expiresAt = DateTime.parse(data['expiresAt'] as String);
      }

      final pass = EventPass(
        id: data['passId']?.toString() ?? _uuid.v4(),
        eventName: data['eventName']?.toString() ?? 'Event',
        eventDescription: data['eventDescription']?.toString() ?? '',
        eventDate: eventDate,
        venue: data['venue']?.toString() ?? 'Venue',
        seatZone: data['seatZone']?.toString() ?? 'General',
        ticketId: data['ticketId']?.toString() ?? _uuid.v4(),
        organizerDID:
            data['organizerDID']?.toString() ?? 'did:organizer:unknown',
        organizerName: data['organizerName']?.toString() ?? 'Event Organizer',
        holderDID: wallet.did,
        credentialType: 'EventTicketCredential',
        issuedAt: DateTime.now(),
        expiresAt: expiresAt,
      );

      debugPrint('Created pass: ${pass.eventName}');

      final accepted = await _showPassPreview(pass);

      if (accepted == true) {
        final success = await appProvider.addPass(pass);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event pass added successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else {
          _showError('Failed to save pass to database');
        }
      }
    } on FormatException catch (e) {
      debugPrint('JSON parse error: $e');
      _showError('Invalid JSON format: ${e.message}');
    } catch (e) {
      debugPrint('Error processing QR: $e');
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool?> _showPassPreview(EventPass pass) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Accept Event Pass?',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildPreviewRow('Event', pass.eventName),
            _buildPreviewRow(
              'Date',
              DateFormat('EEE, MMM dd, yyyy').format(pass.eventDate),
            ),
            _buildPreviewRow('Venue', pass.venue),
            _buildPreviewRow('Seat/Zone', pass.seatZone),
            _buildPreviewRow('Organizer', pass.organizerName),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addDemoPass() async {
    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final wallet = appProvider.wallet;

      if (wallet == null) {
        _showError('Wallet not found. Please create a wallet first.');
        return;
      }

      debugPrint('Creating demo pass for wallet: ${wallet.did}');

      final demoPass = EventPass(
        id: _uuid.v4(),
        eventName: 'Tech Conference 2025',
        eventDescription:
            'Annual technology conference featuring industry leaders, workshops, and networking opportunities.',
        eventDate: DateTime.now().add(const Duration(days: 30)),
        venue: 'Convention Center, Downtown',
        seatZone: 'VIP Section A',
        ticketId: 'DEMO-${_uuid.v4().substring(0, 8).toUpperCase()}',
        organizerDID: 'did:key:z6MkDemo123456789abcdef',
        organizerName: 'TechEvents Inc.',
        holderDID: wallet.did,
        credentialType: 'EventTicketCredential',
        issuedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 31)),
      );

      debugPrint('Demo pass created: ${demoPass.id}');

      final success = await appProvider.addPass(demoPass);

      debugPrint('Demo pass save result: $success');

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demo pass added successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        _showError('Failed to save demo pass');
      }
    } catch (e) {
      debugPrint('Error adding demo pass: $e');
      _showError('Error: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }
}
