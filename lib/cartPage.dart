import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'activity.dart'; // Assurez-vous que cette classe est bien définie quelque part dans votre projet

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double total = 0;

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Panier'),
      ),
      body: currentUser != null
          ? StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('panier')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return Text("Aucune activité dans le panier.");
                }
                final activities = snapshot.data!.docs;
                total = 0; // Réinitialiser le total

                List<Widget> activityWidgets = activities.map((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  double prix = double.tryParse(data['prix'].toString()) ?? 0;
                  total += prix;

                  return ListTile(
                    leading: Image.network(data['imageUrl']),
                    title: Text(data['title']),
                    subtitle:
                        Text('${data['lieu']} - ${prix.toStringAsFixed(2)}€'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => removeFromCart(doc.id),
                    ),
                  );
                }).toList();

                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: activityWidgets,
                      ),
                    ),
                    Text('Total: ${total.toStringAsFixed(2)}€',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                );
              },
            )
          : Text("Veuillez vous connecter pour voir votre panier."),
    );
  }

  void removeFromCart(String activiteId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('panier')
          .doc(activiteId)
          .delete();
      setState(() {}); // Recharger l'état pour mettre à jour l'affichage
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Veuillez vous connecter pour modifier le panier")),
      );
    }
  }
}
