// import 'package:drivers/screens/car_info_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:drivers/infoHandler/app_info.dart';
// import 'package:drivers/screens/login_screen.dart';
// import 'package:drivers/screens/main_screen.dart';
// import 'package:drivers/screens/register_screen.dart';
// import 'package:drivers/splashScreen/splash_screen.dart';
// import 'package:drivers/themeProvider/theme_provider.dart';

// Future<void> main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => AppInfo(),
//       child: MaterialApp(
//         title: 'Flutter Demo',
//         themeMode: ThemeMode.system,
//         theme: MyThemes.lightTheme,
//         darkTheme: MyThemes.darkTheme,
//         debugShowCheckedModeBanner: false,
//         home: SplashScreen(),
//       ),
//       );
//   }
// }


import 'package:drivers/Assistants/assistant_methods.dart';
import 'package:drivers/screens/car_info_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drivers/infoHandler/app_info.dart';
import 'package:drivers/screens/login_screen.dart';
import 'package:drivers/screens/main_screen.dart';
import 'package:drivers/screens/register_screen.dart';
import 'package:drivers/splashScreen/splash_screen.dart';
import 'package:drivers/themeProvider/theme_provider.dart';

// Функция для обработки фоновых уведомлений
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background notification received: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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

  // Обработка уведомлений в активном режиме
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground notification received: ${message.notification?.title}');
    // Здесь можно добавить логику для отображения уведомления в UI
    // Например, показать SnackBar или диалоговое окно
  });

  // Обработка уведомлений в фоновом режиме
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Инициализация FCM-токена и его сохранение
  await AssistantMethods.initializeFcm();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'Flutter Demo',
        themeMode: ThemeMode.system,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}