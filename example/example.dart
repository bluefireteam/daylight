import 'package:intl/intl.dart';
import 'package:daylight/daylight.dart';

void main() {
  const berlin = const DaylightLocation(52.518611, 13.408056);
  final october = DateTime(2020, 10, 15);

  // Create berlin calculator
  const berlinSunCalculator = const DaylightCalculator(berlin);

  // calculate for sunrise on civil twilight
  final civilSunrise = berlinSunCalculator.calculateEvent(
    october,
    Zenith.civil,
    EventType.sunrise,
  );

  print(civilSunrise?.formatStandard()); // utc: 04:58:18

  // calculate for sunrise and sunset on astronomical twilight
  final astronomicalEvents = berlinSunCalculator.calculateForDay(
    october,
    Zenith.astronomical,
  );
  print(astronomicalEvents.sunset?.formatStandard()); // utc: 18:03:55
  print(astronomicalEvents.sunrise?.formatStandard()); // utc: 03:39:09
  print(astronomicalEvents.type); // DayType.sunriseAndSunset
}

extension on DateTime {
  String formatStandard() {
    return DateFormat("HH:mm:ss").format(this);
  }
}
