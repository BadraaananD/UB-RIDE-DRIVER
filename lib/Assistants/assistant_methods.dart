// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_geofire/flutter_geofire.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:drivers/Assistants/request_assistant.dart';
// import 'package:drivers/global/global.dart';
// import 'package:drivers/global/map_key.dart';
// import 'package:drivers/infoHandler/app_info.dart';
// import 'package:drivers/models/direction_details_info.dart';
// import 'package:drivers/models/directions.dart';
// import 'package:drivers/models/user_model.dart';

// class AssistantMethods {

//   static void readCurrentOnlineUserInfo() async{
//     currentUser = firebaseAuth.currentUser;
//     DatabaseReference userRef = FirebaseDatabase.instance
//       .ref()
//       .child("drivers")
//       .child(currentUser!.uid);

//     userRef.once().then((snap){
//       if(snap.snapshot.value != null){
//         userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
//       }
//     });

// //     currentUser = firebaseAuth.currentUser;

// // if (currentUser != null) {
// //   DatabaseReference userRef = FirebaseDatabase.instance
// //       .ref()
// //       .child("drivers")
// //       .child(currentUser!.uid);

// //   userRef.once().then((snap) {
// //     if (snap.snapshot.value != null) {
// //       userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
// //     }
// //   });
// // } else {
// //   print("Error: currentUser is null in readCurrentOnlineUserInfo()");
// // }
//   }

//   static Future<String> searchAddressForGeographicCoOrdinates(Position position, context) async{

//     String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
//     String humanReadableAddress = "";
    
//     var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

//     if(requestResponse != "Error Occured. Failed. No Response."){
//       humanReadableAddress = requestResponse["results"][0]["formatted_address"];

//       Directions userPickUpAddress = Directions();
//       userPickUpAddress.locationLatitude = position.latitude;
//       userPickUpAddress.locationLongitude = position.longitude;
//       userPickUpAddress.locationName = humanReadableAddress;

//       Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress); 
//     }

//     return humanReadableAddress;
//   }

//   static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async {

//     String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
//     var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

//     // if(responseDirectionApi == "Error Occured. Failed. No Response."){
//     //   return "";
//     // }

//     DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
//     directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

//     directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
//     directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

//     directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
//     directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

//     return directionDetailsInfo;
//   }

//   static pauseLiveLocationUpdates() {
//     streamSubscriptionPosition!.pause();
//     Geofire.removeLocation(firebaseAuth.currentUser!.uid);  
//   }

  
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:drivers/Assistants/request_assistant.dart';
import 'package:drivers/global/global.dart';
import 'package:drivers/global/map_key.dart';
import 'package:drivers/infoHandler/app_info.dart';
import 'package:drivers/models/direction_details_info.dart';
import 'package:drivers/models/directions.dart';
import 'package:drivers/models/user_model.dart';

class AssistantMethods {
  static void readCurrentOnlineUserInfo() async {
    try {
      currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        print('Error: No authenticated user found');
        return;
      }

      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(currentUser!.uid);

      final snap = await userRef.once();
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
        print('Driver info loaded successfully');
      } else {
        print('Error: Driver data not found in database');
      }
    } catch (e) {
      print('Error reading driver info: $e');
    }
  }

  static Future<String> searchAddressForGeographicCoOrdinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occurred. Failed. No Response.") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(
      LatLng originPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    var responseDirectionApi =
        await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static pauseLiveLocationUpdates() {
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(firebaseAuth.currentUser!.uid);
  }

  // Новый метод для получения FCM-токена
  static Future<String?> getFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print('Driver FCM Token: $fcmToken');
      return fcmToken;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Новый метод для сохранения FCM-токена в базе данных
  static Future<void> saveFcmTokenToDatabase(String token) async {
    try {
      if (firebaseAuth.currentUser == null) {
        print('Error: No authenticated user found');
        return;
      }
      String driverId = firebaseAuth.currentUser!.uid;
      await FirebaseDatabase.instance
          .ref()
          .child('drivers')
          .child(driverId)
          .update({'fcmToken': token});
      print('FCM token saved to database');
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Новый метод для инициализации FCM и отслеживания обновлений токена
  static Future<void> initializeFcm() async {
    try {
      // Получаем и сохраняем начальный FCM-токен
      String? fcmToken = await getFcmToken();
      if (fcmToken != null) {
        await saveFcmTokenToDatabase(fcmToken);
      }

      // Отслеживаем обновления токена
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        print('New FCM Token: $newToken');
        await saveFcmTokenToDatabase(newToken);
      });
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){
    double timeTravelledFareAmountPerMinute = (directionDetailsInfo.duration_value! / 60) * 0.1;
    double distanceTravelledFareAmountPerKilometer = (directionDetailsInfo.duration_value! / 1000) * 0.1;

    double totalFareAmount = timeTravelledFareAmountPerMinute + distanceTravelledFareAmountPerKilometer;
    double localCurrencyTotalFare = totalFareAmount * 3600;

    if(driverVehicleType == "Bike"){
      double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 0.8);
      return resultFareAmount;
    }
    else if(driverVehicleType == "CNG"){
      double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 1.5);
      return resultFareAmount;
    }
    else if(driverVehicleType == "Car"){
      double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 2);
      return resultFareAmount;
    }
    else {
      return localCurrencyTotalFare.truncate().toDouble();
    }
  }
}