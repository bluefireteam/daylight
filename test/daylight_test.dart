import 'package:intl/intl.dart';
import 'package:daylight/daylight.dart';
import 'package:test/test.dart';

void main() {
  const perth = const DaylightLocation(-31.953512, 115.857048);
  const berlin = const DaylightLocation(52.518611, 13.408056);
  final july = DateTime(2020, 7, 15);
  final october = DateTime(2020, 10, 15);
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
          final daylightResult =
              DaylightResult(DateTime.now(), DateTime.now(), july, perth);
          expect(daylightResult.type, DayType.sunriseAndSunset);
        });

        test('sunriseOnly', () {
          final daylightResult =
              DaylightResult(DateTime.now(), null, july, perth);
          expect(daylightResult.type, DayType.sunriseOnly);
        });

        test('sunsetOnly', () {
          final daylightResult =
              DaylightResult(null, DateTime.now(), july, perth);
          expect(daylightResult.type, DayType.sunsetOnly);
        });

        test('allDay south', () {
          final daylightResult = DaylightResult(null, null, october, perth);
          expect(daylightResult.type, DayType.allDay);
        });

        test('allDay north', () {
          final daylightResult = DaylightResult(null, null, july, berlin);
          expect(daylightResult.type, DayType.allDay);
        });

        test('allNight south', () {
          final daylightResult = DaylightResult(null, null, july, perth);
          expect(daylightResult.type, DayType.allNight);
        });

        test('allNight north', () {
          final daylightResult = DaylightResult(null, null, october, berlin);
          expect(daylightResult.type, DayType.allNight);
        });
      });
    });
    group('DaylightCalculator', () {
      group('calculateEvent', () {
        group('sunrise', () {
          const calculator = const DaylightCalculator(perth);
          test('official', () {
            final time = calculator.calculateEvent(
              october,
              Zenith.official,
              EventType.sunrise,
            );
            expect(DateFormat("HH:mm:ss").format(time), "22:36:33"); // UTC
          });
          test('nautical', () {
            final time = calculator.calculateEvent(
              october,
              Zenith.nautical,
              EventType.sunrise,
            );
            expect(DateFormat("HH:mm:ss").format(time), "21:42:09"); // UTC
          });
          test('civil', () {
            final time = calculator.calculateEvent(
              october,
              Zenith.civil,
              EventType.sunrise,
            );
            expect(DateFormat("HH:mm:ss").format(time), "22:11:36"); // UTC
          });
          test('astronomical', () {
            final time = calculator.calculateEvent(
              october,
              Zenith.astronomical,
              EventType.sunrise,
            );
            expect(DateFormat("HH:mm:ss").format(time), "21:11:56"); // UTC
          });
          test('golden', () {
            final time = calculator.calculateEvent(
              october,
              Zenith.golden,
              EventType.sunrise,
            );
            expect(DateFormat("HH:mm:ss").format(time), "22:59:38"); // UTC
          });
        });
        group('sunset', () {
          const calculator = const DaylightCalculator(berlin);
          test('official', () {
            final time = calculator.calculateEvent(
              july,
              Zenith.official,
              EventType.sunset,
            );
            expect(DateFormat("HH:mm:ss").format(time), "20:21:47"); // UTC
          });
          test('nautical', () {
            final time = calculator.calculateEvent(
              july,
              Zenith.nautical,
              EventType.sunset,
            );
            expect(DateFormat("HH:mm:ss").format(time), "22:17:10"); // UTC
          });
          test('civil', () {
            final time =
                calculator.calculateEvent(july, Zenith.civil, EventType.sunset);
            expect(DateFormat("HH:mm:ss").format(time), "21:08:08"); // UTC
          });
          test('astronomical', () {
            final time = calculator.calculateEvent(
              july,
              Zenith.astronomical,
              EventType.sunset,
            );
            expect(time, null); // UTC
          });
          test('golden', () {
            final time = calculator.calculateEvent(
              july,
              Zenith.golden,
              EventType.sunset,
            );
            expect(DateFormat("HH:mm:ss").format(time), "19:43:17"); // UTC
          });
        });
      });

      group('calculateForDay', () {
        test('official', () {
          const calculator = const DaylightCalculator(berlin);
          final resultForDay = calculator.calculateForDay(october);

          expect(
            DateFormat("HH:mm:ss").format(resultForDay.sunrise),
            "06:32:48",
          ); // UTC
          expect(
            DateFormat("HH:mm:ss").format(resultForDay.sunset),
            "17:10:14",
          ); // UTC
        });
      });
    });
  });
}
