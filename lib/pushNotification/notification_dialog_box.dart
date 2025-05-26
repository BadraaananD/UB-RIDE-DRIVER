import 'package:drivers/Assistants/assistant_methods.dart';
import 'package:drivers/global/global.dart';
import 'package:drivers/models/user_ride_request_information.dart';
import 'package:drivers/screens/new_trip_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationDialogBox extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;

  NotificationDialogBox({this.userRideRequestDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: EdgeInsets.all(8),
        width: screenWidth * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_car, size: 60, color: Colors.blueAccent),

              SizedBox(height: 10),

              Text(
                "Шинэ аялалын хүсэлт",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),

              SizedBox(height: 14),

              Divider(height: 2, thickness: 2, color: Colors.blue),

              SizedBox(height: 20),

              // Origin
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.userRideRequestDetails!.originAddress!,
                      style: TextStyle(fontSize: 16, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Destination
              Row(
                children: [
                  Icon(Icons.flag, color: Colors.blue, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.userRideRequestDetails!.destinationAddress!,
                      style: TextStyle(fontSize: 16, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              Divider(height: 2, thickness: 2, color: Colors.blue),

              SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.cancel, size: 18),
                      label: Text("Цуцлах".toUpperCase()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        acceptRideRequest(context);
                      },
                      icon: Icon(Icons.check_circle, size: 18),
                      label: Text("Батлах".toUpperCase()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  void acceptRideRequest(BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap) {
      if (snap.snapshot.value == "idle") {
        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(firebaseAuth.currentUser!.uid)
            .child("newRideStatus")
            .set("accepted");

        AssistantMethods.pauseLiveLocationUpdates();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => NewTripScreen(
              userRideRequestDetails: widget.userRideRequestDetails,
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: "Аялалын хүсэлт байхгүй байна.");
      }
    });
  }
}
