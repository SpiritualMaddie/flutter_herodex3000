import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_herodex3000/data/models/agent_model.dart';
import 'package:flutter_herodex3000/data/models/powerstats_model.dart';
import 'package:flutter_herodex3000/data/models/biography_model.dart';
import 'package:flutter_herodex3000/data/models/appearance_model.dart';
import 'package:flutter_herodex3000/presentation/helpers/agent_summary_mapper.dart';

void main() {
  group('AgentSummaryMapper.toSummary', () {
    test('should map AgentModel to AgentSummary correctly', () {
      // Arrange
      final agent = AgentModel(
        agentId: '4',
        name: 'Wonder Woman',
        powerstats: PowerstatsModel(
          intelligence: 88,
          strength: 100,
          speed: 79,
          durability: 100,
          power: 100,
          combat: 100,
        ),
        biography: BiographyModel(
          fullName: 'Diana Prince',
          alterEgos: 'No alter egos found.',
          aliases: ['Princess Diana'],
          placeOfBirth: 'Themyscira',
          firstAppearance: 'All-Star Comics #8',
          publisher: 'DC Comics',
          alignment: 'good',
        ),
        appearance: AppearanceModel(
          gender: 'Female',
          race: 'Amazon',
          height: ['6\'0"', '183 cm'],
          weight: ['165 lb', '75 kg'],
        ),
      );

      // Act
      final summary = AgentSummaryMapper.toSummary(agent);

      // Assert
      expect(summary.id, '4');
      expect(summary.name, 'Wonder Woman');
      expect(summary.alignment, 'good');
      expect(summary.power, 100);
      expect(summary.strength, 100);
      expect(summary.intelligence, 88);
      expect(summary.isHero, true); // good alignment = hero
    });

    test('toSummary should correctly identify villain alignment', () {
      // Arrange
      final agent = AgentModel(
        agentId: '5',
        name: 'Joker',
        powerstats: PowerstatsModel(
          intelligence: 100,
          strength: 10,
          speed: 12,
          durability: 60,
          power: 43,
          combat: 90,
        ),
        biography: BiographyModel(
          fullName: 'Jack Napier',
          alterEgos: 'No alter egos found.',
          aliases: ['Clown Prince of Crime'],
          placeOfBirth: 'Gotham City',
          firstAppearance: 'Batman #1',
          publisher: 'DC Comics',
          alignment: 'bad',
        ),
        appearance: AppearanceModel(
          gender: 'Male',
          race: 'Human',
          height: ['6\'5"', '196 cm'],
          weight: ['192 lb', '87 kg'],
        ),
      );

      // Act
      final summary = AgentSummaryMapper.toSummary(agent);

      // Assert
      expect(summary.alignment, 'bad');
      expect(summary.isHero, false); // bad alignment = villain
    });

    test('toSummary should handle missing image URL', () {
      // Arrange
      final agent = AgentModel(
        agentId: '6',
        name: 'Mystery Hero',
        powerstats: PowerstatsModel(
          intelligence: 50,
          strength: 50,
          speed: 50,
          durability: 50,
          power: 50,
          combat: 50,
        ),
        biography: BiographyModel(
          fullName: 'Unknown',
          alterEgos: 'No alter egos found.',
          aliases: [],
          placeOfBirth: '-',
          firstAppearance: '-',
          publisher: "null",
          alignment: 'neutral',
        ),
        appearance: AppearanceModel(
          gender: 'Male',
          race: "null",
          height: [],
          weight: [],
        ),
        image: null, // No image
      );

      // Act
      final summary = AgentSummaryMapper.toSummary(agent);

      // Assert
      expect(summary.imageUrl, ''); // Should default to empty string
    });
  });
}
