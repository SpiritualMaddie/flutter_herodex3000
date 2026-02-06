import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_herodex3000/data/models/appearance_model.dart';

void main() {
  test('should handle malformed height/weight arrays', () {
    // Arrange
      final json = {
        'gender': 'Female',
        'race': 'Human',
        'height': [null, '', 'invalid'],
        'weight': ['invalid', null],
      };

      // Act
      final appearance = AppearanceModel.fromJson(json);

      // Assert
      expect(appearance.height.length, 3);
      expect(appearance.weight.length, 2);
  });
}
