import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lenderly_dialer/commons/models/auth_models.dart';
import 'package:lenderly_dialer/views/follow_up_form_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const _testSubjects = [
    'Collection Follow-up',
    'Payment Reminder',
    'Field Visit',
  ];

  final _mockSession = UserSession(
    userId: 7,
    email: 'agent@test.com',
    fullName: 'Test Agent',
    loginType: 'sanctum',
    loginTime: DateTime(2026, 6, 1),
    token: 'fake-token-abc',
  );

  setUpAll(() {
    // Pre-load dotenv so EnvironmentConfig.initialize() does not fail when
    // the asset bundle is unavailable in the test runner.
    dotenv.testLoad(
      fileInput:
          'API_BASE_URL=http://127.0.0.1:8000\n'
          'API_TIMEOUT=30000\n'
          'DEBUG_MODE=true\n'
          'LOG_LEVEL=debug\n',
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'fake-token-abc',
      'user_session': jsonEncode(_mockSession.toJson()),
    });
  });

  // ── helpers ──────────────────────────────────────────────────────────────

  Widget _buildWidget() {
    return const MaterialApp(
      home: FollowUpFormView(
        loanId: 42,
        borrowerId: 10,
        borrowerName: 'Juan dela Cruz',
      ),
    );
  }

  /// Returns a [MockClient] that serves fake subjects and optionally a
  /// customisable LAFU response.
  MockClient _mockClient({
    int lafuStatus = 201,
    Map<String, dynamic>? lafuBody,
  }) {
    return MockClient((request) async {
      if (request.url.path.endsWith('lafuSubjects')) {
        return http.Response(
          jsonEncode({'success': true, 'data': _testSubjects}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      if (request.url.path.endsWith('lafu')) {
        return http.Response(
          jsonEncode(lafuBody ?? {'success': true, 'message': 'Recorded.'}),
          lafuStatus,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response('Not found', 404);
    });
  }

  // Selects the first subject from the dropdown after subjects have loaded.
  Future<void> _selectFirstSubject(WidgetTester tester) async {
    final subjectDropdown = find.byType(DropdownButtonFormField<String>).first;
    await tester.tap(subjectDropdown);
    await tester.pumpAndSettle();
    // Tap the last occurrence to avoid hitting the button itself.
    await tester.tap(find.text(_testSubjects[0]).last);
    await tester.pumpAndSettle();
  }

  // Taps a "Select date" widget and confirms the default date via OK.
  Future<void> _pickDate(WidgetTester tester) async {
    await tester.tap(find.text('Select date').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  // ── tests ─────────────────────────────────────────────────────────────────

  group('FollowUpFormView – UI', () {
    testWidgets('renders app bar title and borrower name', (tester) async {
      await http.runWithClient(() async {
        await tester.pumpWidget(_buildWidget());
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Add Follow-up'), findsOneWidget);
        expect(find.text('Juan dela Cruz'), findsOneWidget);
        expect(find.text('Save Follow-up'), findsOneWidget);
      }, _mockClient);
    });

    testWidgets('shows loading spinner then subject dropdown', (tester) async {
      await http.runWithClient(() async {
        await tester.pumpWidget(_buildWidget());

        // Spinner is visible immediately (before subjects arrive).
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // After subjects load the dropdown should be there.
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(DropdownButtonFormField<String>), findsWidgets);
      }, _mockClient);
    });
  });

  group('FollowUpFormView – validation', () {
    testWidgets(
      'shows "Subject is required" when form submitted without subject',
      (tester) async {
        await http.runWithClient(() async {
          await tester.pumpWidget(_buildWidget());
          await tester.pump(const Duration(seconds: 1));

          await tester.ensureVisible(find.text('Save Follow-up'));
          await tester.tap(find.text('Save Follow-up'));
          await tester.pump();

          expect(find.text('Subject is required'), findsOneWidget);
        }, _mockClient);
      },
    );

    testWidgets('shows snackbar when date of contact is missing', (
      tester,
    ) async {
      await http.runWithClient(() async {
        await tester.pumpWidget(_buildWidget());
        await tester.pump(const Duration(seconds: 1));

        await _selectFirstSubject(tester);

        // Submit without picking any date.
        await tester.ensureVisible(find.text('Save Follow-up'));
        await tester.tap(find.text('Save Follow-up'));
        await tester.pump();

        expect(find.text('Please select a date of contact'), findsOneWidget);
      }, _mockClient);
    });

    testWidgets('shows snackbar when action date is missing', (tester) async {
      await http.runWithClient(() async {
        await tester.pumpWidget(_buildWidget());
        await tester.pump(const Duration(seconds: 1));

        await _selectFirstSubject(tester);
        await _pickDate(tester); // sets dateOfContact
        // actionDate still missing

        await tester.ensureVisible(find.text('Save Follow-up'));
        await tester.tap(find.text('Save Follow-up'));
        await tester.pump();

        expect(find.text('Please select an action date'), findsOneWidget);
      }, _mockClient);
    });
  });

  group('FollowUpFormView – save POST', () {
    testWidgets('POSTs correct payload and shows success snackbar', (
      tester,
    ) async {
      Map<String, dynamic>? capturedPayload;
      String? capturedAuth;

      final client = MockClient((request) async {
        if (request.url.path.endsWith('lafuSubjects')) {
          return http.Response(
            jsonEncode({'success': true, 'data': _testSubjects}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path.endsWith('lafu')) {
          capturedAuth = request.headers['Authorization'];
          capturedPayload = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({'success': true, 'message': 'Recorded.'}),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      });

      await http.runWithClient(() async {
        await tester.pumpWidget(_buildWidget());
        await tester.pump(const Duration(seconds: 1));

        await _selectFirstSubject(tester);
        await _pickDate(tester); // dateOfContact
        await _pickDate(tester); // actionDate

        await tester.ensureVisible(find.text('Save Follow-up'));
        await tester.tap(find.text('Save Follow-up'));
        await tester.pump(const Duration(seconds: 2));

        // Verify request payload.
        expect(capturedPayload, isNotNull);
        expect(capturedPayload!['loan_id'], equals(42));
        expect(capturedPayload!['borrower_id'], equals(10));
        expect(capturedPayload!['action_person_id'], equals(7));
        expect(capturedPayload!['subject'], equals(_testSubjects[0]));
        expect(capturedPayload!['mode_of_contact'], isA<String>());
        expect(capturedPayload!['mode_of_payment'], isA<String>());
        expect(
          capturedPayload!['date_of_contact'],
          matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')),
        );
        expect(
          capturedPayload!['action_date'],
          matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')),
        );
        expect(capturedPayload!['recovery_likelihood'], isA<String>());

        // Verify bearer token is forwarded.
        expect(capturedAuth, equals('Bearer fake-token-abc'));

        // Verify success snackbar.
        expect(find.text('Follow-up recorded successfully!'), findsOneWidget);
      }, () => client);
    });

    testWidgets('POSTs optional fields when filled', (tester) async {
      Map<String, dynamic>? capturedPayload;

      final client = MockClient((request) async {
        if (request.url.path.endsWith('lafuSubjects')) {
          return http.Response(
            jsonEncode({'success': true, 'data': _testSubjects}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path.endsWith('lafu')) {
          capturedPayload = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({'success': true}),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      });

      await http.runWithClient(() async {
        await tester.pumpWidget(_buildWidget());
        await tester.pump(const Duration(seconds: 1));

        await _selectFirstSubject(tester);
        await _pickDate(tester);
        await _pickDate(tester);

        // Fill optional text fields.
        await tester.enterText(
          find.widgetWithText(TextFormField, '').first,
          'Borrower promised to pay on Friday',
        );
        await tester.ensureVisible(find.text('Save Follow-up'));
        await tester.tap(find.text('Save Follow-up'));
        await tester.pump(const Duration(seconds: 2));

        expect(capturedPayload, isNotNull);
        // At least one optional field should be present.
        expect(
          capturedPayload!.containsKey('discussion_notes') ||
              capturedPayload!.containsKey('follow_up_action_notes') ||
              capturedPayload!.containsKey('message'),
          isTrue,
        );
      }, () => client);
    });

    testWidgets('shows error snackbar on HTTP 422 server error', (
      tester,
    ) async {
      await http.runWithClient(
        () async {
          await tester.pumpWidget(_buildWidget());
          await tester.pump(const Duration(seconds: 1));

          await _selectFirstSubject(tester);
          await _pickDate(tester);
          await _pickDate(tester);

          await tester.ensureVisible(find.text('Save Follow-up'));
          await tester.tap(find.text('Save Follow-up'));
          await tester.pump(const Duration(seconds: 2));

          expect(
            find.textContaining('Failed to save follow-up'),
            findsOneWidget,
          );
        },
        () => _mockClient(
          lafuStatus: 422,
          lafuBody: {'message': 'Unprocessable Entity'},
        ),
      );
    });

    testWidgets('shows error snackbar when auth token is missing', (
      tester,
    ) async {
      // Override prefs to have no token.
      SharedPreferences.setMockInitialValues({});

      await http.runWithClient(() async {
        await tester.pumpWidget(_buildWidget());
        await tester.pump(const Duration(seconds: 1));

        await _selectFirstSubject(tester);
        await _pickDate(tester);
        await _pickDate(tester);

        await tester.ensureVisible(find.text('Save Follow-up'));
        await tester.tap(find.text('Save Follow-up'));
        await tester.pump(const Duration(seconds: 1));

        expect(
          find.textContaining('Authentication token missing'),
          findsOneWidget,
        );
      }, _mockClient);
    });

    testWidgets('button shows "Saving..." while request is in flight', (
      tester,
    ) async {
      // Use a client that never completes the LAFU request during the test.
      final client = MockClient((request) async {
        if (request.url.path.endsWith('lafuSubjects')) {
          return http.Response(
            jsonEncode({'success': true, 'data': _testSubjects}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        // Simulate a slow server.
        await Future<void>.delayed(const Duration(seconds: 30));
        return http.Response('{}', 201);
      });

      await http.runWithClient(() async {
        await tester.pumpWidget(_buildWidget());
        await tester.pump(const Duration(seconds: 1));

        await _selectFirstSubject(tester);
        await _pickDate(tester);
        await _pickDate(tester);

        await tester.ensureVisible(find.text('Save Follow-up'));
        await tester.tap(find.text('Save Follow-up'));

        // One pump without completing async work → should see "Saving...".
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Saving...'), findsOneWidget);
      }, () => client);
    });
  });
}
