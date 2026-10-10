import 'package:flutter_test/flutter_test.dart';
import 'package:fitpastel/core/utils/plate_calculator.dart';

void main() {
  group('PlateCalculator Tests', () {
    test('Calculates plates correctly for 60kg Olympic Bar (20kg)', () {
      final result = PlateCalculator.calculate(
        targetWeight: 60.0,
        barWeight: 20.0,
      );

      expect(result.weightPerSide, 20.0);
      expect(result.totalWeight, 60.0);
      expect(result.platesPerSide[20.0], 1);
      expect(result.hasRemainingWeight, false);
      expect(result.remainingWeight, 0.0);
    });

    test('Calculates plates correctly for 100kg Olympic Bar (20kg)', () {
      // 100 - 20 = 80 total plate weight => 40kg per side
      // 40kg = 1x25kg + 1x15kg
      final result = PlateCalculator.calculate(
        targetWeight: 100.0,
        barWeight: 20.0,
      );

      expect(result.weightPerSide, 40.0);
      expect(result.platesPerSide[25.0], 1);
      expect(result.platesPerSide[15.0], 1);
      expect(result.hasRemainingWeight, false);
    });

    test('Calculates plates correctly for EZ Curl Bar (10kg) targeting 30kg', () {
      // 30 - 10 = 20 total plate weight => 10kg per side
      final result = PlateCalculator.calculate(
        targetWeight: 30.0,
        barWeight: 10.0,
      );

      expect(result.weightPerSide, 10.0);
      expect(result.platesPerSide[10.0], 1);
      expect(result.hasRemainingWeight, false);
    });

    test('Returns empty plates when target weight equals bar weight', () {
      final result = PlateCalculator.calculate(
        targetWeight: 20.0,
        barWeight: 20.0,
      );

      expect(result.weightPerSide, 0.0);
      expect(result.platesPerSide.isEmpty, true);
      expect(result.hasRemainingWeight, false);
    });

    test('Handles non-standard weights with remainder', () {
      // 53kg target with 20kg bar => 33kg total => 16.5kg per side
      // 16.5kg = 1x15kg + 1x1.25kg = 16.25kg, remainder 0.25kg
      final result = PlateCalculator.calculate(
        targetWeight: 53.0,
        barWeight: 20.0,
      );

      expect(result.weightPerSide, 16.5);
      expect(result.platesPerSide[15.0], 1);
      expect(result.platesPerSide[1.25], 1);
      expect(result.hasRemainingWeight, true);
      expect(result.remainingWeight, closeTo(0.25, 0.001));
    });
  });
}
