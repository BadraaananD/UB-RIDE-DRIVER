import 'package:drivers/models/trips_history_model.dart';
import 'package:firebase_database/firebase_database.dart';
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

  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){
    double timeTravelledFareAmountPerMinute = (directionDetailsInfo.duration_value! / 60) * 0.1;
    double distanceTravelledFareAmountPerKilometer = (directionDetailsInfo.duration_value! / 1000) * 0.1;

    double totalFareAmount = timeTravelledFareAmountPerMinute + distanceTravelledFareAmountPerKilometer;
    double localCurrencyTotalFare = totalFareAmount * 3600;

    return ((localCurrencyTotalFare.truncate()) * 2).toDouble();
  }

  //retrieve the trips keys for online user 
  //trip key = ride request key
  static void readTripsKeysForOnlineDriver(context){
    FirebaseDatabase.instance.ref().child("All Ride Requests").orderByChild("driverId").equalTo(firebaseAuth.currentUser!.uid).once().then((snap){
      if(snap.snapshot.value != null){
        Map keysTripsId = snap.snapshot.value as Map;

        //count total number trips and share it with Provider
        int overAllTripsCounter = keysTripsId.length;
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripsCounter(overAllTripsCounter);

        //share trips keys with provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value) {
          tripsKeysList.add(key);
        });
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripsKeys(tripsKeysList);

        //get trips keys data -read trips complete information
        readTripsHistoryInformation(context);
      }
    });
  }

  static void readTripsHistoryInformation(context){
    var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;

    for(String eachKey in tripsAllKeys){
      FirebaseDatabase.instance.ref().child("All Ride Requests").child(eachKey).once().then((snap){
        var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

        if((snap.snapshot.value as Map)["status"] == "ended"){
          Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInformation(eachTripHistory); 
        }
      });
    }
  }

  //readDriverEarnings
  static void readDriverEarnings(context){
    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").once().then((snap){
      if(snap.snapshot.value != null){
        String driverEarnings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateDriverTotalEarnings(driverEarnings);
      }
    });

    readTripsKeysForOnlineDriver(context);
  }

  static void readDriverRatings(context){
    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("ratings").once().then((snap){
      if(snap.snapshot.value != null){
        String driverRatings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateDriverAverageRatings(driverRatings);
      }
    });
  }

  static Future<void> driverIsOfflineNow() async {
    try {
      String driverId = firebaseAuth.currentUser!.uid;

      // Remove driver's location from GeoFire
      Geofire.removeLocation(driverId);

      // Remove the driver's status from Firebase
      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(driverId)
          .child("newRideStatus");
      await ref.remove();

      // Remove active driver entry
      await FirebaseDatabase.instance
          .ref()
          .child("activeDrivers")
          .child(driverId)
          .remove();

      // Cancel live location updates
      if (streamSubscriptionPosition != null) {
        streamSubscriptionPosition!.cancel();
        streamSubscriptionPosition = null;
      }

      if (streamSubscriptionDriverLivePosition != null) {
      streamSubscriptionDriverLivePosition!.cancel();
      streamSubscriptionDriverLivePosition = null;
    }

      print("Driver is now offline and removed from activeDrivers");
    } catch (e) {
      print("Error while setting driver offline: $e");
    }
  }

  static void setupPresenceSystem() async {
  String driverId = firebaseAuth.currentUser!.uid;

  // Reference to driver's presence status
  DatabaseReference presenceRef = FirebaseDatabase.instance
      .ref()
      .child("drivers")
      .child(driverId)
      .child("presence");

  // Reference to activeDrivers
  DatabaseReference activeDriverRef = FirebaseDatabase.instance
      .ref()
      .child("activeDrivers")
      .child(driverId);

  // Monitor connection status
  DatabaseReference connectedRef = FirebaseDatabase.instance.ref(".info/connected");
  connectedRef.onValue.listen((event) async {
    if (event.snapshot.value == false) {
      // Device is disconnected
      await presenceRef.set("disconnected");
      return;
    }

    // Device is connected
    await presenceRef.set("connected");

    // Set up onDisconnect to remove driver from activeDrivers
    presenceRef.onDisconnect().set("disconnected");
    activeDriverRef.onDisconnect().remove();
  });
}
}