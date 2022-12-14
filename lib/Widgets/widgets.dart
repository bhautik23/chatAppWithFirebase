import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
  focusedBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2)),
  enabledBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2)),
  errorBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)),
);

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void showSnackbar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message,style: TextStyle(fontSize: 14),),
    backgroundColor: color,
    duration: Duration(seconds: 2),
    action: SnackBarAction(label: "Ok",onPressed: (){},textColor: Colors.white,),
  ));
}
