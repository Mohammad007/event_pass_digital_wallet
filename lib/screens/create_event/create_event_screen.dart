import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/event_pass.dart';

/// Create Event Screen - Form to create events and generate tickets
class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final _eventNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _seatZoneController = TextEditingController();
  final _organizerNameController = TextEditingController();
  final _attendeeNameController = TextEditingController();
  final _attendeeEmailController = TextEditingController();

  DateTime _eventDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _eventTime = const TimeOfDay(hour: 10, minute: 0);

  bool _isLoading = false;
  String? _generatedQRData;
  EventPass? _createdPass;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event & Issue Ticket'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Details Section
              _buildSectionHeader('Event Details'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name *',
                  prefixIcon: Icon(Icons.event),
                  hintText: 'e.g. Tech Conference 2025',
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Brief event description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Event Date *',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(_eventDate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Time *',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(_eventTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(
                  labelText: 'Venue *',
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'e.g. Convention Center',
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _seatZoneController,
                decoration: const InputDecoration(
                  labelText: 'Seat/Zone',
                  prefixIcon: Icon(Icons.event_seat),
                  hintText: 'e.g. VIP Section A',
                ),
              ),

              const SizedBox(height: 24),

              // Organizer Details
              _buildSectionHeader('Organizer Details'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _organizerNameController,
                decoration: const InputDecoration(
                  labelText: 'Organizer Name *',
                  prefixIcon: Icon(Icons.business),
                  hintText: 'Your organization name',
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),

              const SizedBox(height: 24),

              // Attendee Details
              _buildSectionHeader('Attendee Details'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _attendeeNameController,
                decoration: const InputDecoration(
                  labelText: 'Attendee Name',
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Ticket holder name',
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _attendeeEmailController,
                decoration: const InputDecoration(
                  labelText: 'Attendee Email',
                  prefixIcon: Icon(Icons.email),
                  hintText: 'For sending ticket',
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 32),

              // Generate Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generateTicket,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.qr_code_rounded),
                  label: Text(
                    _isLoading ? 'Generating...' : 'Generate Ticket QR',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Generated QR Code
              if (_generatedQRData != null && _createdPass != null) ...[
                const SizedBox(height: 32),
                _buildQRResult(),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.secondary,
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _eventDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _eventTime,
    );
    if (time != null) {
      setState(() => _eventTime = time);
    }
  }

  Future<void> _generateTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final wallet = provider.wallet;

      if (wallet == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wallet not found. Please setup wallet first.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Combine date and time
      final eventDateTime = DateTime(
        _eventDate.year,
        _eventDate.month,
        _eventDate.day,
        _eventTime.hour,
        _eventTime.minute,
      );

      final passId = _uuid.v4();
      final ticketId = 'TKT-${_uuid.v4().substring(0, 8).toUpperCase()}';
      final holderDID =
          'did:key:${_uuid.v4()}'; // In real app, this would be the attendee's DID

      // Issue W3C Credential via SpruceKit
      final credential = await provider.spruceKitService.issueEventTicket(
        issuerDID: wallet.did,
        holderDID: holderDID,
        eventName: _eventNameController.text.trim(),
        eventDate: eventDateTime.toIso8601String(),
        venue: _venueController.text.trim(),
        ticketId: ticketId,
        seatZone: _seatZoneController.text.trim().isNotEmpty
            ? _seatZoneController.text.trim()
            : 'General Admission',
        organizerName: _organizerNameController.text.trim(),
      );

      if (credential == null) {
        throw Exception('Failed to issue credential via SpruceKit');
      }

      // Create internal pass object for UI display
      final pass = EventPass(
        id: passId,
        eventName: _eventNameController.text.trim(),
        eventDescription: _descriptionController.text.trim(),
        eventDate: eventDateTime,
        venue: _venueController.text.trim(),
        seatZone: _seatZoneController.text.trim().isNotEmpty
            ? _seatZoneController.text.trim()
            : 'General Admission',
        ticketId: ticketId,
        organizerDID: wallet.did,
        organizerName: _organizerNameController.text.trim(),
        holderDID: holderDID,
        credentialType: 'EventTicketCredential',
        issuedAt: DateTime.now(),
        expiresAt: eventDateTime.add(const Duration(hours: 24)),
      );

      // Generate QR Data from the Verifiable Credential JWT
      // SpruceKit supports JWT-based VC presentation in QR codes
      final qrData = credential.jwt;

      if (qrData == null) throw Exception('No JWT in credential');

      // Save pass locally
      final success = await provider.addPass(pass);

      if (success) {
        setState(() {
          _generatedQRData = qrData;
          _createdPass = pass;
        });

        debugPrint('Ticket VC generated: $ticketId');
        debugPrint('VC JWT Length: ${qrData.length}');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save ticket locally'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error generating ticket: $e');
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

  Widget _buildQRResult() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Ticket Generated!',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textLight.withOpacity(0.3)),
              ),
              child: QrImageView(
                data: _generatedQRData!,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Ticket Info
            Text(
              _createdPass!.eventName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Ticket ID: ${_createdPass!.ticketId}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat(
                'EEE, MMM dd, yyyy • hh:mm a',
              ).format(_createdPass!.eventDate),
              style: TextStyle(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Copy QR data
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('QR data copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy QR Data'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Create another
                      setState(() {
                        _generatedQRData = null;
                        _createdPass = null;
                        _eventNameController.clear();
                        _descriptionController.clear();
                        _attendeeNameController.clear();
                        _attendeeEmailController.clear();
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Another'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _seatZoneController.dispose();
    _organizerNameController.dispose();
    _attendeeNameController.dispose();
    _attendeeEmailController.dispose();
    super.dispose();
  }
}
