import 'package:flutter/material.dart';

class CircularIndicator{
Widget loading() {
    return Material(
              color:  Colors.black12,
              child: Center(child: CircularProgressIndicator(color: Colors.teal)));
       
  }
}