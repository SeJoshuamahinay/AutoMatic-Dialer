import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'api_client.dart';
import 'environment_config.dart';

/// Minimal Pusher-protocol client for Laravel Reverb.
///
/// `pusher_channels_flutter` only supports Pusher.com's cluster-based
/// routing (no host/port override), so it can't reach a self-hosted Reverb
/// server. Reverb speaks the same wire protocol as Pusher, and we only need
/// a private channel + a handful of named events, so a small hand-rolled
/// client over [WebSocketChannel] is less code than working around a
/// plugin that doesn't fit.
class TrackingSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  String? _deviceId;
  String? _socketId;
  bool _subscribed = false;
  int _reconnectAttempt = 0;
  bool _manuallyDisconnected = false;

  void Function(int intervalSeconds)? onStartTracking;
  void Function(int intervalSeconds)? onChangeInterval;
  void Function(String requestId)? onRequestLocation;
  void Function()? onStopTracking;
  void Function()? onStopService;
  void Function(bool connected)? onConnectionStateChange;

  String get _channelName => 'private-device.$_deviceId';

  bool get isSubscribed => _subscribed;

  Future<void> connect(String deviceId) async {
    _deviceId = deviceId;
    _manuallyDisconnected = false;
    await _openSocket();
  }

  Future<void> disconnect() async {
    _manuallyDisconnected = true;
    _reconnectTimer?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _subscribed = false;
  }

  Future<void> _openSocket() async {
    final scheme = EnvironmentConfig.reverbScheme == 'https' ? 'wss' : 'ws';
    final uri = Uri.parse(
      '$scheme://${EnvironmentConfig.reverbHost}:${EnvironmentConfig.reverbPort}'
      '/app/${EnvironmentConfig.reverbAppKey}?protocol=7&client=flutter&version=1.0',
    );
    debugPrint('[TrackingSocket] connecting to $uri');

    try {
      _channel = WebSocketChannel.connect(uri);
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onDone: () {
          debugPrint('[TrackingSocket] socket closed (onDone)');
          _handleDisconnect();
        },
        onError: (e) {
          debugPrint('[TrackingSocket] socket error: $e');
          _handleDisconnect();
        },
      );
    } catch (e) {
      debugPrint('[TrackingSocket] failed to open socket: $e');
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _subscribed = false;
    onConnectionStateChange?.call(false);
    if (_manuallyDisconnected) return;

    _reconnectAttempt++;
    final delaySeconds = min(30, pow(2, _reconnectAttempt).toInt());
    debugPrint('[TrackingSocket] reconnecting in ${delaySeconds}s (attempt $_reconnectAttempt)');
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), _openSocket);
  }

  void _handleMessage(dynamic raw) {
    debugPrint('[TrackingSocket] raw message: $raw');
    final message = jsonDecode(raw as String) as Map<String, dynamic>;
    final event = message['event'] as String?;

    switch (event) {
      case 'pusher:connection_established':
        final data = jsonDecode(message['data'] as String) as Map<String, dynamic>;
        _socketId = data['socket_id'] as String?;
        _reconnectAttempt = 0;
        debugPrint('[TrackingSocket] connection established, socket_id=$_socketId');
        onConnectionStateChange?.call(true);
        _subscribeToDeviceChannel();
        break;

      case 'pusher:ping':
        _send({'event': 'pusher:pong', 'data': {}});
        break;

      case 'pusher_internal:subscription_succeeded':
        _subscribed = true;
        debugPrint('[TrackingSocket] subscribed to $_channelName');
        break;

      case 'pusher:subscription_error':
        _subscribed = false;
        debugPrint('[TrackingSocket] subscription error for $_channelName');
        break;

      case 'start_tracking':
        final interval = _intData(message, 'interval_seconds');
        debugPrint('[TrackingSocket] received start_tracking, interval=${interval}s');
        onStartTracking?.call(interval);
        break;

      case 'change_interval':
        final interval = _intData(message, 'interval_seconds');
        debugPrint('[TrackingSocket] received change_interval, interval=${interval}s');
        onChangeInterval?.call(interval);
        break;

      case 'request_location':
        final requestId = _stringData(message, 'request_id');
        debugPrint('[TrackingSocket] received request_location, id=$requestId');
        onRequestLocation?.call(requestId);
        break;

      case 'stop_tracking':
        debugPrint('[TrackingSocket] received stop_tracking');
        onStopTracking?.call();
        break;

      case 'stop_service':
        debugPrint('[TrackingSocket] received stop_service');
        onStopService?.call();
        break;
    }
  }

  int _intData(Map<String, dynamic> message, String key) {
    final data = jsonDecode(message['data'] as String) as Map<String, dynamic>;
    return (data[key] as num).toInt();
  }

  String _stringData(Map<String, dynamic> message, String key) {
    final data = jsonDecode(message['data'] as String) as Map<String, dynamic>;
    return data[key] as String;
  }

  Future<void> _subscribeToDeviceChannel() async {
    if (_socketId == null || _deviceId == null) return;

    debugPrint('[TrackingSocket] requesting auth for $_channelName');
    final response = await ApiClient.post(
      '/broadcasting/auth',
      body: {'channel_name': _channelName, 'socket_id': _socketId},
    );

    if (response.statusCode != 200) {
      debugPrint('[TrackingSocket] auth failed (HTTP ${response.statusCode}): ${response.body}');
      return;
    }

    final auth = (jsonDecode(response.body) as Map<String, dynamic>)['auth'] as String;

    _send({
      'event': 'pusher:subscribe',
      'data': {'channel': _channelName, 'auth': auth},
    });
    debugPrint('[TrackingSocket] subscribe request sent for $_channelName');
  }

  void _send(Map<String, dynamic> payload) {
    _channel?.sink.add(jsonEncode(payload));
  }
}
