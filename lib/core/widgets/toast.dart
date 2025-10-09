import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FlutterToast{
  final String toastMsg;
  FlutterToast({required this.toastMsg});

  Future<bool?> toast(){
    return Fluttertoast.showToast(
                  msg: toastMsg,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.teal,
                  textColor: Colors.white,
                );
  }
}