/// Centralized feature-access rules for the expansion features.
/// Single source of truth — UI must not scatter hard-coded subscription
/// checks. Saved data is never hidden when a subscription lapses: limits
/// only gate *adding new* items.
class FeatureAccess {
  static const int freeProfileLimit = 1;
  static const int freeItemLimit = 2;

  static bool canAddProfile(int existingCount, bool hasAccess) =>
      hasAccess || existingCount < freeProfileLimit;

  static bool canAddItem(int existingCount, bool hasAccess) =>
      hasAccess || existingCount < freeItemLimit;

  static bool canCompare(bool hasAccess) => hasAccess;

  static bool canProject(bool hasAccess) => hasAccess;
}
