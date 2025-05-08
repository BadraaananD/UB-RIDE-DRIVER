import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:drivers/global/global.dart';
import 'package:drivers/screens/login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget{
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>{

  final emailTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

void _submit() {
  firebaseAuth.sendPasswordResetEmail(
    email: emailTextEditingController.text.trim()
  ).then((value){
    Fluttertoast.showToast(msg: "Бид танд нууц үгээ сэргээх имэйл илгээсэн тул имэйлээ шалгана уу");
  }).onError((error, StackTrace){
    Fluttertoast.showToast(msg: "Алдаа гарлаа: \n ${error.toString()}");
  });
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
                  'Нууц үг сэргээх',
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
                                  return "Имэйл 100 тэмдэгтээс хэтрэх ёсгүй";
                                }
                              },
                              onChanged: (text) => setState(() {
                                emailTextEditingController.text = text;
                              }),
                            ),

                      SizedBox(height: 20,),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor:Colors.white, 
                          backgroundColor:Colors.blue,
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
                          "Нууц үг сэргээх холбоос илгээх",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                         )
                         ),

                         SizedBox(height: 20,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Та бүртгэлтэй юу?",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),

                              SizedBox(width: 5,),

                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                                },
                                child: Text(
                                  "Нэвтрэх",
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