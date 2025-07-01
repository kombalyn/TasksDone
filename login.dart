import 'package:apptvshow/aSZF.dart';
import 'package:apptvshow/color/colorapp.dart';
import 'package:apptvshow/forgottenPassword.dart';
import 'package:apptvshow/modelview/viewHome.dart';
import 'package:apptvshow/subscriptionOptions.dart';
import 'package:apptvshow/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './auth.dart';
import './register.dart';
import './functions/errordialog.dart';
import 'Navbar/navbar.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  ViewHome viewHome = Get.put(ViewHome());

  String? errorMessage = '';

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  String _createUserId(String email) {
    return sha256.convert(utf8.encode(email.trim().toLowerCase())).toString();
  }
  Future<void> signInWithEmailAndPassword() async {
    //Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionOptions()));

    try{
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      ).then((_) => {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const  MyApp1())),
      });
      final userId = _createUserId(_emailController.text);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NavBar(userId: userId),
        ),
      );
    } on FirebaseAuthException {
      setState(() {
        if(_controllerEmail.text == ''){
          errorMessage = 'Kérlek add meg az e-mail címed!';
        }
        else if(_controllerPassword.text == ''){
          errorMessage = 'Kérlek add meg a jelszavad!';
        } else {
          errorMessage = 'Kérlek adj meg érvényes bejelentkezési adatokat!';
        }
        dialogBuilder(context, errorMessage);
      });
    }



  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: ColorApp.bgHome, // same colour as the app background
      statusBarIconBrightness: Brightness.light, // Adjusts the icon color for contrast
      statusBarBrightness: Brightness.dark, // iOS status bar brightness
    ));
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorApp.bgHome,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('images/LUMEEI_logó.jpg',
                    width: 150,
                    height: 150,
                  ),
                  Text('LUMEEI',
                    style: GoogleFonts.montserrat(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        )
                    ),
                  ),
                  Text('gyere tanulj & játssz velünk',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      )
                  ),
                  const SizedBox(height: 40,),
                  TextFormField(
                    controller: _controllerEmail,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      hintText: 'Írd be az e-mail címed',
                      hintStyle: const TextStyle(
                        color: ColorApp.bgHome,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                      validator: (String? value){
                        if(value == null || value.isEmpty) {
                          return 'Kérlek add meg a neved';
                        }
                        return null;
                      },
                  ),
                  const SizedBox(height: 15,),
                  TextFormField(
                    controller: _controllerPassword,
                    decoration: InputDecoration(
                      border:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      hintText: "Kérlek add meg a jelszavad",
                      hintStyle: const TextStyle(
                        color: ColorApp.bgHome,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: signInWithEmailAndPassword,
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(Colors.black),
                      fixedSize: WidgetStatePropertyAll(Size(200, 20)),
                    ),
                    child: Text('Bejelentkezés',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )
                    ),
                  ),
                  const SizedBox(height: 10), // Space between buttons
                  TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgottenPassword()),
                      );
                    },
                    child: Text('Elfelejtetted a jelszavad?',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        )
                    ),
                  ),
                  TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Register()),
                      );
                    },
                    child: Text('Fiók létrehozása',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        )
                    ),
                  ),
                  const SizedBox(height: 20), // Space between buttons
                  TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Aszf()),
                      );
                    },
                    child: Text('ÁSZF & Adatvédelmi tájékoztató',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 9,
                          ),
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
