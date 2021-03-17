library daylight;

import 'dart:math' as math;
import 'package:daylight/src/season.dart';
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
enum Zenith { astronomical, nautical, civil, official, golden }

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
  DaylightResult(this.sunrise, this.sunset, this._date, this.location);

  /// Time of the sunset in UTC
  final DateTime? sunrise;

  /// Time of the sunset in UTC
  final DateTime? sunset;

  final DaylightLocation location;

  final DateTime _date;

  /// Define  which sun events happens in the snapshot date
  DayType get type {
    if (sunrise == null) {
      if (sunset == null) {
        final season =
            (location.isNorth) ? _date.seasonNorth : _date.seasonSouth;
        if (season == Season.winter || season == Season.autumn) {
          return DayType.allNight;
        }
        return DayType.allDay;
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
  const DaylightCalculator(this.location);

  /// The specific coordinate location for the calculation.
  final DaylightLocation location;

  /// Calculate both sunset and sunrise times for optional [Zenith] and returns in a [DaylightResult]
  ///
  /// Dates are UTC.
  DaylightResult calculateForDay(
    DateTime date, [
    Zenith zenith = Zenith.official,
  ]) {
    final sunsetDateTime = calculateEvent(date, zenith, EventType.sunset);
    final sunriseDateTime = calculateEvent(date, zenith, EventType.sunrise);
    return DaylightResult(sunriseDateTime, sunsetDateTime, date, location);
  }

  /// Calculate the time of an specific sun event
  ///
  /// Returns in UTC.
  DateTime? calculateEvent(DateTime date, Zenith zenith, EventType type) {
    final lastMidnight = DateTime(date.year, date.month, date.day);

    final eventMils = _calculate(date, zenith, type);
    if (eventMils == null) {
      return null;
    }
    final int mils = (lastMidnight.millisecondsSinceEpoch + eventMils).floor();
    return DateTime.fromMillisecondsSinceEpoch(mils, isUtc: true);
  }

  double? _calculate(DateTime time, Zenith zenith, EventType type) {
    final double baseLongHour = location.long / 15;

    final double hour = _longToHour(time, type == EventType.sunrise ? 6 : 18);

    final double meanAnomaly = (0.9856 * hour) - 3.289;

    final double sunTrueLong = _sunTrueLong(meanAnomaly);
    final double sunRightAsc = _sunRightAsc(sunTrueLong);

    final double sunLocalHourCos = _sunLocalHourCos(sunTrueLong, zenith);

    if (sunLocalHourCos < -1.0 || sunLocalHourCos > 1.0) {
      return null; // no event
    }

    final double sunLocalHourAngle = _sunLocalHourAngle(sunLocalHourCos, type);

    final double localMeanTime =
        sunLocalHourAngle + sunRightAsc - (0.06571 * hour) - 6.622;

    final double utcMeanTime = _fixValue(localMeanTime, 0, 24) - baseLongHour;
    final double localT = utcMeanTime + time.timeZoneOffset.inHours;

    //return in mils
    return localT * 3600 * 1000;
  }

  double _longToHour(DateTime utc, int offset) {
    final double baseLongHour = location.long / 15;
    final int dayOfYear = int.parse(DateFormat("D").format(utc));

    final double difference = offset - baseLongHour;

    return dayOfYear + (difference / 24);
  }

  double _sunTrueLong(double meanAnomaly) {
    const multiplier = 1.916;
    const degMultiplier = 0.020;
    const addend = 282.634;
    final meanSin = math.sin(_degToRad(meanAnomaly));
    final doubleMeanSin = math.sin(_degToRad(2 * meanAnomaly));

    return _fixValue(meanAnomaly +
        (multiplier * meanSin) +
        (degMultiplier * doubleMeanSin) +
        addend);
  }

  double _sunRightAsc(double sunTrueLong) {
    final rightAsc = _fixValue(
        _radToDeg(math.atan(0.91764 * math.tan(_degToRad(sunTrueLong)))));

    final longQuadrant = (sunTrueLong / 90).floor() * 90;
    final ascQuadrant = (rightAsc / 90).floor() * 90;

    return (rightAsc + (longQuadrant - ascQuadrant)) / 15;
  }

  double _sunLocalHourCos(double sunTrueLong, Zenith zenith) {
    // sun declination
    final double sinDec = 0.39782 * math.sin(_degToRad(sunTrueLong));
    final double cosDec = math.cos(math.asin(sinDec));

    final double cosZenith = math.cos(_degToRad(zenith.angle));
    final double sinLat = math.sin(_degToRad(location.lat));
    final double cosLat = math.cos(_degToRad(location.lat));

    return (cosZenith - (sinDec * sinLat)) / (cosDec * cosLat);
  }

  double _sunLocalHourAngle(double sunLocalHourCos, EventType eventType) {
    final double acos = _radToDeg(math.acos(sunLocalHourCos));
    final double acosEvent = eventType == EventType.sunrise ? 360 - acos : acos;

    return acosEvent / 15;
  }
}

double _fixValue(double value, [double min = 0, double max = 360]) {
  if (value < min) {
    return value + (max - min);
  }
  if (value >= max) {
    return value - (max - min);
  }
  return value;
}

double _radToDeg(double rad) => Angle.fromRadians(rad).degrees;

double _degToRad(double deg) => Angle.fromDegrees(deg).radians;

/// Simple wrapper class for storing the geographical coordinates of a specific location.
class DaylightLocation {
  const DaylightLocation(this.lat, this.long);

  final double lat;
  final double long;

  bool get isNorth => lat > 0;
}
