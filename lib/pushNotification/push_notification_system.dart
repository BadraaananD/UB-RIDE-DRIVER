

// // import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:drivers/global/global.dart';
// import 'package:drivers/models/user_ride_request_information.dart';
// import 'package:drivers/pushNotification/notification_dialog_box.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class PushNotificationSystem {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   Future initializeCloudMessaging(BuildContext context) async {
//     // 1.Terminated
//     // When app is closed and open directly from the push notification
//     FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage){
//       if(remoteMessage != null){
//         readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context);
//       }
//     });

//     // 2. Foreground
//     // When the app is open and recieves a push notification
//     FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage){
//       readUserRideRequestInformation(remoteMessage!.data["rideRequestId"], context);
//     }); 

//     // 3. Background
//     // When the app is in the background and opened directly from the push notification
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
//       readUserRideRequestInformation(remoteMessage!.data["rideRequestId"], context);
//     });
//   }

//   readUserRideRequestInformation(String userRideRequestId, BuildContext context) {
//     FirebaseDatabase.instance.ref().child("All Ride Requests").child(userRideRequestId).child("driverId").onValue.listen((event) {
//       if(event.snapshot.value == "waiting" || event.snapshot.value == firebaseAuth.currentUser!.uid){
//         FirebaseDatabase.instance.ref().child("All Ride Requests").child(userRideRequestId).once().then((snapData) {
//           if(snapData.snapshot.value != null) {

//             // audioPlayer.open(Audio("music/music_notification.mp3"));
//             // audioPlayer.play();

//             double originLat = double.parse((snapData.snapshot.value! as Map)["origin"]["latitude"]);
//             double originLng = double.parse((snapData.snapshot.value! as Map)["origin"]["longitute"]);
//             String originAddress = (snapData.snapshot.value! as Map)["originAddress"];

//             double destinationLat = double.parse((snapData.snapshot.value! as Map)["destination"]["latitude"]);
//             double destinationLng = double.parse((snapData.snapshot.value! as Map)["destination"]["longitute"]);
//             String destinationAddress = (snapData.snapshot.value! as Map)["destinationAddress"];

//             String userName = (snapData.snapshot.value! as Map)["userName"];
//             String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

//             String? rideRequestId = snapData.snapshot.key;

//             UserRideRequestInformation userRideRequestDetails = UserRideRequestInformation();
//             userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
//             userRideRequestDetails.originAddress = originAddress;
//             userRideRequestDetails.destinationLatLng = LatLng(destinationLat, destinationLng);
//             userRideRequestDetails.destinationAddress = destinationAddress;
//             userRideRequestDetails.userName = userName;
//             userRideRequestDetails.userPhone = userPhone;

//             userRideRequestDetails.rideRequestId = rideRequestId;

//             showDialog(
//               context: context, 
//               builder: (BuildContext context) => NotificationDialogBox(
//                 userRideRequestDetails: userRideRequestDetails,
//               )
//             );
//           }
//           else{
//             Fluttertoast.showToast(msg: "This Ride Request Id do not exists.");
//           }
//         });
//       }
//       else {
//         Fluttertoast.showToast(msg: "This Ride Request has been cancelled.");
//         Navigator.pop(context);
//       }
//     });
//   }

//   // Future generateAndGetToken() async {
//   //   String? registrationToken = await messaging.getToken();
//   //   print("FCM registration Token: ${registrationToken}");

//   //   FirebaseDatabase.instance.ref()
//   //     .child("drivers")
//   //     .child(firebaseAuth.currentUser!.uid)
//   //     .child("token")
//   //     .set(registrationToken);

//   //   messaging.subscribeToTopic("allDrivers");
//   //   messaging.subscribeToTopic("allUsers");
//   // }
//   Future<void> generateAndGetToken() async {
//   try {
//     String? registrationToken = await messaging.getToken();
//     if (registrationToken == null) {
//       print('Failed to generate FCM token');
//       return;
//     }
//     print("FCM registration Token: $registrationToken");

//     // Сохраняем токен в fcmToken
//     await FirebaseDatabase.instance
//         .ref()
//         .child("drivers")
//         .child(firebaseAuth.currentUser!.uid)
//         .update({'fcmToken': registrationToken});

//     // Подписка на топики (удалите, если не используются)
//     await messaging.subscribeToTopic("allDrivers");
//     await messaging.subscribeToTopic("allUsers");

//     print('FCM token saved successfully');
//   } catch (e) {
//     print('Error generating or saving FCM token: $e');
//   }
// }
// }

import 'package:drivers/global/global.dart';
import 'package:drivers/models/user_ride_request_information.dart';
import 'package:drivers/pushNotification/notification_dialog_box.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationSystem {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initializeCloudMessaging(BuildContext context) async {
    try {
      // Запрашиваем разрешение на уведомления (важно для iOS)
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print("Notification permission status: ${settings.authorizationStatus}");

      // Настраиваем foreground-уведомления
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 1. Terminated: приложение закрыто, открыто через уведомление
      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage) {
        if (remoteMessage != null && remoteMessage.data["rideRequestId"] != null) {
          print("Terminated notification received: ${remoteMessage.notification?.title}");
          print("Notification data: ${remoteMessage.data}");
          readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context);
        } else {
          print("No initial message or missing rideRequestId");
        }
      });

      // 2. Foreground: приложение открыто
      FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
        if (remoteMessage != null && remoteMessage.data["rideRequestId"] != null) {
          print("Foreground notification received: ${remoteMessage.notification?.title}");
          print("Notification data: ${remoteMessage.data}");
          readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context);
        } else {
          print("Invalid foreground notification: missing rideRequestId or null message");
        }
      });

      // 3. Background: приложение в фоне, открыто через уведомление
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
        if (remoteMessage != null && remoteMessage.data["rideRequestId"] != null) {
          print("Background notification opened: ${remoteMessage.notification?.title}");
          print("Notification data: ${remoteMessage.data}");
          readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context);
        } else {
          print("Invalid background notification: missing rideRequestId or null message");
        }
      });
    } catch (e) {
      print("Error in initializeCloudMessaging: $e");
      Fluttertoast.showToast(msg: "Error initializing notifications: $e");
    }
  }

  void readUserRideRequestInformation(String userRideRequestId, BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(userRideRequestId)
        .once()
        .then((DatabaseEvent event) {
      final snapData = event.snapshot;
      if (snapData.value == null) {
        print("Ride request not found: $userRideRequestId");
        Fluttertoast.showToast(msg: "This Ride Request does not exist.");
        return;
      }

      final rideData = snapData.value as Map<dynamic, dynamic>?;
      if (rideData == null) {
        print("Ride request data is null for ID: $userRideRequestId");
        Fluttertoast.showToast(msg: "Invalid ride request data.");
        return;
      }

      // Проверяем статус driverId
      final driverId = rideData["driverId"]?.toString();
      if (driverId != "waiting" && driverId != firebaseAuth.currentUser!.uid) {
        print("Ride request cancelled or assigned to another driver: $userRideRequestId");
        Fluttertoast.showToast(msg: "This Ride Request has been cancelled or assigned.");
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        return;
      }

      try {
        // Безопасно извлекаем данные
        final origin = rideData["origin"] as Map<dynamic, dynamic>?;
        final destination = rideData["destination"] as Map<dynamic, dynamic>?;

        // Проверяем наличие координат и адресов
        if (origin == null || destination == null) {
          print("Missing origin or destination data for ride: $userRideRequestId");
          Fluttertoast.showToast(msg: "Invalid ride request: missing location data.");
          return;
        }

        // Парсим координаты с обработкой ошибок
        double originLat = 0.0;
        double originLng = 0.0;
        double destinationLat = 0.0;
        double destinationLng = 0.0;

        try {
          originLat = double.parse(origin["latitude"]?.toString() ?? "0.0");
          originLng = double.parse(origin["longitude"]?.toString() ?? "0.0"); // Исправлено: longitute -> longitude
          destinationLat = double.parse(destination["latitude"]?.toString() ?? "0.0");
          destinationLng = double.parse(destination["longitude"]?.toString() ?? "0.0");
        } catch (e) {
          print("Error parsing coordinates for ride $userRideRequestId: $e");
          Fluttertoast.showToast(msg: "Invalid location data in ride request.");
          return;
        }

        // Извлекаем адреса и пользовательские данные
        String originAddress = rideData["originAddress"]?.toString() ?? "Unknown";
        String destinationAddress = rideData["destinationAddress"]?.toString() ?? "Unknown";
        String userName = rideData["userName"]?.toString() ?? "Unknown";
        String userPhone = rideData["userPhone"]?.toString() ?? "Unknown";

        print("Ride request data parsed: "
            "originLat=$originLat, originLng=$originLng, "
            "destinationLat=$destinationLat, destinationLng=$destinationLng, "
            "originAddress=$originAddress, destinationAddress=$destinationAddress, "
            "userName=$userName, userPhone=$userPhone");

        // Создаём объект UserRideRequestInformation
        UserRideRequestInformation userRideRequestDetails = UserRideRequestInformation();
        userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
        userRideRequestDetails.originAddress = originAddress;
        userRideRequestDetails.destinationLatLng = LatLng(destinationLat, destinationLng);
        userRideRequestDetails.destinationAddress = destinationAddress;
        userRideRequestDetails.userName = userName;
        userRideRequestDetails.userPhone = userPhone;
        userRideRequestDetails.rideRequestId = userRideRequestId;

        // Показываем диалог
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => NotificationDialogBox(
            userRideRequestDetails: userRideRequestDetails,
          ),
        ).then((_) {
          print("Notification dialog closed for ride: $userRideRequestId");
        });
      } catch (e) {
        print("Error processing ride request $userRideRequestId: $e");
        Fluttertoast.showToast(msg: "Error processing ride request: $e");
      }
    }).catchError((e) {
      print("Error reading ride request $userRideRequestId: $e");
      Fluttertoast.showToast(msg: "Error reading ride request: $e");
    });
  }

  Future<void> generateAndGetToken() async {
    try {
      String? registrationToken = await messaging.getToken();
      if (registrationToken == null) {
        print('Failed to generate FCM token');
        return;
      }
      print("FCM registration Token: $registrationToken");

      // Сохраняем токен в fcmToken
      await FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(firebaseAuth.currentUser!.uid)
          .child("fcmToken")
          .set(registrationToken);

      // Подписка на топики (можно удалить, если не используются)
      await messaging.subscribeToTopic("allDrivers");
      await messaging.subscribeToTopic("allUsers");

      print('FCM token saved successfully');
    } catch (e) {
      print('Error generating or saving FCM token: $e');
      Fluttertoast.showToast(msg: "Error saving FCM token: $e");
    }
  }
}