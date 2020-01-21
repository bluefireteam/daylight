library daylight;

import 'dart:math' as math;
import 'package:daylight/season.dart';
import 'package:intl/intl.dart';
import 'package:angles/angles.dart';

enum EventType { sunrise, sunset }

enum DayType { sunriseAndSunset, sunriseOnly, sunsetOnly, allDay, allNight }

extension DayTypeUtils on DayType {
  bool get isNoChange => this == DayType.allDay || this == DayType.allNight;

  bool get hasSunrise =>
      this == DayType.sunriseOnly || this == DayType.sunriseAndSunset;

  bool get hasSunset =>
      this == DayType.sunsetOnly || this == DayType.sunriseAndSunset;
}

enum Zenith {
  astronomical,
  nautical,
  civil,
  official,
  golden,
}

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

class DaylightResult {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime _date;

  DaylightResult(this.sunrise, this.sunset, this._date);

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

class DaylightCalculator {
  final Location location;

  const DaylightCalculator(this.location);

  DaylightResult calculateForDay(DateTime date,
      [Zenith zenith = Zenith.official]) {
    final lastMidnight = new DateTime(date.year, date.month, date.day);

    double sunriseMils = calculateEvent(date, zenith, EventType.sunrise);
    DateTime sunriseDateTime;
    if (sunriseMils != null) {
      int mils = (lastMidnight.millisecondsSinceEpoch + sunriseMils).floor();
      sunriseDateTime = DateTime.fromMillisecondsSinceEpoch(mils);
    }

    double sunsetMils = calculateEvent(date, zenith, EventType.sunset);
    DateTime sunsetDateTime;
    if (sunsetMils != null) {
      int mils = (lastMidnight.millisecondsSinceEpoch + sunsetMils).floor();
      sunsetDateTime = DateTime.fromMillisecondsSinceEpoch(mils, isUtc: false);
    }

    return DaylightResult(sunriseDateTime, sunsetDateTime, date);
  }

  double calculateEvent(DateTime time, Zenith zenith, EventType type) {
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
