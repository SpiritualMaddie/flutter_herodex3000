import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_herodex3000/data/models/powerstats_model.dart';

void main() {
  group('PowerstatsModel.fromJson safe parsing', () {
    test('_safeParse should handle string "null"', () {
      // Arrange
      final json = {
        'intelligence': 'null',
        'strength': '75',
        'speed': '80',
        'durability': '90',
        'power': '85',
        'combat': '95',
      };

      // Act
      final stats = PowerstatsModel.fromJson(json);

      // Assert
      expect(stats.intelligence, 0); // "null" string should parse to 0
      expect(stats.strength, 75);
    });

    test('_safeParse should handle empty strings', () {
      // Arrange
      final json = {
        'intelligence': '',
        'strength': '',
        'speed': '50',
        'durability': '60',
        'power': '70',
        'combat': '80',
      };

      // Act
      final stats = PowerstatsModel.fromJson(json);

      // Assert
      expect(stats.intelligence, 0); // Empty string should parse to 0
      expect(stats.strength, 0);
      expect(stats.speed, 50);
    });

    test('_safeParse should handle actual null values', () {
      // Arrange
      final json = {
        'intelligence': null,
        'strength': null,
        'speed': '40',
        'durability': '50',
        'power': '60',
        'combat': '70',
      };

      // Act
      final stats = PowerstatsModel.fromJson(json);

      // Assert
      expect(stats.intelligence, 0); // null should parse to 0
      expect(stats.strength, 0);
      expect(stats.speed, 40);
    });
  });
}
