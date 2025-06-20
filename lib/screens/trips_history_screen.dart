import 'package:drivers/infoHandler/app_info.dart';
import 'package:drivers/widgets/history_design_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TripsHistoryScreen extends StatefulWidget {
  const TripsHistoryScreen({super.key});

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.grey[100],
      appBar: AppBar(
        backgroundColor:Colors.white,
        title: Text(
          "Аяллын түүх",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color:Colors.black,),
          onPressed: ()
          {
            Navigator.pop(context);
          }, 
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView.separated(
          itemBuilder: (context, i)
          {
            return Card(
              color:Colors.grey[100],
              shadowColor: Colors.transparent,
              child: HistoryDesignUIWidget(
                tripsHistoryModel: Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList[i],
              ),
            );
          },
          separatorBuilder: (context, i) => SizedBox(height: 30,),
          itemCount: Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList.length,
        ),
      ),
    );
  }
}