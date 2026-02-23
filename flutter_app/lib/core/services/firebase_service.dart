import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../api/api_client.dart';
import '../constants/api_constants.dart';
import '../../firebase_options.dart';

// Must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background processing
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;

  Future<void> init() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // Initialize Local Notifications for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (defaultTargetPlatform == TargetPlatform.android) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
            
        // Setup default init settings
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/launcher_icon');
        const InitializationSettings initializationSettings = InitializationSettings(
            android: initializationSettingsAndroid,
        );
        await flutterLocalNotificationsPlugin.initialize(
          settings: initializationSettings,
        );
    }

    // Update FCM options for Android foreground messages to show as heads-up
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Register Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get the device token
    String? token = await _firebaseMessaging.getToken();
    _fcmToken = token;
    debugPrint("FirebaseMessaging Token: $token");

    // Send token to backend (will fail silently if not logged in)
    if (token != null) {
      registerTokenWithBackend(token);
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint("FirebaseMessaging Token Refreshed: $newToken");
      _fcmToken = newToken;
      registerTokenWithBackend(newToken);
    });

    // Foreground messages handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/launcher_icon',
            ),
          ),
        );
      }
    });
  }

  /// Re-registers the current FCM token with the backend.
  /// Call this after successful login.
  Future<void> registerCurrentToken() async {
    if (_fcmToken != null) {
      await registerTokenWithBackend(_fcmToken!);
    }
  }

  /// Sends the FCM token to the backend for push notification targeting.
  Future<void> registerTokenWithBackend(String token) async {
    try {
      final apiClient = ApiClient();
      await apiClient.dio.post(
        ApiConstants.registerFcmToken,
        data: {'token': token},
      );
      debugPrint('FCM token registered with backend successfully');
    } catch (e) {
      debugPrint('Failed to register FCM token with backend: $e');
    }
  }
}
