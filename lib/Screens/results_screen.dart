import 'package:flutter/material.dart';
import '../services/scryfall_service.dart';

class ResultsScreen extends StatelessWidget {
  final String cardName;

  ResultsScreen({required this.cardName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: FutureBuilder(
        future: ScryfallService.fetchCard(cardName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final card = snapshot.data as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Name
                    Text(
                      card['name'] ?? 'Card not found',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),

                    // Mana Cost
                    if (card['mana_cost'] != null)
                      Text(
                        'Mana Cost: ${card['mana_cost']}',
                        style: TextStyle(fontSize: 18),
                      ),

                    // Type Line
                    if (card['type_line'] != null)
                      Text(
                        'Type: ${card['type_line']}',
                        style: TextStyle(fontSize: 18),
                      ),

                    // Oracle Text
                    if (card['oracle_text'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          'Text: ${card['oracle_text']}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),

                    // Power and Toughness (for creatures)
                    if (card['power'] != null && card['toughness'] != null)
                      Text(
                        'Power/Toughness: ${card['power']}/${card['toughness']}',
                        style: TextStyle(fontSize: 18),
                      ),

                    // Card Image
                    if (card['image_uris'] != null && card['image_uris']['normal'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Image.network(
                          card['image_uris']['normal'],
                        ),
                      ),

                    // Rarity
                    if (card['rarity'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          'Rarity: ${card['rarity']}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),

                    // Set Name
                    if (card['set_name'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          'Set: ${card['set_name']}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),

                    // Flavor Text
                    if (card['flavor_text'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          'Flavor: "${card['flavor_text']}"',
                          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
