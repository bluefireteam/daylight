/// Enum representing the seasons
enum Season {
  winter,
  spring,
  summer,
  autumn,
}

extension InverseSeason on Season {
  Season get inverse => Season.values[(index + 2) % 4];
}

extension SeasonDate on DateTime {
  /// Retrieves the season for the current datetime instance
  Season get seasonNorth {
    switch (month) {
      case 1:
      case 2:
        return Season.winter;
      case 3:
        return day < 21 ? Season.winter : Season.spring;
      case 4:
      case 5:
        return Season.spring;
      case 6:
        return day < 21 ? Season.spring : Season.summer;
      case 7:
      case 8:
        return Season.summer;
      case 9:
        return day < 22 ? Season.autumn : Season.summer;
      case 10:
      case 11:
        return Season.autumn;
      case 12:
        return day < 22 ? Season.autumn : Season.winter;
      default:
        throw ArgumentError('This month doesnt exist #$month.');
    }
  }

  Season get seasonSouth => seasonNorth.inverse;
}
