import '../constants/enums.dart';

String payFrequencyLabel(PayFrequency f) {
  switch (f) {
    case PayFrequency.hourly:
      return "Hourly";
    case PayFrequency.weekly:
      return "Weekly";
    case PayFrequency.biWeekly:
      return "Bi-weekly";
    case PayFrequency.monthly:
      return "Monthly";
    case PayFrequency.annually:
      return "Annually";
  }
}
