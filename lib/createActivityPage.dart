import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'imageAnalysisService.dart';

class CreateActivityPage extends StatefulWidget {
  @override
  _CreateActivityPageState createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String lieu = '';
  String prix = '';
  String imageUrl = '';
  String categorie = '';
  int nombrePersonnesMinimum = 0;
  List<String> categories = [
    'Sport',
    'Shopping',
    'Ludique',
    'Culture',
    'Nature',
    'Gastronomie'
  ];
  String? selectedCategorie;

  void createActivity() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!
          .save(); // Sauvegarde des valeurs des champs dans les variables d'état

      // Utilise le service de recherche d'images pour trouver une image basée sur le titre
      String? foundImageUrl = await ImageSearchService().findImage(title);

      // Si aucune image n'est trouvée, utilise une URL d'image par défaut ou laisse 'imageUrl' vide
      String finalImageUrl = foundImageUrl ??
          imageUrl; // Ou une URL d'image par défaut (fonctionne bien donc pas besoin pour l'instant)

      // Insére les données dans Firestore et récupére l'ID de l'activité créée
      DocumentReference activityRef =
          await FirebaseFirestore.instance.collection('activites').add({
        'title': title,
        'lieu': lieu,
        'prix': prix,
        'imageUrl':
            finalImageUrl, // Utilise l'URL d'image trouvée ou une URL par défaut
        'categorie': categorie,
        'nombrePersonnesMinimum': nombrePersonnesMinimum,
      });

      // L'ID de l'activité est l'ID du document Firestore créé
      String activityId = activityRef.id;
      print("Activité créée avec ID: $activityId");

      Navigator.pop(context); // Retourne à l'écran des activités
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Créer une activité")),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Titre'),
                onSaved: (value) {
                  title = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Lieu'),
                onSaved: (value) {
                  lieu = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un lieu';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Prix'),
                onSaved: (value) {
                  prix = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un prix';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Catégorie'),
                value: selectedCategorie,
                items: categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategorie = newValue;
                  });
                },
                onSaved: (value) {
                  categorie = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une catégorie';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Nombre de personnes minimum'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  nombrePersonnesMinimum = int.tryParse(value!) ?? 0;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer le nombre de personnes minimum';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: createActivity,
                  child: Text('Créer l\'activité'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
