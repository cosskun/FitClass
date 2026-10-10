class PlateCalculationResult {
  final double targetWeight;
  final double barWeight;
  final double weightPerSide;
  final Map<double, int> platesPerSide;
  final double remainingWeight;

  PlateCalculationResult({
    required this.targetWeight,
    required this.barWeight,
    required this.weightPerSide,
    required this.platesPerSide,
    this.remainingWeight = 0.0,
  });

  bool get hasRemainingWeight => remainingWeight > 0.001;
  double get totalWeight => targetWeight;
}

class PlateCalculator {
  static const List<double> standardPlates = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25];

  /// Calculates the plates needed for each side of a barbell given total target weight and barbell weight.
  static PlateCalculationResult calculate({
    required double targetWeight,
    required double barWeight,
    List<double>? availablePlates,
  }) {
    final platesList = availablePlates ?? standardPlates;
    final double weightPerSide = (targetWeight - barWeight) > 0 ? (targetWeight - barWeight) / 2 : 0.0;
    
    final Map<double, int> neededPlates = {};
    double remainingSideWeight = weightPerSide;

    for (final plate in platesList) {
      if (remainingSideWeight >= plate) {
        final count = (remainingSideWeight / plate).floor();
        if (count > 0) {
          neededPlates[plate] = count;
          remainingSideWeight -= count * plate;
        }
      }
    }

    return PlateCalculationResult(
      targetWeight: targetWeight,
      barWeight: barWeight,
      weightPerSide: weightPerSide,
      platesPerSide: neededPlates,
      remainingWeight: remainingSideWeight,
    );
  }
}
