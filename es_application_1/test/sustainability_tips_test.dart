import 'package:flutter_test/flutter_test.dart';
import '../lib/sustainability_tips.dart';

void main() {
  group('SustainabilityTips Tests', () {
    test('getDailyTip returns a non-empty string', () {
      final tip = SustainabilityTips.getDailyTip();
      expect(tip, isNotEmpty);
    });
  });
}
