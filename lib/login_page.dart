import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'mainPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String username = '';
  String password = '';

  void signInWithUsernameAndPassword() async {
    if (username.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Veuillez remplir tous les champs");
      return;
    }

    final QuerySnapshot userQuery = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (userQuery.docs.isEmpty) {
      Fluttertoast.showToast(msg: "Utilisateur non trouvé");
      return;
    }

    String email = userQuery.docs.first.get('email');

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => MainPage()));
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur de connexion: ${e.toString()}");
    }
  }

  void registerWithUsernameAndPassword() async {
    if (username.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Veuillez remplir tous les champs");
      return;
    }

    String email = "$username@mvpapp.com";

    try {
      UserCredential newUser = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Enregistre le nom d'utilisateur et l'email associé dans Firestore
      await _firestore.collection('users').doc(newUser.user!.uid).set({
        'username': username,
        'email': email,
      });

      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => MainPage()));
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur d'inscription: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MVP")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                onChanged: (value) => username = value.trim(),
                decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                onChanged: (value) => password = value,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Mot de passe'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: signInWithUsernameAndPassword,
                child: Text('Se connecter'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: registerWithUsernameAndPassword,
                child: Text('S\'inscrire'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
