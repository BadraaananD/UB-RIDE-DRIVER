import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:drivers/global/global.dart';
import 'package:drivers/screens/login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      firebaseAuth
          .sendPasswordResetEmail(email: emailTextEditingController.text.trim())
          .then((value) {
        Fluttertoast.showToast(msg: "Бид танд нууц үгээ сэргээх имэйл илгээсэн тул имэйлээ шалгана уу");
      }).onError((error, stackTrace) {
        Fluttertoast.showToast(msg: "Алдаа гарлаа: \n${error.toString()}");
      });
    } else {
      Fluttertoast.showToast(msg: "Имэйл буруу байна");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final padding = isSmallScreen ? 16.0 : 32.0;
    final fontSizeTitle = isSmallScreen ? 24.0 : 32.0;
    final buttonHeight = isSmallScreen ? 48.0 : 56.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        child: Text(
                          'Нууц үг сэргээх',
                          style: TextStyle(
                            fontSize: fontSizeTitle,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      Text(
                        'Имэйлд тань сэргээх холбоос илгээнэ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 24 : 32),
                      TextFormField(
                        controller: emailTextEditingController,
                        inputFormatters: [LengthLimitingTextInputFormatter(100)],
                        decoration: InputDecoration(
                          labelText: "Имэйл",
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                          ),
                          filled: true,
                          fillColor: Colors.green[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          prefixIcon: Icon(Icons.email_outlined, color: Colors.green[800]),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "Имэйл хоосон байж болохгүй";
                          }
                          if (!EmailValidator.validate(text)) {
                            return "Хүчинтэй имэйл оруулна уу";
                          }
                          if (text.length > 99) {
                            return "Имэйл 100 тэмдэгтээс хэтрэх ёсгүй";
                          }
                          return null;
                        },
                        onChanged: (text) => setState(() {
                          emailTextEditingController.text = text;
                        }),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green[800],
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: Size(double.infinity, buttonHeight),
                            padding: EdgeInsets.symmetric(vertical: buttonHeight / 2.5),
                          ),
                          onPressed: () {
                            _submit();
                          },
                          child: Text(
                            "Сэргээх холбоос илгээх",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Та бүртгэлтэй юу?",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                            },
                            child: Text(
                              "Нэвтрэх",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: Colors.green[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}