/// Enum representing the seasons
enum Season {
  /// Winter
  winter,

  /// Spring
  spring,

  /// Summer
  summer,

  /// Autumn
  autumn,
}

/// Extension on [DateTime] to get the season
extension SeasonDate on DateTime {
  /// Retrieves the season for the current datetime instance
  Season get seasonNorth {
    switch (month) {
      case 1 || 2:
        return Season.winter;
      case 3 :
        return day < 21 ? Season.winter : Season.spring;
      case 4 || 5:
        return Season.spring;
      case 6:
        return day < 21 ? Season.spring : Season.summer;
      case 7 || 8:
        return Season.summer;
      case 9:
        return day < 22 ? Season.summer : Season.autumn;
      case 10 || 11:
        return Season.autumn;
      case 12:
        return day < 22 ? Season.autumn : Season.winter;
      default:
        throw ArgumentError('This month does not exist #$month.');
    }
  }

  /// Retrieves the season for the current datetime instance
  Season get seasonSouth => seasonNorth.inverse;
}

extension on Season {
  Season get inverse => Season.values[(index + 2) % 4];
}
