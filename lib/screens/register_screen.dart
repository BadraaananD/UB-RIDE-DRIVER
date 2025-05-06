import 'package:drivers/screens/car_info_screen.dart';
import 'package:drivers/screens/forgot_password_screen.dart';
import 'package:drivers/screens/login_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;


  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmTextEditingController = TextEditingController();

  bool _passwordVisible = false;

  // Declare a GlobalKey
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    //validate all the form fields
    if(_formKey.currentState!.validate()){
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(), 
        password: passwordTextEditingController.text.trim()
        ).then((auth) async {
          currentUser = auth.user;  

          if(currentUser != null){
            Map userMap = {
              "id":currentUser!.uid,
              "name": nameTextEditingController.text.trim(),
              "email": emailTextEditingController.text.trim(),
              "address": addressTextEditingController.text.trim(),
              "phone": phoneTextEditingController.text.trim(),
            };

            DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");
            userRef.child(currentUser!.uid).set(userMap);

          }
          await Fluttertoast.showToast(msg: "Амжилттай бүртгүүллээ");
          Navigator.push(context, MaterialPageRoute(builder: (c) => CarInfoScreen()));
        }).catchError((errorMessage) {
          Fluttertoast.showToast(msg: "Алдаа гарлаа: \n $errorMessage");
        });
    }
    else {
      Fluttertoast.showToast(msg: "Зарим талбар буруу байна");
    }
  }


  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset(darkTheme ? 'images/2.jpg' : 'images/1.jpg'),

                SizedBox(height: 20),

                Text(
                  'Бүртгүүлэх',
                  style: TextStyle(
                    color: darkTheme ? Colors.amber.shade400 : Colors.blue,
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
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Нэр",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                                border: OutlineInputBorder( // <-- ИСПРАВЛЕНО
                                  borderRadius: BorderRadius.circular(40), // <-- Исправлено
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.person, color: darkTheme ? Colors.amber.shade400 : Colors.grey,),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if(text == null || text.isEmpty){
                                  return "Нэр хоосон байж болохгүй";
                                }
                                if(text.length < 2){
                                  return "Зөв нэр оруулна уу";
                                }
                                if(text.length > 49){
                                  return "Нэр 50 тэмдэгтээс хэтрэх ёсгүй";
                                }
                              },
                              onChanged: (text) => setState(() {
                                nameTextEditingController.text = text;
                              }),
                            ),

                            SizedBox(height: 20,),

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
                                fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                                border: OutlineInputBorder( // <-- ИСПРАВЛЕНО
                                  borderRadius: BorderRadius.circular(40), // <-- Исправлено
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.person, color: darkTheme ? Colors.amber.shade400 : Colors.grey,),
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
                                  return "Зөв имэйл хаяг оруулна уу";
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

                            IntlPhoneField(
                              showCountryFlag: false,
                              dropdownIcon: Icon(
                                Icons.arrow_drop_down,
                                color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                              ),
                              decoration: InputDecoration(
                                hintText: "Утасны дугаар",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                                border: OutlineInputBorder( // <-- ИСПРАВЛЕНО
                                  borderRadius: BorderRadius.circular(40), // <-- Исправлено
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                
                              ),
                              initialCountryCode: 'MN',
                              onChanged: (text) => setState(() {
                                phoneTextEditingController.text = text.completeNumber;
                              }),
                            ),

                             TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100)
                              ],
                              decoration: InputDecoration(
                                hintText: "Хаяг",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                                border: OutlineInputBorder( // <-- ИСПРАВЛЕНО
                                  borderRadius: BorderRadius.circular(40), // <-- Исправлено
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.person, color: darkTheme ? Colors.amber.shade400 : Colors.grey,),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if(text == null || text.isEmpty){
                                  return "Хаяг хоосон байж болохгүй";
                                }
                                if(text.length < 2){
                                  return "Зөв хаяг оруулна уу";
                                }
                                if(text.length > 49){
                                  return "Хаяг 100 тэмдэгтээс хэтрэх ёсгүй";
                                }
                              },
                              onChanged: (text) => setState(() {
                                addressTextEditingController.text = text;
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
                                fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                                border: OutlineInputBorder( // <-- ИСПРАВЛЕНО
                                  borderRadius: BorderRadius.circular(40), // <-- Исправлено
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.person, color: darkTheme ? Colors.amber.shade400 : Colors.grey,),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: darkTheme ? Colors.amber.shade400 : Colors.grey,
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
                                  return "Зөв нууц үг оруулна уу";
                                }
                                if(text.length > 49){
                                  return "Нууц үг 50 тэмдэгтээс хэтрэх ёсгүй";
                                }
                                return null;
                              },
                              onChanged: (text) => setState(() {
                                passwordTextEditingController.text = text;
                              }),
                            ), 

                            SizedBox(height: 20,),

                            TextFormField(
                              obscureText: !_passwordVisible,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: "Нууц үг баталгаажуулах",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                                border: OutlineInputBorder( // <-- ИСПРАВЛЕНО
                                  borderRadius: BorderRadius.circular(40), // <-- Исправлено
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.person, color: darkTheme ? Colors.amber.shade400 : Colors.grey,),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: darkTheme ? Colors.amber.shade400 : Colors.grey,
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
                                  return "Нууц үг баталгаажуулах талбар хоосон байж болохгүй";
                                }
                                if(text != passwordTextEditingController.text){
                                  return "Нууц үг тохирохгүй байна";
                                }
                                if(text.length < 6){
                                  return "Зөв нууц үг оруулна уу";
                                }
                                if(text.length > 49){
                                  return "Нууц үг 50 тэмдэгтээс хэтрэх ёсгүй";
                                }
                                return null;
                              },
                              onChanged: (text) => setState(() {
                                confirmTextEditingController.text = text;
                              }),
                            ),  
                          ],
                        ),
                      ),

                      SizedBox(height: 20,),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: darkTheme ? Colors.black : Colors.white, backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
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
                          "Бүртгүүлэх",
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
                              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
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
                                    color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                  ),
                                ),
                              )
                            ],
                          )
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
