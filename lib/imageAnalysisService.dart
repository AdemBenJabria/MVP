import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageSearchService {
  final String apiKey = 'AIzaSyDrNdqxaKvNBnmeiRUh5LVRBipBEnMoyEM';
  final String searchEngineId = '42b02adcd1970464b';

  Future<String?> findImage(String query) async {
    final String apiUrl =
        'https://www.googleapis.com/customsearch/v1?q=$query&cx=$searchEngineId&searchType=image&key=$apiKey&fileType=png&num=1';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          // Récupère le lien de la première image trouvée
          final String imageUrl = data['items'][0]['link'];
          return imageUrl;
        }
      }
    } catch (e) {
      print('Erreur lors de la recherche d\'image : $e');
    }
    return null; // Retourne null si aucune image n'a été trouvée ou en cas d'erreur
  }
}
