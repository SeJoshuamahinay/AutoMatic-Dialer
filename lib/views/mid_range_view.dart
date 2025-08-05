import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/dialer/dialer_bloc.dart';
import '../blocs/dialer/dialer_state.dart' as state;
import '../commons/presenters/dialer_presenter.dart';
import '../commons/models/call_contact_model.dart';
import 'dialer_view.dart';

class MidRangeView extends StatefulWidget {
  const MidRangeView({super.key});

  @override
  State<MidRangeView> createState() => _MidRangeViewState();
}

class _MidRangeViewState extends State<MidRangeView> {
  late DialerPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = DialerPresenter(context.read<DialerBloc>());
    _presenter.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mid Range Bucket',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _presenter.refreshNumbers(),
            tooltip: 'Refresh Numbers',
          ),
        ],
      ),
      body: BlocBuilder<DialerBloc, state.DialerState>(
        builder: (context, currentState) {
          if (currentState is state.DialerLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading mid-range contacts...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (currentState is state.DialerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      currentState.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _presenter.initialize(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (currentState is state.DialingInProgress ||
              currentState is state.CallEnded ||
              currentState is state.NoteSaved) {
            return const DialerView();
          }

          if (currentState is state.QueueCompleted) {
            return _buildQueueCompletedView(currentState);
          }

          if (currentState is state.DialerLoaded) {
            return _buildLoadedView(currentState);
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildLoadedView(state.DialerLoaded loadedState) {
    // Filter contacts for mid-range (example: contacts with certain criteria)
    final midRangeContacts = loadedState.contacts
        .where((contact) => _isMidRangeContact(contact))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Mid-Range Contacts',
                  midRangeContacts.length.toString(),
                  Icons.phone_forwarded,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  midRangeContacts
                      .where((c) => c.status == 'pending')
                      .length
                      .toString(),
                  Icons.pending,
                  Colors.orange.shade300,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Called',
                  midRangeContacts
                      .where((c) => c.status == 'called')
                      .length
                      .toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone_forwarded,
                        size: 30,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Mid-Range Dialer',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ready to start dialing ${midRangeContacts.where((c) => c.status == 'pending').length} mid-range contacts',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          midRangeContacts
                              .where((c) => c.status == 'pending')
                              .isEmpty
                          ? null
                          : () {
                              _presenter.startDialing();
                            },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text(
                        'Start Mid-Range Dialing',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Contacts List
          Expanded(
            child: Card(
              elevation: 2,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.list, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text(
                          'Mid-Range Contacts',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${midRangeContacts.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: midRangeContacts.isEmpty
                        ? const Center(
                            child: Text(
                              'No mid-range contacts available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: midRangeContacts.length,
                            itemBuilder: (context, index) {
                              final contact = midRangeContacts[index];
                              return _buildContactTile(contact);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueCompletedView(state.QueueCompleted completedState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.orange.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Mid-Range Queue Completed!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Successfully called ${completedState.calledContacts} out of ${completedState.totalContacts} mid-range contacts',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _presenter.initialize(),
              icon: const Icon(Icons.home),
              label: const Text('Back to Mid-Range'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(CallContact contact) {
    final isCompleted = contact.status == 'called';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isCompleted
            ? Colors.green.shade100
            : Colors.orange.shade100,
        child: Icon(
          isCompleted ? Icons.check : Icons.phone_forwarded,
          color: isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
          size: 20,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            contact.borrowerName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            contact.borrowerPhone,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status: ${contact.status.toUpperCase()}',
            style: TextStyle(
              fontSize: 12,
              color: isCompleted ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (contact.note != null && contact.note!.isNotEmpty)
            Text(
              'Note: ${contact.note}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
      trailing: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green : Colors.orange,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  bool _isMidRangeContact(CallContact contact) {
    // Example logic for mid-range contacts
    // This could be based on loan amount, priority, or other criteria
    return contact.loanId != null && (contact.loanId! % 3 == 1);
  }
}
