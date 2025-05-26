import 'package:drivers/screens/register_screen.dart';
import 'package:drivers/splashScreen/splash_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:drivers/global/global.dart';
import 'package:drivers/screens/forgot_password_screen.dart';
import 'package:drivers/screens/main_screen.dart';
import 'package:drivers/pushNotification/push_notification_system.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;

  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();

  bool _passwordVisible = false;

  final _formKey = GlobalKey<FormState>();

    void _submit() async {
  if (_formKey.currentState!.validate()) {
    try {
      final auth = await _firebaseAuth.signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      );
      final userRef = FirebaseDatabase.instance.ref().child("drivers");
      final snap = await userRef.child(auth.user!.uid).once();
      if (snap.snapshot.value != null) {
        currentUser = auth.user;
        final pushNotificationSystem = PushNotificationSystem();
        await pushNotificationSystem.generateAndGetToken();
        await Fluttertoast.showToast(msg: "Амжилттай нэвтэрлээ");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreen()));
      } else {
        await Fluttertoast.showToast(msg: "Энэ имэйлд бүртгэл байхгүй байна");
        await _firebaseAuth.signOut();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => SplashScreen()));
      }
    } catch (errorMessage) {
      Fluttertoast.showToast(msg: "Алдаа гарлаа: \n$errorMessage");
    }
  } else {
    Fluttertoast.showToast(msg: "Зарим талбар буруу байна");
  }
}

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SafeArea(
  child: Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600),
      child: Padding(
        padding: EdgeInsets.all(16.0), // Заменяет padding: EdgeInsets.all(0)
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Добавить центрирование по вертикали
          children: [
                // Image.asset('images/1.jpg'),

                // SizedBox(height: 20),

                Text(
  'Нэвтрэх',
  style: TextStyle(
    color: Colors.green[800], // Было Colors.blue
    fontSize: 24, // Уменьшить до 24 для согласованности
    fontWeight: FontWeight.bold,
  ),
),// <-- ЗАКРЫЛ `Text(...)`

                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey, // Добавлен ключ формы
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100)
                              ],
                              decoration: InputDecoration(
  hintText: "Имэйл",
  hintStyle: TextStyle(
    color: Colors.grey[600], // Было Colors.grey
  ),
  filled: true,
  fillColor: Colors.green[50], // Было Colors.grey.shade200
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12), // Было 40
    borderSide: BorderSide(
      width: 0,
      style: BorderStyle.none,
    ),
  ),
  prefixIcon: Icon(Icons.email_outlined, color: Colors.green[800]), // Было Icons.person, Colors.grey
),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if(text == null || text.isEmpty){
                                  return "Имэйл хоосон байж болохгүй";
                                }
                                if(EmailValidator.validate(text) == true){
                                  return null;
                                }
                                if(text.length < 2){
                                  return "Хүчинтэй имэйл оруулна уу";
                                }
                                if(text.length > 100){
                                  return "Имэйл 100-с их тэмдэгт байж болохгүй";
                                }
                              },
                              onChanged: (text) => setState(() {
                                emailTextEditingController.text = text;
                              }),
                            ),

                            SizedBox(height: 20,),

                            TextFormField(
                              obscureText: !_passwordVisible,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
  hintText: "Нууц үг",
  hintStyle: TextStyle(
    color: Colors.grey[600], // Было Colors.grey
  ),
  filled: true,
  fillColor: Colors.green[50], // Было Colors.grey.shade200
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12), // Было 40
    borderSide: BorderSide(
      width: 0,
      style: BorderStyle.none,
    ),
  ),
  prefixIcon: Icon(Icons.lock_outline, color: Colors.green[800]), // Было Icons.person, Colors.grey
  suffixIcon: IconButton(
    icon: Icon(
      _passwordVisible ? Icons.visibility : Icons.visibility_off,
      color: Colors.green[800], // Было Colors.grey
    ),
    onPressed: () {
      setState(() {
        _passwordVisible = !_passwordVisible;
      });
    },
  ),
),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if(text == null || text.isEmpty){
                                  return "Нууц үг хоосон байж болохгүй";
                                }
                                if(text.length < 6){
                                  return "Хүчинтэй нууц үг оруулна уу";
                                }
                                if(text.length > 49){
                                  return "Нууц үг 50-с илүү тэмдэгт байж болохгүй";
                                }
                                return null;
                              },
                              onChanged: (text) => setState(() {
                                passwordTextEditingController.text = text;
                              }),
                            ), 

                      SizedBox(height: 20,),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor:Colors.white, backgroundColor:Colors.green[800],
                          elevation: 2,
                          shape:  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: Size(double.infinity, 48),
                        ),
                        onPressed: (){
                           _submit(); 
                        },
                         child: Text(
                          "Нэвтрэх",
                          style: TextStyle(
                            fontSize: 16, // Было 20
      fontWeight: FontWeight.w600,
                          ),
                         )
                         ),

                         SizedBox(height: 20,),

                         GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (c) => ForgotPasswordScreen()));
                          },
                          child: Text(
  "Нууц үгээ мартсан уу?",
  style: TextStyle(
    color: Colors.green[800], // Было Colors.blue
    fontSize: 14, // Добавить для согласованности
  ),
),
                         ),

                          SizedBox(height: 20,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
  "Бүртгэлгүй юу?",
  style: TextStyle(
    color: Colors.grey[600], // Было Colors.grey
    fontSize: 14, // Было 15
  ),
),

                              SizedBox(width: 5,),

                              GestureDetector(  
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (c) => RegisterScreen()));
                                },
                                child: Text(
  "Бүртгүүлэх",
  style: TextStyle(
    fontSize: 14, // Было 15
    color: Colors.green[800], // Было Colors.blue
    fontWeight: FontWeight.w600, // Добавить для согласованности
  ),
),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),),)
        ),
      ),
    );
  }
}
                                