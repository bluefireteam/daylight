library daylight;

import 'dart:math' as math;
import 'package:daylight/season.dart';
import 'package:intl/intl.dart';
import 'package:angles/angles.dart';

/// Enum that defines in with scope the zenith time will be calculated.
enum EventType { sunrise, sunset }

/// Enum that defines which sun events happens in a specific day
enum DayType { sunriseAndSunset, sunriseOnly, sunsetOnly, allDay, allNight }

/// Extension that adds utility comparison methods into [DayType].
extension DayTypeUtils on DayType {
  /// See if this is a type that indicates no sun events
  bool get isNoChange => this == DayType.allDay || this == DayType.allNight;

  /// Define if [DayType] indicates sunrise.
  bool get hasSunrise =>
      this == DayType.sunriseOnly || this == DayType.sunriseAndSunset;

  /// Define if [DayType] indicates sunset.
  bool get hasSunset =>
      this == DayType.sunsetOnly || this == DayType.sunriseAndSunset;
}

/// Enum that defines the sun position in the event.
///
/// Twilights are divided in three phases: [civil], [nautical] and [astronomical].
/// More info at: https://www.timeanddate.com/astronomy/different-types-twilight.html
/// Added two extra positions: [official], for when the sun is crosses the horizon line and [golden]
/// for when the sun is near the horizon.
enum Zenith { astronomical, nautical, civil, official, golden, _custom }

/// Extension that adds [angle] prop to retrieve angle value (in grads) for a specific [Zenith]
extension ZenithAngle on Zenith {
  double get angle {
    switch (this) {
      case Zenith.astronomical:
        return 108.0;

      case Zenith.nautical:
        return 102.0;

      case Zenith.civil:
        return 96.0;

      case Zenith.golden:
        return 86.0;

      case Zenith.official:
      default:
        return 90.8333;
    }
  }
}

/// Defines a snapshot result for a daylight calculation.
class DaylightResult {
  /// Time of the sunrise
  final DateTime sunrise;

  /// Time of the sunset
  final DateTime sunset;
  final DateTime _date;

  DaylightResult(this.sunrise, this.sunset, this._date);

  /// Define  which sun events happens in the snapshot date
  DayType get type {
    if (sunrise == null) {
      if (sunset == null) {
        final season = _date.getSeason();
        if (season == Season.winter) {
          return DayType.allNight;
        }
        if (season == Season.summer) {
          return DayType.allDay;
        }
        return DayType.sunriseAndSunset;
      }
      return DayType.sunsetOnly;
    }
    if (sunset == null) {
      return DayType.sunriseOnly;
    }
    return DayType.sunriseAndSunset;
  }
}

/// Class that wraps all daylight calculations
class DaylightCalculator {
  /// The specific coordinate location for the calculation.
  final Location location;

  const DaylightCalculator(this.location);

  /// Calculate both sunset and sunrise times for optional [Zenith] and returns in a [DaylightResult]
  DaylightResult calculateForDay(
    DateTime date, [
    Zenith zenith = Zenith.official,
  ]) {
    final sunsetDateTime = calculateEvent(date, zenith, EventType.sunset);
    final sunriseDateTime = calculateEvent(date, zenith, EventType.sunrise);
    return DaylightResult(sunriseDateTime, sunsetDateTime, date);
  }

  /// Calculate the time of an specific sun event
  DateTime calculateEvent(DateTime date, Zenith zenith, EventType type) {
    final lastMidnight = new DateTime(date.year, date.month, date.day);

    double eventMils = _calculate(date, zenith, EventType.sunrise);

    if (eventMils == null) return null;
    int mils = (lastMidnight.millisecondsSinceEpoch + eventMils).floor();
    return DateTime.fromMillisecondsSinceEpoch(mils);
  }

  double _calculate(DateTime time, Zenith zenith, EventType type) {
    double baseLongHour = location.long / 15;

    double hour = _longToHour(time, type == EventType.sunrise ? 6 : 18);

    double meanAnomaly = (0.9856 * hour) - 3.289;

    double sunTrueLong = _sunTrueLong(meanAnomaly);
    double sunRightAsc = _sunRightAsc(sunTrueLong);

    double sunLocalHourCos = _sunLocalHourCos(sunTrueLong, zenith);

    if (type == EventType.sunrise && sunLocalHourCos > 1) {
      return null; // no sunrise
    }
    if (type == EventType.sunset && sunLocalHourCos < -1) {
      return null; // no sunset
    }

    double sunLocalHourAngle = _sunLocalHourAngle(sunLocalHourCos, type);

    double localMeanTime =
        sunLocalHourAngle + sunRightAsc - (0.06571 * hour) - 6.622;

    double utcMeanTime = fixValue(localMeanTime, 0, 24) - baseLongHour;
    double localT = utcMeanTime + time.timeZoneOffset.inHours;

    //return in mils
    return localT * 3600 * 1000;
  }

  double _longToHour(DateTime utc, int offset) {
    double baseLongHour = location.long / 15;
    int dayOfYear = int.parse(DateFormat("D").format(utc));

    double difference = offset - baseLongHour;

    return dayOfYear + (difference / 24);
  }

  double _sunTrueLong(double meanAnomaly) {
    final multiplier = 1.916;
    final degMultiplier = 0.020;
    final addend = 282.634;
    final meanSin = math.sin(degToRad(meanAnomaly));
    final doubleMeanSin = math.sin(degToRad(2 * meanAnomaly));

    return fixValue(meanAnomaly +
        (multiplier * meanSin) +
        (degMultiplier * doubleMeanSin) +
        addend);
  }

  double _sunRightAsc(double sunTrueLong) {
    final rightAsc = fixValue(
        radToDeg(math.atan(0.91764 * math.tan(degToRad(sunTrueLong)))));

    final longQuadrant = ((sunTrueLong / 90).floor() * 90);
    final ascQuadrant = ((rightAsc / 90).floor() * 90);

    return (rightAsc + (longQuadrant - ascQuadrant)) / 15;
  }

  double _sunLocalHourCos(double sunTrueLong, Zenith zenith) {
    // sun declination
    double sinDec = 0.39782 * math.sin(degToRad(sunTrueLong));
    double cosDec = math.cos(math.asin(sinDec));

    double cosZenith = math.cos(degToRad(zenith.angle));
    double sinLat = math.sin(degToRad(location.lat));
    double cosLat = math.cos(degToRad(location.lat));

    return (cosZenith - (sinDec * sinLat)) / (cosDec * cosLat);
  }

  double _sunLocalHourAngle(double sunLocalHourCos, EventType eventType) {
    double acos = radToDeg(math.acos(sunLocalHourCos));
    double acosEvent = eventType == EventType.sunrise ? 360 - acos : acos;

    return acosEvent / 15;
  }
}

double fixValue(double value, [double min = 0, double max = 360]) {
  if (value < min) return value + (max - min);
  if (value >= max) return value - (max - min);
  return value;
}

double radToDeg(double rad) => Angle.fromRadians(rad).degrees;

double degToRad(double deg) => Angle.fromDegrees(deg).radians;

class Location {
  final double lat;
  final double long;

  Location(this.lat, this.long);
}
