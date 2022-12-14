import 'package:chat_app_firebase/Widgets/widgets.dart';
import 'package:chat_app_firebase/helper/helper_function.dart';
import 'package:chat_app_firebase/pages/auth/loginPage.dart';
import 'package:chat_app_firebase/pages/homePage.dart';
import 'package:chat_app_firebase/services/auth_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final fromkey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String fullname = "";
  bool _isLoading = false;
  AuthServices authServices = AuthServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 80),
                  child: Form(
                    key: fromkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Groupie",
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Create your account now to chat and explore",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Image.network(
                          'https://img.freepik.com/free-vector/setup-concept-illustration_114360-382.jpg?w=996&t=st=1670745612~exp=1670746212~hmac=d0611cbecadada86a2476dfbd66b8611f5fabf9686c12eeab305ca2cdbf1bc7f',
                          height: 300,
                          width: 300,
                        ),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                            hintText: "Fullname",
                            prefixIcon: Icon(
                              CupertinoIcons.person_solid,
                              color: Colors.green,
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {
                              fullname = val;
                              print(fullname);
                            });
                          },
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Name cannot be empty";
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: 15,
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
                              CupertinoIcons.lock_fill,
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
                                primary: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(.7),
                                elevation: 0),
                            onPressed: () {
                              register();
                            },
                            child: Text(
                              "Register",
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
                            text: "Already have an account? ",
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            children: [
                              TextSpan(
                                text: "Login now",
                                style: TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context, LoginPage());
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

  register() async {
    if (fromkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authServices.registerUserEmailandPassword(fullname, email, password).then((value)async{
        if(value == true){
         await HelperFunction.saveUserLoggedInStatus(true);
         await HelperFunction.saveUserEmailSF(email);
         await HelperFunction.saveUserNameSF(fullname);
         nextScreenReplace(context, HomePage());
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
