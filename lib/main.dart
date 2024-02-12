import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart';
import 'mainPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyARbud4hyqbJMhf3bD_bfEVgLFYu--xj9A",
      appId: "1:61654628298:android:3704005996952aa9bc4133",
      messagingSenderId: "61654628298",
      projectId: "mvpfirebase-fb103",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MVP',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
      routes: {
        '/mainPage': (context) => MainPage(),
      },
    );
  }
}
