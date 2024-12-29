import 'dart:convert';
import 'package:http/http.dart' as http;

class ScryfallService {
  static Future<Map<String, dynamic>> fetchCard(String cardName) async {
    final response = await http.get(Uri.parse('https://api.scryfall.com/cards/named?fuzzy=$cardName'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load card data');
    }
  }
}
