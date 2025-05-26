// import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/services.dart';
// import 'package:googleapis_auth/auth_io.dart';
// import 'package:http/http.dart' as http;

// class FcmUtils {
//   static Future<String> getAccessToken() async {
//     try {
//       final String serviceAccountJson =
//           await rootBundle.loadString('assets/ubride-2cbac-0ba5ddcc7562.json');
//       final accountCredentials =
//           ServiceAccountCredentials.fromJson(serviceAccountJson);
//       final scopes = ['https://www.googleapis.com/auth/cloud-platform'];

//       final client = await clientViaServiceAccount(accountCredentials, scopes);
//       final accessToken = client.credentials.accessToken.data;
//       client.close();

//       return accessToken;
//     } catch (e) {
//       print('Error getting access token: $e');
//       rethrow;
//     }
//   }

//   static Future<void> sendNotificationToUser(
//       String fcmToken, String rideId, String rideType) async {
//     try {
//       final String accessToken = await getAccessToken();
//       const String projectId = 'ubride-2cbac';
//       final String fcmEndpoint =
//           'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

//       final Map<String, dynamic> message = {
//         'message': {
//           'token': fcmToken,
//           'notification': {
//             'title': 'Водитель выехал',
//             'body': 'Водитель направляется к начальной точке.',
//           },
//           'data': {
//             'rideId': rideId,
//             'rideType': rideType,
//           },
//         },
//       };

//       final response = await http.post(
//         Uri.parse(fcmEndpoint),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $accessToken',
//         },
//         body: jsonEncode(message),
//       );

//       if (response.statusCode == 200) {
//         print('Уведомление успешно отправлено пользователю');
//       } else {
//         print('Ошибка отправки уведомления: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       print('Ошибка отправки уведомления: $e');
//     }
//   }

//   static Future<void> storeFcmToken(String userId) async {
//     try {
//       String? fcmToken = await FirebaseMessaging.instance.getToken();
//       if (fcmToken != null) {
//         await FirebaseDatabase.instance
//             .ref()
//             .child("drivers")
//             .child(userId)
//             .update({
//           'fcmToken': fcmToken,
//           'fcmTokenTimestamp': DateTime.now().toIso8601String(),
//         });
//         print('FCM-токен сохранён для водителя: $userId');
//       }
//     } catch (e) {
//       print('Ошибка сохранения FCM-токена: $e');
//     }
//   }

//   static void handleForegroundNotifications() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Получено уведомление в foreground: ${message.notification?.title}');
//     });
//   }

//   static void handleTokenRefresh() {
//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//       final userId = FirebaseAuth.instance.currentUser?.uid;
//       if (userId != null) {
//         FirebaseDatabase.instance
//             .ref()
//             .child("drivers")
//             .child(userId)
//             .update({
//           'fcmToken': newToken,
//           'fcmTokenTimestamp': DateTime.now().toIso8601String(),
//         });
//         print('FCM-токен обновлён для водителя: $userId');
//       }
//     });
//   }
// }