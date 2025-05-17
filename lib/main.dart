import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drivers/infoHandler/app_info.dart';
import 'package:drivers/splashScreen/splash_screen.dart';

void checkFcmToken() async {
  String? currentToken = await FirebaseMessaging.instance.getToken();
  print("Текущий FCM-токен: $currentToken");
  if (currentToken == null) {
    print("Ошибка: FCM-токен не сгенерирован");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  checkFcmToken();

  // Инициализация FCM
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Запрашиваем разрешение на уведомления (для iOS)
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'UB Ride Driver',
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}