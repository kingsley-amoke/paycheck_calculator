import 'package:hive/hive.dart';

/// Hive bootstrap for calculation profiles. Boxes store JSON maps keyed by
/// profile id — no TypeAdapters, tolerant to schema evolution.
class LocalStorageService {
  static const String profilesBoxName = 'calculation_profiles';
  static const String stateBoxName = 'app_state';
  static const String activeProfileKey = 'active_profile_id';

  /// Set once onboarding completes; onboarding shows again only when unset.
  static const String onboardingCompleteKey = 'onboarding_complete';

  static Future<Box<Map>> openProfilesBox() =>
      Hive.openBox<Map>(profilesBoxName);

  static Future<Box> openStateBox() => Hive.openBox(stateBoxName);
}
