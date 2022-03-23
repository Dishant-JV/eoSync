import 'package:e_o_sync/log_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ex.dart';



void main() {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(
      MaterialApp(
        home: LogInScreen(),
        debugShowCheckedModeBanner: false,
      )
  );
}

