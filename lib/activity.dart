class Activity {
  final String imageUrl;
  final String title;
  final String lieu;
  final String prix;
  final String categorie;
  final int nombrePersonnesMinimum;

  Activity({
    required this.imageUrl,
    required this.title,
    required this.lieu,
    required this.prix,
    required this.categorie,
    required this.nombrePersonnesMinimum,
  });

  factory Activity.fromMap(Map<String, dynamic> data) {
    return Activity(
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '',
      lieu: data['lieu'] ?? '',
      prix: data['prix'] ?? '',
      categorie: data['categorie'] ?? '',
      nombrePersonnesMinimum: data['nombrePersonnesMinimum'] ?? 0,
    );
  }
}
