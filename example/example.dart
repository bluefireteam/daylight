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
  print(DateFormat("HH:mm:ss").format(civilSunrise)); // utc: 04:58:18

  // calculate for sunrise and sunset on astronomical twilight
  final astronomicalEvents = berlinSunCalculator.calculateForDay(
    october,
    Zenith.astronomical,
  );
  print(
    DateFormat("HH:mm:ss").format(astronomicalEvents.sunset),
  ); // utc: 18:03:55
  print(
    DateFormat("HH:mm:ss").format(astronomicalEvents.sunrise),
  ); // utc: 03:39:09
  print(astronomicalEvents.type); // DayType.sunriseAndSunset
}
