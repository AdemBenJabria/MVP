import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'activity.dart';

class ActivityDetailPage extends StatelessWidget {
  final Activity activity;

  const ActivityDetailPage({Key? key, required this.activity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activity.title),
        actions: [
          IconButton(
            icon: Icon(Icons.add_comment),
            onPressed: () => _showReviewDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Image.network(activity.imageUrl),
            Text(activity.title),
            Text(activity.categorie),
            Text(activity.lieu),
            Text(
                'Nombre de personnes minimum: ${activity.nombrePersonnesMinimum}'),
            Text('Prix: ${activity.prix}€'),
            _buildReviewsSection(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addToCart(context, activity),
        child: Icon(Icons.add_shopping_cart),
        tooltip: 'Ajouter au panier',
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    final TextEditingController _commentController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    int _rating = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un avis'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              // Permet le défilement pour éviter le dépassement
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: _commentController,
                    decoration: InputDecoration(labelText: 'Votre avis'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un avis';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Text('Note :'),
                  Wrap(
                    // Wrap pour gérer l'espace
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          _rating = index + 1;
                          // Force la mise à jour de l'interface sans fermer la boîte de dialogue
                          (context as Element).markNeedsBuild();
                        },
                      );
                    }),
                    spacing: 7.0, // Ajoute un espacement entre les étoiles
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Envoyer'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Récupération du nom d'utilisateur depuis Firestore
                  String userName =
                      'Anonyme'; // Valeur par défaut si non trouvé comme sur Amazon
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final userData = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();
                    userName = userData.data()?['username'] ?? 'Anonyme';
                  }

                  // Envoyer l'avis à Firestore avec le nom d'utilisateur
                  FirebaseFirestore.instance
                      .collection('activity_reviews')
                      .add({
                    'activityTitle': activity.title,
                    'comment': _commentController.text,
                    'rating': _rating,
                    'userId': user?.uid ?? 'Anonyme',
                    'username':
                        userName, // Ajoute le nom d'utilisateur récupéré
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    // Récupérer et afficher les avis de l'activité
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('activity_reviews')
          .where('activityTitle', isEqualTo: activity.title)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Aucun avis disponible pour cette activité."),
          );
        }
        return Column(
          children: snapshot.data!.docs.map((doc) {
            final reviewData = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(
                  '${reviewData['username']}'), // Affiche le nom d'utilisateur
              subtitle: Text(reviewData['comment']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < reviewData['rating']
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void addToCart(BuildContext context, Activity activity) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('panier')
          .add({
        'categorie': activity.categorie,
        'imageUrl': activity.imageUrl,
        'lieu': activity.lieu,
        'nombrePersonnesMinimum': activity.nombrePersonnesMinimum,
        'prix': activity.prix,
        'title': activity.title,
      }).then((_) {
        // Mise à jour des préférences de catégorie
        final userPreferencesDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('preferences')
            .doc('categories');

        userPreferencesDoc.get().then((docSnapshot) {
          if (docSnapshot.exists) {
            // Mise à jour des compteurs pour cette catégorie et fourchette de prix
            userPreferencesDoc.update({
              'categories.${activity.categorie}': FieldValue.increment(1),
              'prix.${activity.prix}': FieldValue.increment(1),
            });
          } else {
            // Création du document avec la catégorie et le prix actuel
            userPreferencesDoc.set({
              'categories': {activity.categorie: 1},
              'prix': {activity.prix: 1},
            });
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Activité ajoutée au panier')));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'ajout au panier')));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Vous devez être connecté pour ajouter au panier')));
    }
  }
}
