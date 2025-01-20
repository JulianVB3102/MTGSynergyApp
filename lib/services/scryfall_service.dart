/*import 'dart:convert';
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
*/
import 'dart:convert'; // For JSON encoding and decoding
import 'package:http/http.dart' as http; // For making HTTP requests

class ScryfallService {
  /// Fetch a single card by name
  static Future<Map<String, dynamic>> fetchCard(String cardName) async {
    final response = await http.get(Uri.parse('https://api.scryfall.com/cards/named?fuzzy=$cardName'));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      if (decodedData is Map<String, dynamic>) {
        return decodedData;
      } else {
        throw Exception("Unexpected response format for fetchCard.");
      }
    } else {
      throw Exception('Failed to load card data: ${response.reasonPhrase}');
    }
  }

  /// Fetch all cards with batch request
  static Future<List<dynamic>> fetchAllCards() async {
    final response = await http.get(Uri.parse('https://api.scryfall.com/cards/search?order=cmc'));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      if (decodedData is Map<String, dynamic> && decodedData['data'] is List) {
        return decodedData['data'] as List<dynamic>;
      } else {
        throw Exception("Unexpected response format for fetchAllCards.");
      }
    } else {
      throw Exception('Failed to fetch cards: ${response.reasonPhrase}');
    }
  }
}



