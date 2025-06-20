import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivers/global/global.dart';
import 'package:drivers/models/user_ride_request_information.dart';
import 'package:drivers/screens/new_trip_screen.dart';
import 'package:firebase_database/firebase_database.dart' as rtdb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class ScheduledRidesTabPage extends StatefulWidget {
  const ScheduledRidesTabPage({super.key});

  @override
  State<ScheduledRidesTabPage> createState() => _ScheduledRidesTabPageState();
}

class _ScheduledRidesTabPageState extends State<ScheduledRidesTabPage> {
  List<Map<dynamic, dynamic>> acceptedRides = [];
  List<Map<dynamic, dynamic>> availableRides = [];
  String? _currentlyOpenRideId;

  @override
  void initState() {
    super.initState();
    registerFcmToken(userModelCurrentInfo?.id);
    fetchRides();
  }

  void registerFcmToken(String? driverId) async {
    if (driverId == null) return;
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      await FirebaseFirestore.instance.collection('drivers').doc(driverId).set({
        'fcmToken': fcmToken,
        'fcmTokenTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    messaging.onTokenRefresh.listen((newToken) {
      FirebaseFirestore.instance.collection('drivers').doc(driverId).set({
        'fcmToken': newToken,
        'fcmTokenTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  void fetchRides() {
    rtdb.Query ref = rtdb.FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .orderByChild("ride_type")
        .equalTo("planned");

    ref.onValue.listen((event) {
      List<Map<dynamic, dynamic>> accepted = [];
      List<Map<dynamic, dynamic>> available = [];

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          value['rideId'] = key;

          int totalBookedSeats = 0;
          if (value['passenger_ids'] != null && value['passenger_ids'] is Map) {
            Map<dynamic, dynamic> passengers = value['passenger_ids'];
            passengers.forEach((passengerId, passengerData) {
              totalBookedSeats += (passengerData['booked_seats'] as num?)?.toInt() ?? 0;
            });
          }
          value['total_booked_seats'] = totalBookedSeats;

          if (value['status'] == 'accepted' && value['driver_id'] == userModelCurrentInfo?.id) {
            accepted.add(Map<dynamic, dynamic>.from(value));
          } else if (value['status'] == 'pending') {
            available.add(Map<dynamic, dynamic>.from(value));
          }
        });
      }

      setState(() {
        acceptedRides = accepted;
        availableRides = available;
      });
    }, onError: (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка загрузки данных: $error")),
      );
    });
  }

  Future<List<Map<String, dynamic>>> fetchPassengerNames(Map<dynamic, dynamic>? passengerIds) async {
    List<Map<String, dynamic>> passengerDetails = [];
    if (passengerIds == null || passengerIds.isEmpty) {
      return passengerDetails;
    }

    for (var passengerId in passengerIds.keys.take(4)) {
      try {
        rtdb.DatabaseReference userRef = rtdb.FirebaseDatabase.instance
            .ref()
            .child("users")
            .child(passengerId);

        rtdb.DataSnapshot snapshot = await userRef.get();
        int bookedSeats = passengerIds[passengerId]['booked_seats']?.toInt() ?? 0;

        if (snapshot.exists) {
          Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
          String name = userData['name'] ?? 'Unknown';
          passengerDetails.add({
            'name': name,
            'booked_seats': bookedSeats,
          });
        } else {
          passengerDetails.add({
            'name': 'Unknown',
            'booked_seats': bookedSeats,
          });
        // AscendingOrder();
        }
      } catch (e) {
        passengerDetails.add({
          'name': 'Unknown',
          'booked_seats': 0,
        });
      }
    }
    return passengerDetails;
  }

  void showPassengerDialog(BuildContext context, Map<dynamic, dynamic> rideData) async {
    if (_currentlyOpenRideId == rideData['rideId']) {
      setState(() {
        _currentlyOpenRideId = null;
      });
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _currentlyOpenRideId = rideData['rideId'];
    });

    List<Map<String, dynamic>> passengerDetails =
        await fetchPassengerNames(rideData['passenger_ids']);

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          elevation: 8,
          child: Container(
            width: screenWidth * 0.9,
            constraints: const BoxConstraints(maxHeight: 500),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.people, color: Colors.deepPurple),
                      SizedBox(width: 10),
                      Text(
                        "Зорчигчийн мэдээлэл",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (passengerDetails.isEmpty)
                    const Text(
                      "Пассажир олдсонгүй",
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ...passengerDetails.asMap().entries.map(
                      (entry) {
                        final seatCount = entry.value['booked_seats'] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.person, color: Colors.blueAccent),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Зорчигч ${entry.key + 1}: ${entry.value['name']}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: List.generate(
                                        seatCount,
                                        (index) => const Padding(
                                          padding: EdgeInsets.only(right: 4),
                                          child: Icon(Icons.event_seat, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );}
                      ).toList(),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentlyOpenRideId = null;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text("Хаах"),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      setState(() {
        _currentlyOpenRideId = null;
      });
    });
  }

  Widget buildRideCard(Map<dynamic, dynamic> rideData, BuildContext context) {
    DateTime dateTime = DateTime.parse(rideData['scheduled_time']).toLocal();
    String formattedDay = DateFormat('yyyy-MM-dd').format(dateTime);
    String formattedTime = DateFormat('HH:mm').format(dateTime);

    bool isCurrentDriver = rideData['driver_id'] == userModelCurrentInfo?.id;

    double cardWidth = MediaQuery.of(context).size.width * 0.8;
    cardWidth = cardWidth.clamp(250, 300);

    return GestureDetector(
      onTap: () => showPassengerDialog(context, rideData),
      child: SizedBox(
        width: cardWidth,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Эхлэх цэг: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '${rideData['originAddress']}',
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Очих цэг: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '${rideData['destinationAddress']}',
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Өдөр: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: formattedDay,
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Цаг: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: formattedTime,
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Суудлын тоо: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '4 / ${rideData['total_booked_seats'] ?? 0}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (rideData['status'] == 'pending')
                      ElevatedButton(
                        onPressed: () async {
                          final rideId = rideData['rideId'];
                          if (rideId == null || rideId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Ошибка: ID поездки не найден")),
                            );
                            return;
                          }

                          if (userModelCurrentInfo == null || userModelCurrentInfo!.id == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Ошибка: Информация о водителе отсутствует")),
                            );
                            return;
                          }

                          rtdb.DatabaseReference driverRef = rtdb.FirebaseDatabase.instance
                              .ref()
                              .child("drivers")
                              .child(firebaseAuth.currentUser!.uid)
                              .child("newRideStatus");

                          rtdb.DataSnapshot snap = await driverRef.once().then((snap) => snap.snapshot);
if (snap.value != "idle") {
  // Проверяем, есть ли активная поездка
  rtdb.DataSnapshot ridesSnap = await rtdb.FirebaseDatabase.instance
      .ref()
      .child("All Ride Requests")
      .orderByChild("driver_id")
      .equalTo(userModelCurrentInfo!.id)
      .once()
      .then((snap) => snap.snapshot);

  bool hasActiveRide = false;
  if (ridesSnap.value != null) {
    Map<dynamic, dynamic> rides = ridesSnap.value as Map<dynamic, dynamic>;
    rides.forEach((key, value) {
      if (value["status"] != "ended" && value["status"] != "pending") {
        hasActiveRide = true;
      }
    });
  }

  if (hasActiveRide) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Та өөр аялал аль хэдийн хүлээн авсан байна")),
    );
    return;
  } else {
    // Принудительно сбрасываем статус, если активной поездки нет
    await driverRef.set("idle");
  }
}

                          rtdb.DatabaseReference rideRef = rtdb.FirebaseDatabase.instance
                              .ref()
                              .child("All Ride Requests")
                              .child(rideId);

                          try {
                            await rideRef.update({
                              "status": "accepted",
                              "driver_id": userModelCurrentInfo!.id!,
                            });

                            rtdb.DatabaseReference tripsHistoryRef = rtdb.FirebaseDatabase.instance
                                .ref()
                                .child("drivers")
                                .child(firebaseAuth.currentUser!.uid)
                                .child("tripsHistory");
                            await tripsHistoryRef.child(rideId).set(true);

                            await driverRef.set("accepted");

                            UserRideRequestInformation rideInfo = UserRideRequestInformation(
                              rideRequestId: rideId,
                              userName: "Unknown",
                              originAddress: rideData['originAddress'],
                              destinationAddress: rideData['destinationAddress'],
                              originLatLng: LatLng(
                                rideData['origin']['latitude'] ?? 0.0,
                                rideData['origin']['longitude'] ?? 0.0,
                              ),
                              destinationLatLng: LatLng(
                                rideData['destination']['latitude'] ?? 0.0,
                                rideData['destination']['longitude'] ?? 0.0,
                              ),
                              rideType: "planned",
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => NewTripScreen(userRideRequestDetails: rideInfo),
                              ),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Поездка успешно принята")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Ошибка при принятии поездки: $e")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(100, 36),
                        ),
                        child: const Text("Хүлээн авах"),
                      ),
                    if (rideData['status'] == 'accepted' && isCurrentDriver)
                      ElevatedButton(
                        onPressed: () async {
                          final rideId = rideData['rideId'];
                          if (rideId == null || rideId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Ошибка: ID поездки не найден")),
                            );
                            return;
                          }

                          bool? confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Аялал цуцлах"),
                              content: const Text("Та аялал цуцлахдаа итгэлтэй байна уу?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Үгүй"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Тийм"),
                                ),
                              ],
                            ),
                          );

                          if (confirm != true) return;

                          rtdb.DatabaseReference rideRef = rtdb.FirebaseDatabase.instance
                              .ref()
                              .child("All Ride Requests")
                              .child(rideId);

                          try {
                            await rideRef.update({
                              "status": "pending",
                              "driver_id": null,
                            });

                            await rtdb.FirebaseDatabase.instance
    .ref()
    .child("drivers")
    .child(firebaseAuth.currentUser!.uid)
    .child("tripsHistory")
    .child(rideId)
    .remove();

await rtdb.FirebaseDatabase.instance
    .ref()
    .child("drivers")
    .child(firebaseAuth.currentUser!.uid)
    .child("newRideStatus")
    .set("idle");

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Поездка успешно отменена")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Ошибка при отмене поездки: $e")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(100, 36),
                        ),
                        child: const Text("Цуцлах"),
                      ),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     final rideId = rideData['rideId'];
                    //     if (rideId == null || rideId.isEmpty) {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         const SnackBar(content: Text("Ошибка: ID поездки не найден")),
                    //       );
                    //       return;
                    //     }
                    //     rtdb.DatabaseReference rideRef = rtdb.FirebaseDatabase.instance
                    //         .ref()
                    //         .child("All Ride Requests")
                    //         .child(rideId);
                    //     try {
                    //       await rideRef.update({
                    //         "status": "driverComing",
                    //       });
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         const SnackBar(content: Text("Статус обновлён: водитель выехал")),
                    //       );
                    //     } catch (e) {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         SnackBar(content: Text("Ошибка: $e")),
                    //       );
                    //     }
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.blue,
                    //     foregroundColor: Colors.white,
                    //     minimumSize: const Size(100, 36),
                    //   ),
                    //   child: const Text("Выехал"),
                    // ),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     final rideId = rideData['rideId'];
                    //     if (rideId == null || rideId.isEmpty) {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         const SnackBar(content: Text("Ошибка: ID поездки не найден")),
                    //       );
                    //       return;
                    //     }
                    //     rtdb.DatabaseReference rideRef = rtdb.FirebaseDatabase.instance
                    //         .ref()
                    //         .child("All Ride Requests")
                    //         .child(rideId);
                    //     try {
                    //       await rideRef.update({
                    //         "status": "driverArrived",
                    //       });
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         const SnackBar(content: Text("Статус обновлён: водитель прибыл")),
                    //       );
                    //     } catch (e) {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         SnackBar(content: Text("Ошибка: $e")),
                    //       );
                    //     }
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.blue,
                    //     foregroundColor: Colors.white,
                    //     minimumSize: const Size(100, 36),
                    //   ),
                    //   child: const Text("Прибыл"),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              "Хүлээн авсан захиалга",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: screenHeight * 0.35,
            child: acceptedRides.isEmpty
                ? const Center(child: Text("Хоосон"))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: acceptedRides.length,
                    itemBuilder: (context, index) {
                      return buildRideCard(acceptedRides[index], context);
                    },
                  ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              "Захиалгууд",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: screenHeight * 0.35,
            child: availableRides.isEmpty
                ? const Center(child: Text("Хоосон"))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: availableRides.length,
                    itemBuilder: (context, index) {
                      return buildRideCard(availableRides[index], context);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}