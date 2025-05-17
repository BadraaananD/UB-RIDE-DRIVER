import 'dart:async';

import 'package:flutter/material.dart';
import 'package:drivers/Assistants/assistant_methods.dart';
import 'package:drivers/global/global.dart';
import 'package:drivers/screens/login_screen.dart';
import 'package:drivers/screens/main_screen.dart';
import 'package:drivers/pushNotification/push_notification_system.dart';


class SplashScreen extends StatefulWidget{
  const SplashScreen({Key? key}) : super(key: key);
  
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{

startTimer(){
  Timer(Duration(seconds: 3), () async {
    if(firebaseAuth.currentUser != null){
      AssistantMethods.readCurrentOnlineUserInfo();
      final pushNotificationSystem = PushNotificationSystem();
      await pushNotificationSystem.generateAndGetToken();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreen())); 
    }
    else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => LoginScreen()));
    }
  });
}

@override
void initState(){
  super.initState();

  startTimer();
}

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Text(
          'UB Ride \n Driver',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold
          )
        ),
      )
    );
  }
}
  
