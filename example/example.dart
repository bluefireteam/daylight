import 'package:intl/intl.dart';
import 'package:daylight/daylight.dart';

void main() {
  const london = const DaylightLocation(51.5072, 0.1276);
  final december = DateTime.utc(2024, 12, 1);

  // Create berlin calculator
  const berlinSunCalculator = const DaylightCalculator(london);

  // calculate for sunrise on civil twilight
  final civilSunrise = berlinSunCalculator.calculateEvent(
    december,
    Zenith.civil,
    EventType.sunrise,
  );

  print((
    "Civil sunrise:",
    civilSunrise?.formatStandard(),
  )); // utc: 07:03:16

  // calculate for sunrise and sunset on astronomical twilight
  final astronomicalEvents = berlinSunCalculator.calculateForDay(
    december,
    Zenith.official,
  );
  print((
    "sunset",
    astronomicalEvents.sunset?.formatStandard(),
  )); // utc: 15:54:09
  print((
    "sunrise",
    astronomicalEvents.sunrise?.formatStandard(),
  )); // utc: 07:42:15
  print(astronomicalEvents.type); // DayType.sunriseAndSunset
}

extension on DateTime {
  String formatStandard() {
    return DateFormat("HH:mm:ss").format(this.toLocal());
  }
}
