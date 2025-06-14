import 'dart:async';
import 'package:drivers/Assistants/assistant_methods.dart';
import 'package:drivers/global/global.dart';
import 'package:drivers/pushNotification/push_notification_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; 

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> with WidgetsBindingObserver{

  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(47.9206, 106.9176),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;

  String statusText = "Одоо оффлайн байна";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false; 

  checkDriverStatus() async {
  DatabaseReference activeDriversRef = FirebaseDatabase.instance.ref().child("activeDrivers").child(currentUser!.uid);
  activeDriversRef.once().then((snap) {
    if (snap.snapshot.value != null) {
      setState(() {
        statusText = "Одоо онлайн байна";
        isDriverActive = true;
        buttonColor = Colors.transparent;
      });
    } else {
      setState(() {
        statusText = "Одоо оффлайн байна";
        isDriverActive = false;
        buttonColor = Colors.grey;
      });
    }
  });
}

  checkIfLocationPermissionAllowed() async{
    _locationPermission = await Geolocator.requestPermission();
    if(_locationPermission == LocationPermission.denied){
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateDriverPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(driverCurrentPosition!, context);
    print("Энэ бол манай хаяг = " + humanReadableAddress);

    AssistantMethods.readDriverRatings(context);
  }

  readCurrentDriverInformation() async {
    currentUser = firebaseAuth.currentUser;

    FirebaseDatabase.instance.ref()
    .child("drivers")
    .child(currentUser!.uid)
    .once()
    .then((snap)
    {
      if(snap.snapshot.value != null){
        onlineDriverData.id = (snap.snapshot.value as Map)["id"];
        onlineDriverData.name = (snap.snapshot.value as Map)["name"];
        onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
        onlineDriverData.email = (snap.snapshot.value as Map)["email"];
        onlineDriverData.address = (snap.snapshot.value as Map)["address"];
        onlineDriverData.ratings = (snap.snapshot.value as Map)["ratings"];
        onlineDriverData.car_model = (snap.snapshot.value as Map)["car_details"]["car_model"];
        onlineDriverData.car_number = (snap.snapshot.value as Map)["car_details"]["car_number"];
        onlineDriverData.car_color = (snap.snapshot.value as Map)["car_details"]["car_color"];
      }
    }); 

    AssistantMethods.readDriverEarnings(context);
  }

  @override
  void dispose() {
    super.dispose();
    if (streamSubscriptionPosition != null) {
      streamSubscriptionPosition!.cancel();
      streamSubscriptionPosition = null;
    }
    newGoogleMapController?.dispose();
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkDriverStatus();
    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);

    AssistantMethods.setupPresenceSystem();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding:EdgeInsets.only(top: 40),
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller){
            _controllerGoogleMap.complete(controller);

            newGoogleMapController = controller;

            locateDriverPosition();
          },
        ),

        // ui for online/offline driver
        statusText != "Одоо онлайн байна" 
        ? Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          color: Colors.black87,
        ) : Container(),

        // button for online/offline driver
        Positioned(
          top: statusText != "Одоо онлайн байна" ? MediaQuery.of(context).size.height * 0.45 : 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: (){
                  if(isDriverActive != true){
                    driverIsOnlineNow();
                    updateDriversLocationAtRealTime();

                    setState(() {
                      statusText = "Одоо онлайн байна";
                      isDriverActive = true;
                      buttonColor = Colors.transparent;
                    });
                    Fluttertoast.showToast(msg: "Та одоо онлайн байна");
                  }
                  else{
                    driverIsOfflineNow();
                    setState(() {
                      statusText = "Одоо оффлайн байна";
                      isDriverActive = false;
                      buttonColor = Colors.grey;
                    });
                    Fluttertoast.showToast(msg: "Та одоо оффлайн байна");
                  }
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ) 
                ),
                child: statusText != "Одоо онлайн байна" ? 
                Text(statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    ),
                  ) : Icon(
                  Icons.phonelink_ring,
                  color: Colors.white,
                  size: 26,
                ),
                )
          ],)
        )
      ],
    );
  }

  driverIsOnlineNow() async {
  Position pos = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  driverCurrentPosition = pos;

  // Initialize Geofire and set the driver's location
  Geofire.initialize("activeDrivers");
  Geofire.setLocation(currentUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

  // Set the driver's status to online
  DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid).child("newRideStatus");
  ref.set("idle");

  // Listen for changes in ride status if needed
  ref.onValue.listen((event) {
    // You can handle updates here if needed.
  });
}

  updateDriversLocationAtRealTime(){
    streamSubscriptionPosition = Geolocator.getPositionStream().listen((Position position) {
      if(isDriverActive == true){
        driverCurrentPosition = position;
        Geofire.setLocation(currentUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      }

      LatLng latLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }


  driverIsOfflineNow() async {
    await AssistantMethods.driverIsOfflineNow();
  }
}

