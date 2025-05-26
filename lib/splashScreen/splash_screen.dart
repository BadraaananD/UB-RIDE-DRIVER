import 'dart:async';
import 'package:flutter/material.dart';
import 'package:drivers/Assistants/assistant_methods.dart';
import 'package:drivers/global/global.dart';
import 'package:drivers/screens/login_screen.dart';
import 'package:drivers/screens/main_screen.dart';
import 'package:drivers/pushNotification/push_notification_system.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  startTimer() {
    Timer(Duration(seconds: 3), () async {
      if (firebaseAuth.currentUser != null) {
        AssistantMethods.readCurrentOnlineUserInfo();
        final pushNotificationSystem = PushNotificationSystem();
        await pushNotificationSystem.generateAndGetToken();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    startTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final fontSize = isSmallScreen ? 36.0 : 48.0;
    final padding = isSmallScreen ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_taxi,
                      color: Colors.green[800],
                      size: isSmallScreen ? 80 : 120,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    Text(
                      'UB Ride Driver',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    Text(
                      'Таны жолоодлогын түнш',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 20,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green[800]!),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
