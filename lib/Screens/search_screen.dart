import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController cardNameController = TextEditingController();
  final TextEditingController cmcController = TextEditingController();
  String? selectedColor; // For Desired Synergy Color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search for Cards'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card Name Input
            TextField(
              controller: cardNameController,
              decoration: InputDecoration(
                labelText: 'Card Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Desired Synergy Color Dropdown
            DropdownButtonFormField<String>(
              value: selectedColor,
              items: ['W', 'U', 'B', 'R', 'G', 'Colorless']
                  .map((color) => DropdownMenuItem(
                value: color,
                child: Text(color),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedColor = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Desired Synergy Color (DSC)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Converted Mana Cost Input
            TextField(
              controller: cmcController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Converted Mana Cost (CMC)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Search Button
            ElevatedButton(
              onPressed: () {
                final cardName = cardNameController.text.trim();

                if (cardName.isEmpty) {
                  // Validate that a card name is entered
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a card name.')),
                  );
                  return;
                }

                // Log arguments for debugging
                final arguments = {
                  'cardName': cardName,
                  'dsc': selectedColor?.isNotEmpty == true ? selectedColor : null,
                  'cmc': cmcController.text.trim().isNotEmpty
                      ? int.tryParse(cmcController.text.trim())
                      : null,
                };
                print("Arguments passed to ResultsScreen: $arguments");

                // Pass inputs to the results screen
                Navigator.pushNamed(
                  context,
                  '/results',
                  arguments: arguments,
                );
              },
              child: Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}


