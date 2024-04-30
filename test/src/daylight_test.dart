import 'package:daylight/daylight.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

void main() {
  const perth = DaylightLocation(-31.953512, 115.857048);
  const berlin = DaylightLocation(52.518611, 13.408056);
  final july = DateTime.utc(2020, 7, 15);
  final october = DateTime.utc(2020, 10, 15);

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

  group('$Zenith', () {
    test('angle', () {
      expect(Zenith.astronomical.angle, 108.0);
      expect(Zenith.nautical.angle, 102.0);
      expect(Zenith.civil.angle, 96.0);
      expect(Zenith.golden.angle, 86.0);
      expect(Zenith.official.angle, 90.8333);
    });
  });

  group('$DaylightResult', () {
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

    test('equality', () {
      final now = DateTime.now();
      final daylightResult1 = DaylightResult(now, now, july, perth);
      final daylightResult2 = DaylightResult(now, now, july, perth);
      expect(daylightResult1, daylightResult2);
    });
  });

  group('$DaylightCalculator', () {
    group('calculateEvent', () {
      group('sunrise', () {
        const calculator = DaylightCalculator(perth);

        test('official', () {
          final time = calculator.calculateEvent(
            october,
            Zenith.official,
            EventType.sunrise,
          );
          expect(DateFormat('HH:mm:ss').format(time!), '21:37:44'); // UTC
          expect(time.isUtc, true);
        });

        test('nautical', () {
          final time = calculator.calculateEvent(
            october,
            Zenith.nautical,
            EventType.sunrise,
          );
          expect(DateFormat('HH:mm:ss').format(time!), '20:43:26'); // UTC
          expect(time.isUtc, true);
        });

        test('civil', () {
          final time = calculator.calculateEvent(
            october,
            Zenith.civil,
            EventType.sunrise,
          );
          expect(DateFormat('HH:mm:ss').format(time!), '21:12:49'); // UTC
          expect(time.isUtc, true);
        });

        test('astronomical', () {
          final time = calculator.calculateEvent(
            october,
            Zenith.astronomical,
            EventType.sunrise,
          );
          expect(DateFormat('HH:mm:ss').format(time!), '20:13:18'); // UTC
          expect(time.isUtc, true);
        });

        test('golden', () {
          final time = calculator.calculateEvent(
            october,
            Zenith.golden,
            EventType.sunrise,
          );
          expect(DateFormat('HH:mm:ss').format(time!), '22:00:47'); // UTC
          expect(time.isUtc, true);
        });
      });
      group('sunset', () {
        const calculator = DaylightCalculator(berlin);

        test('official', () {
          final time = calculator.calculateEvent(
            july,
            Zenith.official,
            EventType.sunset,
          );
          expect(DateFormat('HH:mm:ss').format(time!), '19:22:51'); // UTC
          expect(time.isUtc, true);
        });

        test('nautical', () {
          final time = calculator.calculateEvent(
            july,
            Zenith.nautical,
            EventType.sunset,
          );
          expect(DateFormat('HH:mm:ss').format(time!), '21:19:18'); // UTC
          expect(time.isUtc, true);
        });

        test('civil', () {
          final time = calculator.calculateEvent(
            july,
            Zenith.civil,
            EventType.sunset,
          );
          expect(DateFormat('HH:mm:ss').format(time!), '20:09:27'); // UTC
          expect(time.isUtc, true);
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
          expect(DateFormat('HH:mm:ss').format(time!), '18:44:13'); // UTC
          expect(time.isUtc, true);
        });
      });
    });

    group('calculateForDay', () {
      test('official', () {
        const calculator = DaylightCalculator(berlin);
        final resultForDay = calculator.calculateForDay(october);

        expect(
          DateFormat('HH:mm:ss').format(resultForDay.sunrise!),
          '05:31:01',
        ); // UTC
        expect(
          DateFormat('HH:mm:ss').format(resultForDay.sunset!),
          '16:12:27',
        ); // UTC
      });
    });
  });

  group('$DaylightLocation', () {
    test('equality', () {
      // ignore: prefer_const_constructors
      expect(berlin, DaylightLocation(52.518611, 13.408056));
    });
  });
}
