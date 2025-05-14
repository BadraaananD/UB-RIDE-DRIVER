import 'package:drivers/global/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduledRidesTabPage extends StatefulWidget {
  const ScheduledRidesTabPage({super.key});

  @override
  State<ScheduledRidesTabPage> createState() => _ScheduledRidesTabPageState();
}

class _ScheduledRidesTabPageState extends State<ScheduledRidesTabPage> {
  List<Map<dynamic, dynamic>> acceptedRides = [];
  List<Map<dynamic, dynamic>> availableRides = [];

  @override
  void initState() {
    super.initState();
    print("userModelCurrentInfo: $userModelCurrentInfo, ID: ${userModelCurrentInfo?.id}");
    print("Firebase Auth UID: ${FirebaseAuth.instance.currentUser?.uid}");
    fetchRides();
  }

  void fetchRides() {
    Query ref = FirebaseDatabase.instance
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
          print("Ride key: $key, Data: $value");
          value['rideId'] = key;
          if (value['status'] == 'accepted' && value['driver_id'] == userModelCurrentInfo?.id) {
            accepted.add(Map<dynamic, dynamic>.from(value));
          } else if (value['status'] == 'pending') {
            available.add(Map<dynamic, dynamic>.from(value));
          }
        });

        print("Accepted rides (filtered by driver): $accepted");
        print("Available rides: $available");
      } else {
        print("No data found in All Ride Requests");
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

  Widget buildRideCard(Map<dynamic, dynamic> rideData, BuildContext context) {
    DateTime dateTime = DateTime.parse(rideData['scheduled_time']).toLocal();
    String formattedDay = DateFormat('yyyy-MM-dd').format(dateTime);
    String formattedTime = DateFormat('HH:mm').format(dateTime);

    bool isCurrentDriver = rideData['driver_id'] == userModelCurrentInfo?.id;
    print("Ride data: $rideData, isCurrentDriver: $isCurrentDriver");

    double cardWidth = MediaQuery.of(context).size.width * 0.8;
    cardWidth = cardWidth.clamp(250, 300);

    return SizedBox(
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
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Хэрэглэгч: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${rideData['userName'] ?? 'Unknown'}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Утас: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${rideData['userPhone'] ?? 'Unknown'}',
                    ),
                  ],
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
                      text: '4 / ${rideData['booked_seats']}',
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

                        DatabaseReference rideRef = FirebaseDatabase.instance
                            .ref()
                            .child("All Ride Requests")
                            .child(rideId);

                        try {
                          await rideRef.update({
                            "status": "accepted",
                            "driver_id": userModelCurrentInfo!.id!,
                          });

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
                            title: const Text("Отменить поездку"),
                            content: const Text("Вы уверены, что хотите отменить эту поездку?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Нет"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Да"),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) return;

                        DatabaseReference rideRef = FirebaseDatabase.instance
                            .ref()
                            .child("All Ride Requests")
                            .child(rideId);

                        try {
                          await rideRef.update({
                            "status": "pending",
                            "driver_id": null,
                          });

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
                ],
              ),
            ],
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
                      print("Rendering accepted ride: ${acceptedRides[index]}");
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
                      print("Rendering available ride: ${availableRides[index]}");
                      return buildRideCard(availableRides[index], context);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}