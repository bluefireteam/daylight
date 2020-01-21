# Dart Daylight

Get the sunset and sunrise times for a geolocation without having to access any api.

This is a simple implementation of the legendary [Sunset/Sunrise](https://web.archive.org/web/20161202180207/http://williams.best.vwh.net/sunrise_sunset_algorithm.htm) algorithm.

## Usage
```dart
import 'package:daylight/daylight.dart';


final berlin = Location(52.518611, 13.408056);
final berlinCalculator = DaylightCalculator(berlin);
final dailyResults = berlinCalculator.calculateForDay(DateTime.now(), Zenith.astronomical);
print(dailyResults.sunrise); // Some datetime with sunrise hours like 08:32
print(dailyResults.sunset);
print(dailyResults.type); // day type, will probably be sunriseAndSunset if you dont live in svalbard or antartida


double eventHourEpoch = berlinCalculator.calculateEvent(DateTime.now(), Zenith.official, EventType.sunset);
print(DateTime.fromMillisecondsSinceEpoch(eventHourEpoch.floor()));

```
