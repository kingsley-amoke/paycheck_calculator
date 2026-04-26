import '../constants/enums.dart';

String filingStatusToLabel(FilingStatus s) {
  switch (s) {
    case FilingStatus.single:
      return "Single";
    case FilingStatus.marriedJointly:
      return "Jointly";
    case FilingStatus.marriedSeparately:
      return "Separately";
    case FilingStatus.headOfHousehold:
      return "Household";
  }
}

/// Converts a string key from taxConfig to FilingStatus enum
FilingStatus? stringToFilingStatus(String s) {
  switch (s.toLowerCase()) {
    case 'single':
      return FilingStatus.single;
    case 'married_jointly':
      return FilingStatus.marriedJointly;
    case 'married_separately':
      return FilingStatus.marriedSeparately;
    case 'head_of_household':
      return FilingStatus.headOfHousehold;
    default:
      return null;
  }
}
