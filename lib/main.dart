import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async{

  //Initialize hive 
 await Hive.initFlutter(); 
 // Open a box 
 await Hive.openBox("Habit_Database");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Flutter Demo',
      home: Homepage() ,
      debugShowCheckedModeBanner:false ,
      theme: ThemeData(primarySwatch: Colors.green),
    );
  }
}

