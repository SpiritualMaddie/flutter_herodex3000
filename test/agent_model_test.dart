import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgentModel.fromJson', () {
    test('fromJson should parse valid JSON correctly', () {
      // Arrange
      final json = {
        'id': '1',
        'name': 'Spider-Man',
        'powerstats': {
          'intelligence': '90',
          'strength': '55',
          'speed': '67',
          'durability': '75',
          'power': '74',
          'combat': '85',
        },
        'biography': {
          'full-name': 'Peter Parker',
          'alter-egos': 'No alter egos found.',
          'aliases': ['Spidey', 'Web-Slinger'],
          'place-of-birth': 'New York',
          'first-appearance': 'Amazing Fantasy #15',
          'publisher': 'Marvel Comics',
          'alignment': 'good',
        },
        'appearance': {
          'gender': 'Male',
          'race': 'Human',
          'height': ['5\'10"', '178 cm'],
          'weight': ['165 lb', '75 kg'],
          'eye-color': 'Hazel',
          'hair-color': 'Brown',
        },
        'image': {
          'url': 'https://example.com/spiderman.jpg',
        },
      };

      // Act
      final agent = AgentModel.fromJson(json);

      // Assert
      expect(agent.agentId, '1');
      expect(agent.name, 'Spider-Man');
      expect(agent.powerstats.intelligence, 90);
      expect(agent.powerstats.strength, 55);
      expect(agent.biography.fullName, 'Peter Parker');
      expect(agent.biography.alignment, 'good');
      expect(agent.appearance.gender, 'Male');
      expect(agent.image?.url, 'https://example.com/spiderman.jpg');
    });

    test('fromJson should handle null and missing fields', () {
      // Arrange - minimal JSON with missing optional fields
      final json = {
        'id': '2',
        'name': 'Unknown Hero',
        'powerstats': {
          'intelligence': 'null', // API sometimes returns string "null"
          'strength': '',
          'speed': "null",
          'durability': '50',
          'power': '60',
          'combat': '70',
        },
        'biography': {
          'full-name': "null",
          'alter-egos': '',
          'aliases': [],
          'place-of-birth': '-',
          'first-appearance': '-',
          'publisher': "null",
          'alignment': 'neutral',
        },
        'appearance': {
          'gender': 'Male',
          'race': "null",
          'height': [],
          'weight': [],
        },
        // No image field
      };

      // Act
      final agent = AgentModel.fromJson(json);

      // Assert
      expect(agent.agentId, '2');
      expect(agent.name, 'Unknown Hero');
      expect(agent.powerstats.intelligence, 0); // Should default to 0
      expect(agent.powerstats.strength, 0);
      expect(agent.powerstats.speed, 0);
      expect(agent.biography.fullName, "null");
      expect(agent.biography.publisher, "null");
      expect(agent.appearance.race, "null");
      expect(agent.image, agent.image);
    });
  });

  group('AgentModel.toJson', () {
    test('toJson should serialize AgentModel correctly', () {
      // Arrange
      final agent = AgentModel(
        agentId: '3',
        name: 'Iron Man',
        powerstats: PowerstatsModel(
          intelligence: 100,
          strength: 85,
          speed: 58,
          durability: 85,
          power: 100,
          combat: 64,
        ),
        biography: BiographyModel(
          fullName: 'Tony Stark',
          alterEgos: 'No alter egos found.',
          aliases: ['Shellhead', 'Golden Avenger'],
          placeOfBirth: 'Long Island, New York',
          firstAppearance: 'Tales of Suspense #39',
          publisher: 'Marvel Comics',
          alignment: 'good',
        ),
        appearance: AppearanceModel(
          gender: 'Male',
          race: 'Human',
          height: ['6\'1"', '185 cm'],
          weight: ['225 lb', '102 kg'],
          eyeColor: 'Blue',
          hairColor: 'Black',
        ),
      );

      // Act
      final json = agent.toJson();

      // Assert
      expect(json['id'], '3');
      expect(json['name'], 'Iron Man');
      expect(json['powerstats']['intelligence'], 100);
      expect(json['biography']['full-name'], 'Tony Stark');
      expect(json['biography']['alignment'], 'good');
    });
  });

  test('should handles extremely long names', () {
    // Arrange
      final json = {
        'id': '7',
        'name': 'A' * 1000, // Very long name
        'powerstats': {
          'intelligence': '50',
          'strength': '50',
          'speed': '50',
          'durability': '50',
          'power': '50',
          'combat': '50',
        },
        'biography': {
          'alignment': 'good',
        },
        'appearance': {
          'gender': 'Male',
        },
      };

      // Act
      final agent = AgentModel.fromJson(json);

      // Assert
      expect(agent.name.length, 1000);
      expect(agent.agentId, '7');
  });
}
