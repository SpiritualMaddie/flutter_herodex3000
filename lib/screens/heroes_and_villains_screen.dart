import 'package:flutter/material.dart';

class HeroesAndVillainsScreen extends StatelessWidget {
  const HeroesAndVillainsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Heroes and Villains"),
    ),
    body: Column(
      crossAxisAlignment: .center,
      verticalDirection: .down,
      children: [
        Expanded(
          child: ListView(
            padding: .all(8),
            scrollDirection: .vertical,
            children: [
              Card(child: Text("Card 1"),),
              Card(child: Text("Card 2"),),
              Card(child: Text("Card 3"),),
              Card(child: Text("Card 4"),),
            ],
          ),
        ),
      ],
    ),
    );
  }
}