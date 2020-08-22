# Dart Daylight

[![Pub](https://img.shields.io/pub/v/daylight.svg?style=popout)](https://pub.dartlang.org/packages/daylight)
[![Tests status](https://img.shields.io/github/workflow/status/renancaraujo/daylight/Test/master?label=tests)](https://github.com/renancaraujo/daylight/actions)

Get the sunset and sunrise times for a geolocation without having to access any api.

This is a simple implementation of the legendary [Sunset/Sunrise](https://web.archive.org/web/20161202180207/http://williams.best.vwh.net/sunrise_sunset_algorithm.htm) algorithm.

## Usage

Check the API [docs](https://pub.dev/documentation/daylight/latest/), [example](https://github.com/renancaraujo/daylight/blob/master/example/example.dart) and [tests](https://github.com/renancaraujo/daylight/blob/master/test/daylight_test.dart) for more information about how to use it. 

```dart
import 'package:daylight/daylight.dart';


final berlin = DaylightLocation(52.518611, 13.408056);
final berlinCalculator = DaylightCalculator(berlin);
final dailyResults = berlinCalculator.calculateForDay(DateTime.now(), Zenith.astronomical);
print(dailyResults.sunrise); // Some UTC datetime with sunrise hours like 08:32
print(dailyResults.sunset);
print(dailyResults.type); // day type, will probably be sunriseAndSunset if you dont live near the poles


double eventHourEpoch = berlinCalculator.calculateEvent(DateTime.now(), Zenith.official, EventType.sunset);
print(DateTime.fromMillisecondsSinceEpoch(eventHourEpoch.floor()));

```
