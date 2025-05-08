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
    //validate all the form fields
    if(_formKey.currentState!.validate()){
      await _firebaseAuth.signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(), 
        password: passwordTextEditingController.text.trim()
        ).then((auth) async { 
          DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers"); 
          userRef.child(firebaseAuth.currentUser!.uid).once().then((value) async {
            final snap = value.snapshot;
            if(snap.value != null){
              currentUser = auth.user;
              // currentUser = FirebaseAuth.instance.currentUser;

              await Fluttertoast.showToast(msg: "Амжилттай нэвтэрлээ");
              Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreen()));

            }
            else {
              await Fluttertoast.showToast(msg: "Энэ имэйлд бүртгэл байхгүй байна");
              firebaseAuth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
            }
          });
        }).catchError((errorMessage) {
          Fluttertoast.showToast(msg: "Алдаа гарлаа: \n $errorMessage");
        });
    }
    else {
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
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset('images/1.jpg'),

                SizedBox(height: 20),

                Text(
                  'Нэвтрэх',
                  style: TextStyle(
                    color:Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ), // <-- ЗАКРЫЛ `Text(...)`

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
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor:Colors.grey.shade200,
                                border: OutlineInputBorder( // <-- ИСПРАВЛЕНО
                                  borderRadius: BorderRadius.circular(40), // <-- Исправлено
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.person, color:Colors.grey,),
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
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor:Colors.grey.shade200,
                                border: OutlineInputBorder( // <-- ИСПРАВЛЕНО
                                  borderRadius: BorderRadius.circular(40), // <-- Исправлено
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.person, color:Colors.grey,),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                    color:Colors.grey,
                                  ),
                                  onPressed: (){
                                    //update the state i.e toggle the state of passwordVisible variable
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                )
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
                          foregroundColor:Colors.white, backgroundColor:Colors.blue,
                          elevation: 0,
                          shape:  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: (){
                           _submit(); 
                        },
                         child: Text(
                          "Нэвтрэх",
                          style: TextStyle(
                            fontSize: 20,
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
                              color:Colors.blue,
                            ),
                          )
                         ),

                          SizedBox(height: 20,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Бүртгэлгүй юу?",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
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
                                    fontSize: 15,
                                    color:Colors.blue,
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
          ],
        ),
      ),
    );
  }
}
                                