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
  final Set<String> processedRideRequestIds = {};

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
        if (remoteMessage != null && remoteMessage.data["rideRequestId"] != null && !processedRideRequestIds.contains(remoteMessage.data["rideRequestId"])) {
          print("Terminated notification received: ${remoteMessage.notification?.title}");
          print("Notification data: ${remoteMessage.data}");
          processedRideRequestIds.add(remoteMessage.data["rideRequestId"]);
          readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context);
        } else {
          print("No initial message or missing rideRequestId or already processed");
        }
      });

      // 2. Foreground: приложение открыто
      FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
        if (remoteMessage != null && remoteMessage.data["rideRequestId"] != null && !processedRideRequestIds.contains(remoteMessage.data["rideRequestId"])) {
          print("Foreground notification received: ${remoteMessage.notification?.title}");
          print("Notification data: ${remoteMessage.data}");
          processedRideRequestIds.add(remoteMessage.data["rideRequestId"]);
          readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context);
        } else {
          print("Invalid foreground notification: missing rideRequestId or already processed");
        }
      });

      // 3. Background: приложение в фоне, открыто через уведомление
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
        if (remoteMessage != null && remoteMessage.data["rideRequestId"] != null && !processedRideRequestIds.contains(remoteMessage.data["rideRequestId"])) {
          print("Background notification opened: ${remoteMessage.notification?.title}");
          print("Notification data: ${remoteMessage.data}");
          processedRideRequestIds.add(remoteMessage.data["rideRequestId"]);
          readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context);
        } else {
          print("Invalid background notification: missing rideRequestId or already processed");
        }
      });
    } catch (e) {
      print("Error in initializeCloudMessaging: $e");
      Fluttertoast.showToast(msg: "Error initializing notifications: $e");
    }
  }

  void readUserRideRequestInformation(String userRideRequestId, BuildContext context) {
    print("Processing ride request with ID: $userRideRequestId");
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(userRideRequestId)
        .once()
        .then((DatabaseEvent event) {
      final snapData = event.snapshot;
      if (!snapData.exists) {
        print("Ride request $userRideRequestId not found or already processed");
        return;
      }

      final rideData = snapData.value as Map<dynamic, dynamic>?;
      if (rideData == null) {
        print("Ride request data is null for ID: $userRideRequestId");
        if (context.mounted) {
          Fluttertoast.showToast(msg: "Invalid ride request data.");
        } else {
          print("Context not mounted, skipping toast for invalid data");
        }
        return;
      }

      final driverId = rideData["driverId"]?.toString();
      print("DriverId: $driverId, Current user: ${firebaseAuth.currentUser!.uid}, Ride ID: $userRideRequestId");
      if (driverId != "waiting" && driverId != firebaseAuth.currentUser!.uid) {
        print("Ride request cancelled or assigned to another driver: $userRideRequestId");
        if (context.mounted) {
          Fluttertoast.showToast(msg: "This Ride Request has been cancelled or assigned.");
        } else {
          print("Context not mounted, skipping toast for cancelled/assigned request");
        }
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        return;
      }

      try {
        final origin = rideData["origin"] as Map<dynamic, dynamic>?;
        final destination = rideData["destination"] as Map<dynamic, dynamic>?;

        if (origin == null || destination == null) {
          print("Missing origin or destination data for ride: $userRideRequestId");
          if (context.mounted) {
            Fluttertoast.showToast(msg: "Invalid ride request: missing location data.");
          } else {
            print("Context not mounted, skipping toast for missing location data");
          }
          return;
        }

        double originLat = 0.0;
        double originLng = 0.0;
        double destinationLat = 0.0;
        double destinationLng = 0.0;

        try {
          originLat = double.parse(origin["latitude"]?.toString() ?? "0.0");
          originLng = double.parse(origin["longitude"]?.toString() ?? "0.0");
          destinationLat = double.parse(destination["latitude"]?.toString() ?? "0.0");
          destinationLng = double.parse(destination["longitude"]?.toString() ?? "0.0");
        } catch (e) {
          print("Error parsing coordinates for ride $userRideRequestId: $e");
          if (context.mounted) {
            Fluttertoast.showToast(msg: "Invalid location data in ride request.");
          } else {
            print("Context not mounted, skipping toast for invalid location data");
          }
          return;
        }

        String originAddress = rideData["originAddress"]?.toString() ?? "Unknown";
        String destinationAddress = rideData["destinationAddress"]?.toString() ?? "Unknown";
        String userName = rideData["userName"]?.toString() ?? "Unknown";
        String userPhone = rideData["userPhone"]?.toString() ?? "Unknown";

        print("Ride request data parsed: "
            "originLat=$originLat, originLng=$originLng, "
            "destinationLat=$destinationLat, destinationLng=$destinationLng, "
            "originAddress=$originAddress, destinationAddress=$destinationAddress, "
            "userName=$userName, userPhone=$userPhone");

        UserRideRequestInformation userRideRequestDetails = UserRideRequestInformation();
        userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
        userRideRequestDetails.originAddress = originAddress;
        userRideRequestDetails.destinationLatLng = LatLng(destinationLat, destinationLng);
        userRideRequestDetails.destinationAddress = destinationAddress;
        userRideRequestDetails.userName = userName;
        userRideRequestDetails.userPhone = userPhone;
        userRideRequestDetails.rideRequestId = userRideRequestId;

        // Проверяем, не открыт ли уже диалог
        if (context.mounted && ModalRoute.of(context)?.isCurrent == true) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => NotificationDialogBox(
              userRideRequestDetails: userRideRequestDetails,
            ),
          ).then((_) {
            print("Notification dialog closed for ride: $userRideRequestId");
            processedRideRequestIds.remove(userRideRequestId); // Очищаем после закрытия
          });
        } else {
          print("Context not mounted or not current route, skipping dialog for ride: $userRideRequestId");
        }
      } catch (e) {
        print("Error processing ride request $userRideRequestId: $e");
        if (context.mounted) {
          Fluttertoast.showToast(msg: "Error processing ride request: $e");
        } else {
          print("Context not mounted, skipping toast for error: $e");
        }
      }
    }).catchError((e) {
      print("Error reading ride request $userRideRequestId: $e");
      if (context.mounted) {
        Fluttertoast.showToast(msg: "Error reading ride request: $e");
      } else {
        print("Context not mounted, skipping toast for error: $e");
      }
    });
  }

  Future<void> generateAndGetToken() async {
    try {
      // Удаляем старый токен, чтобы получить новый для текущей сессии
      await messaging.deleteToken();
      String? registrationToken = await messaging.getToken();
      if (registrationToken == null) {
        print('Failed to generate FCM token');
        Fluttertoast.showToast(msg: "Failed to generate FCM token");
        return;
      }
      print("FCM registration Token: $registrationToken");

      // Проверяем текущий токен в базе данных
      final driverRef = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(firebaseAuth.currentUser!.uid);
      final tokenSnapshot = await driverRef.child("fcmToken").get();
      if (tokenSnapshot.exists && tokenSnapshot.value == registrationToken) {
        print("FCM token unchanged, no update needed");
        return;
      }

      // Сохраняем новый токен
      await driverRef.child("fcmToken").set(registrationToken);
      print('FCM token saved successfully');

      // Подписка на топик только для водителей
      await messaging.subscribeToTopic("allDrivers");
      // Отписываемся от allUsers, если не нужно
      await messaging.unsubscribeFromTopic("allUsers");
    } catch (e) {
      print('Error generating or saving FCM token: $e');
      Fluttertoast.showToast(msg: "Error saving FCM token: $e");
    }
  }

  Future<void> clearFcmTokenOnLogout() async {
    try {
      final driverRef = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(firebaseAuth.currentUser!.uid);

      // Удаляем токен из базы данных
      await driverRef.child("fcmToken").remove();
      print("FCM token removed from database");

      // Отписываемся от топиков
      await messaging.unsubscribeFromTopic("allDrivers");
      await messaging.unsubscribeFromTopic("allUsers");
      print("Unsubscribed from FCM topics");

      // Удаляем локальный токенЖ
      await messaging.deleteToken();
      print("Local FCM token deleted");
    } catch (e) {
      print("Error clearing FCM token on logout: $e");
      Fluttertoast.showToast(msg: "Error clearing FCM token: $e");
    }
  }
}