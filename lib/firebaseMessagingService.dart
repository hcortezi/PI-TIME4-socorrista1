import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initializeFirebaseMessaging() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      announcement: true,
      criticalAlert: true,
      alert: true,
      badge: true,
      sound: true,
    );
    print('Permissão concedida: ${settings.authorizationStatus}');
    String? token = await _firebaseMessaging.getToken();
    print('Token: $token');
  }

  void configureFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensagem recebida: ${message.notification?.body}');
      // Handle the received message here
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App aberto por background message: ${message.notification?.body}');
      // Handle the opened app from background message here
    });
  }
}
