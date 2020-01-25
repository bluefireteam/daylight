import 'package:daylight/daylight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const perth = const Location(-31.953512, 115.857048);
  const berlin = const Location(52.518611, 13.408056);
  group('Daylight', () {
    group('DayTypeUtils', () {
      test('isNoChange', () {
        expect(DayType.sunriseAndSunset.isNoChange, false);
        expect(DayType.allDay.isNoChange, true);
        expect(DayType.allNight.isNoChange, true);
      });
      test('hasSunrise', () {
        expect(DayType.sunsetOnly.hasSunrise, false);
        expect(DayType.sunriseOnly.hasSunrise, true);
        expect(DayType.sunriseAndSunset.hasSunrise, true);
      });
      test('hasSunset', () {
        expect(DayType.allDay.hasSunset, false);
        expect(DayType.sunsetOnly.hasSunset, true);
        expect(DayType.sunriseAndSunset.hasSunset, true);
      });
    });
    group('ZenithAngle', () {
      test('angle', () {
        expect(Zenith.astronomical.angle, 108.0);
        expect(Zenith.nautical.angle, 102.0);
        expect(Zenith.civil.angle, 96.0);
        expect(Zenith.golden.angle, 86.0);
        expect(Zenith.official.angle, 90.8333);
      });
    });

    group('DaylightResult', () {
      group('type', () {
        test('sunriseAndSunset', () {

        });
      });
    });
  });
}
