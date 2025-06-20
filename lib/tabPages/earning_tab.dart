import 'package:drivers/infoHandler/app_info.dart';
import 'package:drivers/screens/trips_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EarningsTabPage extends StatefulWidget {
  const EarningsTabPage({super.key});

  @override
  State<EarningsTabPage> createState() => _EarningsTabPageState();
}

class _EarningsTabPageState extends State<EarningsTabPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color:Colors.lightBlueAccent,
      child: Column(
        children: [
          //earnings
          Container(
            color:Colors.lightBlue,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  Text(
                    "Таны орлого",
                    style: TextStyle(
                      color:Colors.white,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10,),

                  Text(
                    " " + Provider.of<AppInfo>(context, listen: false).driverTotalEarnings,
                    style: TextStyle(
                      color:Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.bold, 
                    ),
                  )
                ],
              ),
              ),
          ),

          //total number of trips
          ElevatedButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (c) => TripsHistoryScreen()));
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white54,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Image.asset("images/car.png",
                    scale: 2,
                  ),

                  SizedBox(width: 10,),

                  Text(
                    "Дууссан аяллууд",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),

                  Expanded(
                    child: Container(
                      child: Text(
                        Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList.length.toString(),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    )
                  )
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}