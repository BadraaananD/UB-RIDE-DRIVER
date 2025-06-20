import 'dart:async';
import 'package:drivers/models/driver_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drivers/models/user_model.dart';
import 'package:geolocator/geolocator.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

UserModel? userModelCurrentInfo;

Position? driverCurrentPosition;

DriverData onlineDriverData = DriverData();

String titleStarsRating = "";