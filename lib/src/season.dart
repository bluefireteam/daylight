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
      case DateTime.january || DateTime.february:
        return Season.winter;
      case DateTime.march:
        return day < 21 ? Season.winter : Season.spring;
      case DateTime.april || DateTime.may:
        return Season.spring;
      case DateTime.june:
        return day < 21 ? Season.spring : Season.summer;
      case DateTime.july || DateTime.august:
        return Season.summer;
      case DateTime.september:
        return day < 22 ? Season.summer : Season.autumn;
      case DateTime.october || DateTime.november:
        return Season.autumn;
      case DateTime.december:
        return day < 22 ? Season.autumn : Season.winter;
    }
    throw Exception('Invalid date');
  }

  /// Retrieves the season for the current datetime instance
  Season get seasonSouth => seasonNorth.inverse;
}

extension on Season {
  Season get inverse => Season.values[(index + 2) % 4];
}
