import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    DocumentSnapshot userProfile =
        await _firestore.collection('users').doc(user!.uid).get();
    Map<String, dynamic> userData = userProfile.data() as Map<String, dynamic>;

    setState(() {
      _birthdayController.text = userData['birthday'] ?? '';
      _addressController.text = userData['address'] ?? '';
      _postalCodeController.text = userData['postalCode'] ?? '';
      _cityController.text = userData['city'] ?? '';
    });
  }

  void _saveProfile() async {
    // Sauvegarder les modifications du profil en base de données
    await _firestore.collection('users').doc(user!.uid).update({
      'birthday': _birthdayController.text,
      'address': _addressController.text,
      'postalCode': _postalCodeController.text,
      'city': _cityController.text,
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Profil mis à jour')));

    // Changement de mot de passe si le champ est rempli
    if (_newPasswordController.text.trim().isNotEmpty) {
      try {
        await user!.updatePassword(_newPasswordController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Mot de passe changé avec succès.")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Erreur lors du changement de mot de passe. ${e.toString()}")));
      }
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => LoginPage())); // Redirige vers la page de login
  }

  void _changePassword() async {
    String newPassword = _newPasswordController.text.trim();
    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Le nouveau mot de passe ne peut pas être vide.")));
      return;
    }

    try {
      await user!.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mot de passe changé avec succès.")));
      // Optionnel : Se déconnecter après le changement de mot de passe
      // _signOut();
    } catch (e) {
      print(e); // Pour le débogage
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Erreur lors du changement de mot de passe. Assurez-vous d'être récemment connecté.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Login'),
                initialValue: user!.email, // Utilise l'email comme login
                readOnly: true, // Login en lecture seule
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: 'Nouveau Mot de Passe'),
                obscureText: true, // Pour cacher le mot de passe
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Anniversaire'),
                controller: _birthdayController,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Adresse'),
                controller: _addressController,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Code Postal'),
                controller: _postalCodeController,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Ville'),
                controller: _cityController,
              ),
              ElevatedButton(
                onPressed: _signOut,
                child: Text('Se déconnecter'),
                style: ElevatedButton.styleFrom(primary: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
