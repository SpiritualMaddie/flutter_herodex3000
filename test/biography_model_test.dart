import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_herodex3000/data/models/biography_model.dart';

void main() {
  test('should handle empty aliases array', () {
    // Arrange
    final json = {
      'full-name': 'Test Hero',
      'alter-egos': 'No alter egos found.',
      'aliases': [],
      'place-of-birth': 'New York',
      'first-appearance': 'Amazing Fantasy #15',
      'publisher': 'Marvel Comics',
      'alignment': 'good',
    };

    // Act
    final bio = BiographyModel.fromJson(json);

    // Assert
    expect(bio.aliases, isEmpty);
  });
}
