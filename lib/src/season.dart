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
    return switch (month) {
      DateTime.january || DateTime.february => Season.winter,
      DateTime.march => day < 21 ? Season.winter : Season.spring,
      DateTime.april || DateTime.may => Season.spring,
      DateTime.june => day < 21 ? Season.spring : Season.summer,
      DateTime.july || DateTime.august => Season.summer,
      DateTime.september => day < 22 ? Season.summer : Season.autumn,
      DateTime.october || DateTime.november => Season.autumn,
      DateTime.december => day < 22 ? Season.autumn : Season.winter,
      _ => throw Exception('Invalid month $month'),
    };
  }

  /// Retrieves the season for the current datetime instance
  Season get seasonSouth => seasonNorth.inverse;
}

extension on Season {
  Season get inverse => Season.values[(index + 2) % 4];
}
