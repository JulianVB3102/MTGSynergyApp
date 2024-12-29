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
            final colors = card['color_identity'] as List<dynamic>? ?? [];

            // Get background and text color
            final background = getBackgroundDecoration(colors);
            final textColor = getTextColor(colors);

            return Container(
              decoration: background,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card['name'] ?? 'Card not found',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      if (card['mana_cost'] != null)
                        Text(
                          'Mana Cost: ${card['mana_cost']}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                      if (card['type_line'] != null)
                        Text(
                          'Type: ${card['type_line']}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                      if (card['oracle_text'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            'Text: ${card['oracle_text']}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                          ),
                        ),
                      if (card['image_uris'] != null &&
                          card['image_uris']['normal'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Image.network(
                            card['image_uris']['normal'],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  /// Returns the background decoration with depth based on mana colors.
  BoxDecoration getBackgroundDecoration(List<dynamic> colors) {
    const manaColors = {
      "W": Colors.white,
      "U": Colors.blue,
      "B": Colors.black,
      "R": Colors.red,
      "G": Colors.green,
      "gold": Color(0xFFFFD700), // Gold for multicolor
    };

    if (colors.isEmpty) {
      // Default colorless background with texture
      return BoxDecoration(
        gradient: RadialGradient(
          colors: [Colors.grey[900]!, Colors.grey[700]!],
          center: Alignment.center,
          radius: 1.0,
        ),
      );
    } else if (colors.length == 1) {
      // Single color with a subtle gradient
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            manaColors[colors[0]]!.withOpacity(0.9),
            manaColors[colors[0]]!.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else if (colors.length == 2) {
      // Two-color gradient with depth
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            manaColors[colors[0]]!.withOpacity(0.8),
            manaColors[colors[1]]!.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else {
      // Multicolor background with a gold textured look
      return BoxDecoration(
        gradient: RadialGradient(
          colors: [manaColors["gold"]!, manaColors["gold"]!.withOpacity(0.7)],
          center: Alignment.center,
          radius: 1.0,
        ),
        image: DecorationImage(
          image: AssetImage('assets/textures/img.png'),
          fit: BoxFit.cover,
          colorFilter:
          ColorFilter.mode(Colors.yellow.withOpacity(0.2), BlendMode.overlay),
        ),
      );
    }
  }

  /// Determines the text color based on mana colors.
  Color getTextColor(List<dynamic> colors) {
    if (colors.contains("W")) {
      // Default to black text for white or colorless cards
      return Colors.black;
    }
    // White text for dark backgrounds
    return Colors.white;
  }
}
