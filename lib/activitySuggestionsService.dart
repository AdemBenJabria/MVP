import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivitySuggestionsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  Future<List<String>> getSuggestedActivityTitles() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    // Récupérer les préférences de catégories de l'utilisateur
    DocumentSnapshot preferencesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('preferences')
        .doc('categories')
        .get();

    if (!preferencesSnapshot.exists) return [];

    // Obtenir les catégories préférées et les trier par compteur
    Map<String, dynamic> categoriesCount =
        (preferencesSnapshot.data() as Map<String, dynamic>)['categories'];
    List<String> sortedCategories = categoriesCount.keys.toList()
      ..sort((a, b) => categoriesCount[b].compareTo(categoriesCount[a]));

    // Générer des suggestions basées sur les catégories préférées
    List<String> suggestedActivityTitles = [];
    for (String category in sortedCategories) {
      QuerySnapshot suggestedActivitiesSnapshot = await FirebaseFirestore
          .instance
          .collection('activites')
          .where('categorie', isEqualTo: category)
          .limit(2)
          .get();

      suggestedActivityTitles.addAll(suggestedActivitiesSnapshot.docs
          .map((doc) => doc['title'] as String)
          .toList());
    }

    return suggestedActivityTitles;
  }
}
