/*
import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/material.dart';
import '../services/scryfall_service.dart';
import '../services/db_service.dart'; // Local cache service

class ResultsScreen extends StatelessWidget {
  final String cardName;

  ResultsScreen({required this.cardName});

  /// Method to check the cache first and fall back to API if needed
  Future<Map<String, dynamic>> getCardData(String cardName) async {
    final cacheData = await DBService.fetchFromCache(cardName);
    if (cacheData != null) {
      final cachedData = cacheData['card_data'];
      if (cachedData is String) {
        final decodedData = json.decode(cachedData);
        if (decodedData is Map<String, dynamic>) {
          return decodedData;
        } else {
          throw Exception("Cached data is not a valid Map<String, dynamic>.");
        }
      } else {
        throw Exception("Cached data is not a String.");
      }
    } else {
      final cardData = await ScryfallService.fetchCard(cardName);
      await DBService.insertCache(cardName, json.encode(cardData));
      return cardData;
    }
  }

  /// Retrieves card data and filters potential synergies based on DSC, CMC, and Type
  Future<Map<String, dynamic>> getCardDataWithSynergy(
      String cardName, String? desiredColor, int? cmc) async {
    final mainCardData = await getCardData(cardName);
    final allCards = await ScryfallService.fetchAllCards();
    final filteredCandidates = filterSynergyCandidates(
      allCards,
      desiredColor,
      cmc,
      mainCardData['type_line'] as String?,
    );
    return {
      'mainCard': mainCardData,
      'synergyCandidates': filteredCandidates,
    };
  }

  /// Filters cards based on DSC, CMC, and Type
  List<Map<String, dynamic>> filterSynergyCandidates(
      List<dynamic> allCards, String? desiredColor, int? cmc, String? typeLine) {
    return allCards
        .where((card) {
      if (card is! Map<String, dynamic>) return false;
      final cardColors = (card['color_identity'] as List<dynamic>? ?? []).cast<String>();
      final cardCMC = card['cmc'] as int? ?? 0;
      final cardType = card['type_line'] as String? ?? '';

      final matchesColor = desiredColor == null || cardColors.contains(desiredColor);
      final matchesCMC = cmc == null || cardCMC == cmc;
      final matchesType = typeLine == null || cardType.toLowerCase().contains(typeLine.toLowerCase());

      return matchesColor && matchesCMC && matchesType;
    })
        .cast<Map<String, dynamic>>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final cardName = args['cardName'] as String? ?? '';
    final desiredColor = args['dsc'] as String?;
    final cmc = args['cmc'] as int?;

    if (cardName.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Search Results'),
        ),
        body: Center(
          child: Text('No card name provided.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getCardDataWithSynergy(cardName, desiredColor, cmc),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data found.'));
          } else {
            final mainCard = snapshot.data!['mainCard'] as Map<String, dynamic>;
            final synergies = (snapshot.data!['synergyCandidates'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
            final colors = (mainCard['color_identity'] as List<dynamic>? ?? []).cast<String>();
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
                      // Main Card Details
                      Text(
                        mainCard['name'] ?? 'Card not found',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (mainCard['mana_cost'] != null)
                        Text(
                          'Mana Cost: ${mainCard['mana_cost']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      if (mainCard['type_line'] != null)
                        Text(
                          'Type: ${mainCard['type_line']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      if (mainCard['rarity'] != null)
                        Text(
                          'Rarity: ${mainCard['rarity']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: textColor,
                          ),
                        ),
                      if (mainCard['set_name'] != null)
                        Text(
                          'Set: ${mainCard['set_name']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      if (mainCard['flavor_text'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            'Flavor: ${mainCard['flavor_text']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: textColor,
                            ),
                          ),
                        ),
                      if (mainCard['oracle_text'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            'Oracle Text: ${mainCard['oracle_text']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      if (mainCard['image_uris'] != null &&
                          mainCard['image_uris']['normal'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Image.network(
                            mainCard['image_uris']['normal'],
                          ),
                        ),
                      SizedBox(height: 20),
                      // Synergy Candidates
                      Text(
                        'Potential Synergies:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      ...synergies.map((synergy) {
                        final synergyName = synergy['name'] ?? 'Unknown';
                        final synergyType = synergy['type_line'] ?? '';
                        return ListTile(
                          title: Text(synergyName, style: TextStyle(color: textColor)),
                          subtitle: Text(synergyType, style: TextStyle(color: textColor)),
                        );
                      }).toList(),
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
  BoxDecoration getBackgroundDecoration(List<String> colors) {
    const manaColors = {
      "W": Colors.white,
      "U": Colors.blue,
      "B": Colors.black,
      "R": Colors.red,
      "G": Colors.green,
      "gold": Color(0xFFFFD700),
    };

    if (colors.isEmpty) {
      return BoxDecoration(
        gradient: RadialGradient(
          colors: [Colors.grey[900]!, Colors.grey[700]!],
          center: Alignment.center,
          radius: 1.0,
        ),
      );
    } else if (colors.length == 1) {
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
      return BoxDecoration(
        gradient: RadialGradient(
          colors: [manaColors["gold"]!, manaColors["gold"]!.withOpacity(0.7)],
          center: Alignment.center,
          radius: 1.0,
        ),
      );
    }
  }

  /// Determines the text color based on mana colors.
  Color getTextColor(List<String> colors) {
    if (colors.contains("W")) {
      return Colors.black;
    }
    return Colors.white;
  }
}
 */
import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/material.dart';
import '../services/scryfall_service.dart';
import '../services/db_service.dart'; // Local cache service

class ResultsScreen extends StatelessWidget {
  final String cardName;
  final Map<String, dynamic>? arguments;

  ResultsScreen({required this.cardName, this.arguments});

  /// Method to check the cache first and fall back to API if needed
  Future<Map<String, dynamic>> getCardData(String cardName) async {
    final cacheData = await DBService.fetchFromCache(cardName);
    if (cacheData != null) {
      final decodedData = json.decode(cacheData['card_data']);
      if (decodedData is Map<String, dynamic>) {
        return decodedData;
      } else {
        throw Exception("Cached data is not in the expected format.");
      }
    } else {
      final cardData = await ScryfallService.fetchCard(cardName);
      await DBService.insertCache(cardName, json.encode(cardData));
      return cardData;
    }
  }

  /// Retrieves card data and filters potential synergies based on DSC, CMC, and Type
  Future<Map<String, dynamic>> getCardDataWithSynergy(
      String cardName, String? desiredColor, int? cmc) async {
    final mainCardData = await getCardData(cardName);
    final allCards = await ScryfallService.fetchAllCards();

    final filteredCandidates = filterSynergyCandidates(
      allCards,
      desiredColor,
      cmc,
      mainCardData['type_line'] as String?,
    );

    return {
      'mainCard': mainCardData,
      'synergyCandidates': filteredCandidates,
    };
  }

  /// Filters cards based on DSC, CMC, and Type
  List<Map<String, dynamic>> filterSynergyCandidates(
      List<dynamic> allCards, String? desiredColor, int? cmc, String? typeLine) {
    return allCards
        .where((card) {
      if (card is! Map<String, dynamic>) return false;
      final cardColors = (card['color_identity'] as List<dynamic>? ?? []).cast<String>();
      final cardCMC = card['cmc'] as int? ?? 0;
      final cardType = card['type_line'] as String? ?? '';

      final matchesColor = desiredColor == null || cardColors.contains(desiredColor);
      final matchesCMC = cmc == null || cardCMC == cmc;
      final matchesType = typeLine == null || cardType.toLowerCase().contains(typeLine.toLowerCase());

      return matchesColor && matchesCMC && matchesType;
    })
        .cast<Map<String, dynamic>>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Validate and log incoming arguments
    final args = ModalRoute.of(context)!.settings.arguments;
    print("Raw arguments passed to ResultsScreen: $args");

    if (args == null || args is! Map<String, dynamic>) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('Error: Invalid arguments passed to ResultsScreen.'),
        ),
      );
    }

    // Safely retrieve arguments
    final cardName = args['cardName'] is String ? args['cardName'] as String : '';
    final desiredColor = args['dsc'] is String ? args['dsc'] as String : null;
    final cmc = args['cmc'] is int ? args['cmc'] as int : null;

    print("Extracted arguments - cardName: $cardName, desiredColor: $desiredColor, cmc: $cmc");

    if (cardName.isEmpty) {
      print("Error: cardName is invalid or missing.");
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('Error: Invalid card name provided.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getCardDataWithSynergy(cardName, desiredColor, cmc),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("Error in FutureBuilder: ${snapshot.error}");
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data found.'));
          } else {
            final mainCard = snapshot.data!['mainCard'] as Map<String, dynamic>;
            final synergies = (snapshot.data!['synergyCandidates'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
            final colors = (mainCard['color_identity'] as List<dynamic>? ?? []).cast<String>();
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
                      // Main Card Details
                      Text(
                        mainCard['name'] ?? 'Card not found',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (mainCard['mana_cost'] != null)
                        Text(
                          'Mana Cost: ${mainCard['mana_cost']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      if (mainCard['type_line'] != null)
                        Text(
                          'Type: ${mainCard['type_line']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      if (mainCard['rarity'] != null)
                        Text(
                          'Rarity: ${mainCard['rarity']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: textColor,
                          ),
                        ),
                      SizedBox(height: 20),
                      // Synergy Candidates
                      Text(
                        'Potential Synergies:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      ...synergies.map((synergy) {
                        final synergyName = synergy['name'] ?? 'Unknown';
                        final synergyType = synergy['type_line'] ?? '';
                        return ListTile(
                          title: Text(synergyName, style: TextStyle(color: textColor)),
                          subtitle: Text(synergyType, style: TextStyle(color: textColor)),
                        );
                      }).toList(),
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
  BoxDecoration getBackgroundDecoration(List<String> colors) {
    const manaColors = {
      "W": Colors.white,
      "U": Colors.blue,
      "B": Colors.black,
      "R": Colors.red,
      "G": Colors.green,
      "gold": Color(0xFFFFD700),
    };

    if (colors.isEmpty) {
      return BoxDecoration(
        gradient: RadialGradient(
          colors: [Colors.grey[900]!, Colors.grey[700]!],
          center: Alignment.center,
          radius: 1.0,
        ),
      );
    } else if (colors.length == 1) {
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
      return BoxDecoration(
        gradient: RadialGradient(
          colors: [manaColors["gold"]!, manaColors["gold"]!.withOpacity(0.7)],
          center: Alignment.center,
          radius: 1.0,
        ),
      );
    }
  }

  /// Determines the text color based on mana colors.
  Color getTextColor(List<String> colors) {
    if (colors.contains("W")) {
      return Colors.black;
    }
    return Colors.white;
  }
}