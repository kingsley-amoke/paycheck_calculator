class HourlyConverter {
  static double toWeekly(double hourly, double hoursPerWeek) {
    return hourly * hoursPerWeek;
  }

  static double toMonthly(double hourly, double hoursPerWeek) {
    return hourly * hoursPerWeek * 52 / 12;
  }

  static double toAnnual(double hourly, double hoursPerWeek) {
    return hourly * hoursPerWeek * 52;
  }
}