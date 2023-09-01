# Daylight

[![Pub](https://img.shields.io/pub/v/daylight.svg?style=popout)](https://pub.dartlang.org/packages/daylight)
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

Get the sunset and sunrise times for a geolocation without having to access any remote api.

This is a simple implementation of the legendary [Sunset/Sunrise](https://web.archive.org/web/20161202180207/http://williams.best.vwh.net/sunrise_sunset_algorithm.htm) algorithm.

## Installation 💻

**❗ In order to start using Daylight you must have the [Dart SDK][dart_install_link] installed on your machine.**

Add `daylight` to your `pubspec.yaml`:

```yaml
dependencies:
  daylight:
```

Install it:

```sh
dart pub get
```

---

## Usage 📖


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


## Running Tests 🧪

To run all unit tests:

```sh
dart pub global activate coverage 1.2.0
dart test --coverage=coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
open coverage/index.html
```

[dart_install_link]: https://dart.dev/get-dart
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
