import 'dart:math' as math;
import 'package:daylight/src/season.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Enum that defines in with scope the zenith time will be calculated.
enum EventType {
  /// When the sun creeps up from the horizon
  sunrise,

  /// When the sun hides behind the horizon
  sunset,
}

/// Enum that defines which sun events happens in a specific day
enum DayType {
  /// A pretty normal day, with sunrise and sunset
  sunriseAndSunset(
    isNoChange: false,
    hasSunrise: true,
    hasSunset: true,
  ),

  /// A day with only sunrise, no sunset today
  sunriseOnly(
    isNoChange: false,
    hasSunrise: true,
    hasSunset: false,
  ),

  /// A day with only sunset, no sunrise today (winter is coming)
  sunsetOnly(
    isNoChange: false,
    hasSunrise: false,
    hasSunset: true,
  ),

  /// A day with no sun events, the sun is up all day
  allDay(
    isNoChange: true,
    hasSunrise: false,
    hasSunset: false,
  ),

  /// A day with no sun events, the sun is down all day (winter is here)
  allNight(
    isNoChange: true,
    hasSunrise: false,
    hasSunset: false,
  );

  const DayType({
    required this.isNoChange,
    required this.hasSunrise,
    required this.hasSunset,
  });


  /// Whether the day has no sun events
  final bool isNoChange;

  /// Whether the day has sunrise
  final bool hasSunrise;

  /// Whether the day has sunset
  final bool hasSunset;
}


/// Enum that defines the sun position in the event.
///
/// Twilights are divided in three phases: [civil], [nautical] and
/// [astronomical].
/// More info at: https://www.timeanddate.com/astronomy/different-types-twilight.html
///
/// Added two extra positions: [official], for when the sun is crosses the
/// horizon line and [golden] for when the sun is near the horizon.
enum Zenith {
  /// One of the three twilight phases
  astronomical(108),

  /// One of the three twilight phases
  nautical(102),

  /// One of the three twilight phases
  civil(96),

  /// When the sun crosses the horizon line
  official(90.8333),

  /// When the sun is near the horizon
  golden(86);

  const Zenith(this.angle);

  /// Angle value (in grads) for a specific [Zenith].
  final double angle;
}

/// Defines a snapshot result for a daylight calculation.
class DaylightResult extends Equatable {
  /// Creates a new [DaylightResult].
  const DaylightResult(this.sunrise, this.sunset, this.date, this.location);

  /// Time of the sunset in UTC
  final DateTime? sunrise;

  /// Time of the sunset in UTC
  final DateTime? sunset;

  /// The specific coordinate location for the calculation.
  final DaylightLocation location;

  /// The date of the calculation.
  final DateTime date;

  /// Define  which sun events happens in the snapshot date
  DayType get type {
    if (sunrise == null) {
      if (sunset == null) {
        final season = (location.isNorth) ? date.seasonNorth : date.seasonSouth;
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

  @override
  List<Object?> get props => [sunrise, sunset, location, date];
}

/// Class that wraps all daylight calculations
class DaylightCalculator {
  /// Creates a new [DaylightCalculator].
  const DaylightCalculator(this.location);

  /// The specific coordinate location for the calculation.
  final DaylightLocation location;

  /// Calculate both sunset and sunrise
  /// times for optional [Zenith] and returns in a [DaylightResult]
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
    final mils = (lastMidnight.millisecondsSinceEpoch + eventMils).floor();
    return DateTime.fromMillisecondsSinceEpoch(mils, isUtc: true);
  }

  double? _calculate(DateTime time, Zenith zenith, EventType type) {
    final baseLongHour = location.long / 15;

    final hour = _longToHour(time, type == EventType.sunrise ? 6 : 18);

    final meanAnomaly = (0.9856 * hour) - 3.289;

    final sunTrueLong = _sunTrueLong(meanAnomaly);
    final sunRightAsc = _sunRightAsc(sunTrueLong);

    final sunLocalHourCos = _sunLocalHourCos(sunTrueLong, zenith);

    if (sunLocalHourCos < -1.0 || sunLocalHourCos > 1.0) {
      return null; // no event
    }

    final sunLocalHourAngle = _sunLocalHourAngle(sunLocalHourCos, type);

    final localMeanTime =
        sunLocalHourAngle + sunRightAsc - (0.06571 * hour) - 6.622;

    final utcMeanTime = _fixValue(localMeanTime, 0, 24) - baseLongHour;
    final localT = utcMeanTime + time.timeZoneOffset.inHours;

    //return in mils
    return localT * 3600 * 1000;
  }

  double _longToHour(DateTime utc, int offset) {
    final baseLongHour = location.long / 15;
    final dayOfYear = int.parse(DateFormat('D').format(utc));

    final difference = offset - baseLongHour;

    return dayOfYear + (difference / 24);
  }

  double _sunTrueLong(double meanAnomaly) {
    const multiplier = 1.916;
    const degMultiplier = 0.020;
    const addend = 282.634;
    final meanSin = math.sin(_degToRad(meanAnomaly));
    final doubleMeanSin = math.sin(_degToRad(2 * meanAnomaly));

    return _fixValue(
      meanAnomaly +
          (multiplier * meanSin) +
          (degMultiplier * doubleMeanSin) +
          addend,
    );
  }

  double _sunRightAsc(double sunTrueLong) {
    final rightAsc = _fixValue(
      _radToDeg(math.atan(0.91764 * math.tan(_degToRad(sunTrueLong)))),
    );

    final longQuadrant = (sunTrueLong / 90).floor() * 90;
    final ascQuadrant = (rightAsc / 90).floor() * 90;

    return (rightAsc + (longQuadrant - ascQuadrant)) / 15;
  }

  double _sunLocalHourCos(double sunTrueLong, Zenith zenith) {
    // sun declination
    final sinDec = 0.39782 * math.sin(_degToRad(sunTrueLong));
    final cosDec = math.cos(math.asin(sinDec));

    final cosZenith = math.cos(_degToRad(zenith.angle));
    final sinLat = math.sin(_degToRad(location.lat));
    final cosLat = math.cos(_degToRad(location.lat));

    return (cosZenith - (sinDec * sinLat)) / (cosDec * cosLat);
  }

  double _sunLocalHourAngle(double sunLocalHourCos, EventType eventType) {
    final acos = _radToDeg(math.acos(sunLocalHourCos));
    final acosEvent = eventType == EventType.sunrise ? 360 - acos : acos;

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

double _radToDeg(double rad) {
  return rad * 180 / math.pi;
}

double _degToRad(double deg) {
  return deg * math.pi / 180;
}

/// Simple wrapper class for storing the geographical coordinates of a
/// specific location.
class DaylightLocation extends Equatable {
  /// Creates a new [DaylightLocation].
  const DaylightLocation(this.lat, this.long);

  /// The latitude of the location.
  final double lat;

  /// The longitude of the location.
  final double long;

  /// Returns `true` if the location is in the northern hemisphere.
  bool get isNorth => lat > 0;

  @override
  List<Object?> get props => [lat, long];
}
