import 'package:chat_app_firebase/Widgets/widgets.dart';
import 'package:chat_app_firebase/helper/helper_function.dart';
import 'package:chat_app_firebase/pages/auth/registerPage.dart';
import 'package:chat_app_firebase/pages/homePage.dart';
import 'package:chat_app_firebase/services/auth_services.dart';
import 'package:chat_app_firebase/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final fromkey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthServices authServices = AuthServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body:_isLoading?Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),):SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 80),
            child: Form(
              key: fromkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Groupie",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Login now to see what they are talking!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Image.asset(
                    'assets/login.jpg',
                  ),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                      hintText: "Email",
                      prefixIcon: Icon(
                        CupertinoIcons.mail_solid,
                        color: Colors.green,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        email = val;
                        print(email);
                      });
                    },
                    validator: (value) {
                      return RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value!)
                          ? null
                          : "Please enter a valid email";
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: textInputDecoration.copyWith(
                      hintText: "Password",
                      prefixIcon: Icon(
                        CupertinoIcons.lock,
                        color: Colors.green,
                      ),
                    ),
                    onChanged: (val) {
                      password = val;
                    },
                    validator: (value) {
                      if (value!.length < 8) {
                        return "Password must be at least 8 characters";
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          primary:
                              Theme.of(context).primaryColor.withOpacity(.7),
                          elevation: 0),
                      onPressed: () {
                        login();
                      },
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Register here",
                          style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              nextScreen(context, RegisterPage());
                            },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
  login() async {
    if (fromkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authServices.loginWithUserNamedandPassword( email, password).then((value)async{
        if(value == true){
         QuerySnapshot snapshot = await DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid).gettingUserData(email);
          nextScreenReplace(context, HomePage());

        //  saving the value to our shared Preferencees
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSF(email);
          await HelperFunction.saveUserNameSF(snapshot.docs[0]["fullName"]);

        }
        else
        {
          showSnackbar(context,Colors.red,value);
          setState(() {
            _isLoading = false;
          });
        }
      });

    }
  }
}
