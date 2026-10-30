/// Destination configuration for the separate Expense Tracker app.
///
/// Neither the Android package id nor an official store listing URL is
/// present anywhere in this codebase — per spec, they must NOT be invented.
/// TODO(dev): supply [storeUrl] (or a deep-link/package id once a supported
/// app-to-app integration is defined) before shipping the budget entry point.
/// While null, the settings tile falls back to an explanatory dialog and the
/// app works normally without the Expense Tracker.
class ExpenseTrackerConfig {
  static const String? androidPackageId =
      "com.smoqdev.expense_tracker_scan_receipt";
  static const String? storeUrl =
      "https://play.google.com/store/apps/details?id=com.smoqdev.expense_tracker_scan_receipt";

  /// Test-only override for the unconfigured case.
  static String? storeUrlOverride;

  static bool get isConfigured => storeUrlOverride != null || storeUrl != null;

  static String? get effectiveStoreUrl => storeUrlOverride ?? storeUrl;
}
