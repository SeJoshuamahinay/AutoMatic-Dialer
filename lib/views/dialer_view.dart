import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lenderly_dialer/views/main_navigation_view.dart';
import '../blocs/dialer/dialer_bloc.dart';
import '../blocs/dialer/dialer_state.dart' as state;
import '../commons/models/call_contact_model.dart';
import '../commons/models/call_log_model.dart';
import '../commons/presenters/dialer_presenter.dart';

class DialerView extends StatefulWidget {
  const DialerView({super.key});

  @override
  State<DialerView> createState() => _DialerViewState();
}

class _DialerViewState extends State<DialerView> {
  late DialerPresenter _presenter;
  final TextEditingController _noteController = TextEditingController();
  CallStatus? _selectedCallStatus;
  int? _currentContactId; // Track current contact to reset status

  @override
  void initState() {
    super.initState();
    _presenter = DialerPresenter(context.read<DialerBloc>());
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dialer Active',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showStopDialingDialog(),
        ),
      ),
      body: BlocBuilder<DialerBloc, state.DialerState>(
        builder: (context, currentState) {
          if (currentState is state.DialingInProgress) {
            return _buildDialingInProgressView(currentState);
          }

          if (currentState is state.CallEnded) {
            return _buildCallEndedView(currentState);
          }

          if (currentState is state.NoteSaved) {
            return _buildNoteSavedView(currentState);
          }

          return const Center(child: Text('Unknown dialing state'));
        },
      ),
    );
  }

  Widget _buildDialingInProgressView(state.DialingInProgress dialingState) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(dialingState),

          const SizedBox(height: 32),

          // Current Contact Card
          _buildCurrentContactCard(dialingState.currentContact),

          const SizedBox(height: 24),

          // Call Status
          Card(
            elevation: 4,
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(
                    Icons.phone_in_talk,
                    size: 48,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Call In Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dialing ${dialingState.currentContact.borrowerPhone}',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please complete your call and return to mark it as finished',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _presenter.markCallEnded(dialingState.currentContact.id!),
              icon: const Icon(Icons.call_end),
              label: const Text(
                'Mark Call as completed',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Stop Dialing Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showStopDialingDialog(),
              icon: const Icon(Icons.stop),
              label: const Text('Stop Dialing Queue'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallEndedView(state.CallEnded callEndedState) {
    // Reset call status selection when a new contact is loaded
    if (_currentContactId != callEndedState.contact.id) {
      _currentContactId = callEndedState.contact.id;
      _selectedCallStatus = null;
      // Also clear the note controller for the new contact
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _noteController.clear();
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Progress Indicator
                  _buildProgressIndicator(callEndedState),
                  const SizedBox(height: 32),
                  // Current Contact Card
                  _buildCurrentContactCard(callEndedState.contact),
                  const SizedBox(height: 24),
                  // Note Input Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.note_add, color: Colors.blue.shade600),
                              const SizedBox(width: 8),
                              const Text(
                                'Add Call Note',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _noteController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText:
                                  'Enter notes about this call (optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Call Status Selection
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.label,
                                      color: Colors.blue.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Mark Call Status',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildStatusChip(
                                      'Finished',
                                      Icons.check_circle,
                                      Colors.green,
                                    ),
                                    _buildStatusChip(
                                      'No Answer',
                                      Icons.phone_missed,
                                      Colors.orange,
                                    ),
                                    _buildStatusChip(
                                      'Hang Up',
                                      Icons.call_end,
                                      Colors.red,
                                    ),
                                    _buildStatusChip(
                                      'Called',
                                      Icons.phone,
                                      Colors.blue,
                                    ),
                                    _buildStatusChip(
                                      'Pending',
                                      Icons.pending,
                                      Colors.purple,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _noteController.clear();
                                    _presenter.saveNote(
                                      callEndedState.contact.id!,
                                      '',
                                      CallStatus.called,
                                    );
                                    // Reset selection for next call
                                    setState(() {
                                      _selectedCallStatus = null;
                                    });
                                  },
                                  icon: const Icon(Icons.skip_next),
                                  label: const Text('Skip Note'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    // Check if status is selected
                                    if (!_isStatusSelected()) {
                                      final shouldContinue =
                                          await _promptForStatusSelection();
                                      if (!shouldContinue) return;
                                    }

                                    final note = _noteController.text.trim();
                                    _presenter.saveNote(
                                      callEndedState.contact.id!,
                                      note,
                                      _selectedCallStatus ?? CallStatus.pending,
                                    );
                                    _noteController.clear();
                                    // Reset selection for next call
                                    setState(() {
                                      _selectedCallStatus = null;
                                    });
                                  },
                                  icon: const Icon(Icons.save),
                                  label: const Text('Save & Continue'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteSavedView(state.NoteSaved noteSavedState) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(noteSavedState),

          const SizedBox(height: 32),

          // Success Message
          Card(
            elevation: 4,
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 48,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Note Saved Successfully',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Call to ${noteSavedState.contact.borrowerPhone} completed',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  if (noteSavedState.contact.note != null &&
                      noteSavedState.contact.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Note:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              noteSavedState.contact.note!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Next Actions
          if (noteSavedState.remainingContacts.isNotEmpty) ...[
            Text(
              '${noteSavedState.remainingContacts.length} contacts remaining',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _presenter.stopDialing(),
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Queue'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _presenter.nextCall(),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const Text(
              'All contacts completed!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _presenter.stopDialing();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationView(),
                    ),
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(dynamic currentState) {
    int totalContacts = 0;
    int completedContacts = 0;

    if (currentState is state.DialingInProgress) {
      totalContacts = currentState.totalContacts;
      completedContacts = currentState.calledContacts;
    } else if (currentState is state.CallEnded) {
      totalContacts = currentState.totalContacts;
      completedContacts = currentState.calledContacts;
    } else if (currentState is state.NoteSaved) {
      totalContacts = currentState.totalContacts;
      completedContacts = currentState.calledContacts;
    }

    final progress = totalContacts > 0
        ? completedContacts / totalContacts
        : 0.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progress',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  '$completedContacts / $totalContacts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% Complete',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentContactCard(CallContact contact) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.green.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue.shade200,
                        child: Text(
                          contact.borrowerName.isNotEmpty
                              ? contact.borrowerName
                                    .trim()
                                    .split(' ')
                                    .map((e) => e.isNotEmpty ? e[0] : '')
                                    .take(2)
                                    .join()
                                    .toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Loan ID: ${contact.loanId ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: contact.status == 'called'
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          contact.status == 'called'
                              ? Icons.check_circle
                              : Icons.phone,
                          color: contact.status == 'called'
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          contact.status!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: contact.status == 'called'
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(Icons.person, color: Colors.blue.shade300, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Borrower: ${contact.borrowerName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.blue.shade300, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Phone: ${contact.borrowerPhone}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.people, color: Colors.blue.shade300, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Co-maker: ${contact.coMakerName ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.phone_android,
                    color: Colors.blue.shade300,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Co-maker Phone: ${contact.coMakerPhone ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, IconData icon, Color color) {
    CallStatus? statusForLabel;
    switch (label) {
      case 'Finished':
        statusForLabel = CallStatus.finished;
        break;
      case 'No Answer':
        statusForLabel = CallStatus.noAnswer;
        break;
      case 'Hang Up':
        statusForLabel = CallStatus.hangUp;
        break;
      case 'Called':
        statusForLabel = CallStatus.called;
        break;
      case 'Pending':
        statusForLabel = CallStatus.pending;
        break;
    }

    final isSelected = _selectedCallStatus == statusForLabel;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) =>
          _handleStatusSelection(selected, statusForLabel),
      selectedColor: color,
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      showCheckmark: false,
    );
  }

  /// Handles the selection of call status chips
  Future<void> _handleStatusSelection(
    bool selected,
    CallStatus? statusForLabel,
  ) async {
    setState(() {
      _selectedCallStatus = selected ? statusForLabel : null;
    });

    // Add a small delay to ensure the UI updates properly
    await Future.delayed(const Duration(milliseconds: 100));

    // Debug print to verify selection
    print('Status selected: $_selectedCallStatus');
  }

  /// Validates if a call status has been selected
  bool _isStatusSelected() {
    return _selectedCallStatus != null;
  }

  /// Shows a dialog prompting user to select a call status
  Future<bool> _promptForStatusSelection() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Select Call Status'),
              content: const Text(
                'Please select a call status before saving the note.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showStopDialingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Stop Dialing'),
          content: const Text(
            'Are you sure you want to stop the dialing queue? Your progress will be saved.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue Dialing'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainNavigationView()),
                );
                _presenter.stopDialing();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Stop Queue'),
            ),
          ],
        );
      },
    );
  }
}
