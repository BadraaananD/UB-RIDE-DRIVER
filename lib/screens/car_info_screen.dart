import 'package:drivers/global/global.dart';
import 'package:drivers/screens/register_screen.dart';
import 'package:drivers/splashScreen/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({super.key});

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {

  final carModelTextEditingController = TextEditingController();
  final carNumberTextEditingController = TextEditingController();
  final carColorTextEditingController = TextEditingController();


  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Ensure currentUser is fetched from FirebaseAuth
    currentUser = FirebaseAuth.instance.currentUser;
  }

  _submit() {
  if (_formKey.currentState!.validate()) {
    if (currentUser == null) {
      Fluttertoast.showToast(msg: "Хэрэглэгч нэвтрээгүй байна. Давтан нэвтэрнэ үү.");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => RegisterScreen()));
      return;
    }

    Map driverCarInfoMap = {
      "car_model": carModelTextEditingController.text.trim(),
      "car_number": carNumberTextEditingController.text.trim(),
      "car_color": carColorTextEditingController.text.trim(),
    };

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");
    userRef.child(currentUser!.uid).child("car_details").set(driverCarInfoMap);

    Fluttertoast.showToast(msg: "Машины мэдээлэл хадгалагдлаа.");
    Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
  }
}

  @override
  Widget build(BuildContext context) {
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

                SizedBox(height: 20,),

                Text(
                  "Машины мэдээлэл",
                  style: TextStyle(
                    color:Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

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
                              controller: carModelTextEditingController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: "Машины загвар",
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.directions_car, color:Colors.grey),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "Машины загвар хоосон байж болохгүй";
                                }
                                if (text.length < 2) {
                                  return "Зөв машины загвар оруулна уу";
                                }
                                if (text.length > 49) {
                                  return "Машины загвар 50 тэмдэгтээс хэтрэх ёсгүй";
                                }
                                return null;
                              },
                              onChanged: (text) => setState(() {
                                carModelTextEditingController.text = text;
                              }),
                            ),

                            SizedBox(height: 20,),

                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Машины дугаар",
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
                                  return "Машины дугаар хоосон байж болохгүй";
                                }
                                if(text.length != 7){
                                  return "Зөв машины дугаар оруулна уу";
                                }
                              },
                              onChanged: (text) => setState(() {
                                carNumberTextEditingController.text = text;
                              }),
                            ),

                            SizedBox(height: 20,),

                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Машины өнгө",
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
                                  return "Машины өнгө хоосон байж болохгүй";
                                }
                                if(text.length < 2){
                                  return "Зөв машины өнгө оруулна уу";
                                }
                                if(text.length > 49){
                                  return "Машины өнгө 50 тэмдэгтээс хэтрэх ёсгүй";
                                }
                              },
                              onChanged: (text) => setState(() {
                                carColorTextEditingController.text = text;
                              }),
                            ),
                          ],
                        ),
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
                          "Баталгаажуулах",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                         )
                         ),

                         SizedBox(height: 20,),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}