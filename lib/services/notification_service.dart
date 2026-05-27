import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> init(String userId) async {
    NotificationSettings settings = await _fcm.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _fcm.getToken();
      if (token != null) {
        await saveTokenToDatabase(userId, token);
      }

      _fcm.onTokenRefresh.listen((newToken) {
        saveTokenToDatabase(userId, newToken);
      });
    }
  }

  Future<void> saveTokenToDatabase(String userId, String token) async {
    try {
      await _db.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    } catch (e) {
      print("Error saving FCM token: $e");
    }
  }
}
