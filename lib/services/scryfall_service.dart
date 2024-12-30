import 'dart:convert';
import 'package:http/http.dart' as http;

class ScryfallService {
  /// Fetch a single card by name
  static Future<Map<String, dynamic>> fetchCard(String cardName) async {
    final response = await http.get(Uri.parse('https://api.scryfall.com/cards/named?fuzzy=$cardName'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load card data');
    }
  }

  /// Fetch all cards with batch request
  static Future<List<dynamic>> fetchAllCards() async { // Made static
    final response = await http.get(Uri.parse('https://api.scryfall.com/cards/search?order=cmc'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch cards');
    }
  }
}

