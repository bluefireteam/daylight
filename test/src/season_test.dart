import 'package:daylight/src/season.dart';
import 'package:test/test.dart';

void main() {
  group('SeasonDate', () {
    test('winter', () {
      expect(DateTime(2023, 12, 22), isWinter);
      // ignore: avoid_redundant_argument_values
      expect(DateTime(2023, 1), isWinter);
      expect(DateTime(2023, 2), isWinter);
      expect(DateTime(2023, 3, 20), isWinter);
    });
    test('spring', () {
      expect(DateTime(2023, 3, 21), isSpring);
      expect(DateTime(2023, 4), isSpring);
      expect(DateTime(2023, 5), isSpring);
      expect(DateTime(2023, 6, 20), isSpring);
    });
    test('summer', () {
      expect(DateTime(2023, 6, 21), isSummer);
      expect(DateTime(2023, 7), isSummer);
      expect(DateTime(2023, 8), isSummer);
      expect(DateTime(2023, 9, 21), isSummer);
    });
    test('autumn', () {
      expect(DateTime(2023, 9, 22), isAutumn);
      expect(DateTime(2023, 10), isAutumn);
      expect(DateTime(2023, 11), isAutumn);
      expect(DateTime(2023, 12, 21), isAutumn);
    });
  });
}

Matcher isWinter = SeasonMatcher(Season.winter);
Matcher isSpring = SeasonMatcher(Season.spring);
Matcher isSummer = SeasonMatcher(Season.summer);
Matcher isAutumn = SeasonMatcher(Season.autumn);

class SeasonMatcher extends CustomMatcher {
  SeasonMatcher(Season season)
      : super('SeasonMatcher', 'season', equals(season));

  @override
  Object featureValueOf(dynamic actual) {
    if (actual is DateTime) return actual.seasonNorth;
    throw Exception('Not a DateTime');
  }
}
