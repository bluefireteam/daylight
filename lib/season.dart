enum Season {
  winter,
  spring,
  summer,
  autumn,
}

// Credits to: https://github.com/flutter/samples/blob/master/veggieseasons/lib/data/app_state.dart#L44
extension SeasonDate on DateTime {
  Season getSeason() {
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
        return day < 22 ? Season.autumn : Season.winter;
      case 10:
      case 11:
        return Season.autumn;
      case 12:
        return day < 22 ? Season.autumn : Season.winter;
      default:
        throw ArgumentError('Can\'t return a season for month #${month}.');
    }
  }
}
