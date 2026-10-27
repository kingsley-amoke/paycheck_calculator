import 'package:firebase_remote_config/firebase_remote_config.dart';

class ReviewAccessService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    await _remoteConfig.setDefaults({'review_access_enabled': false});

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: Duration.zero,
      ),
    );

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (_) {
      // Keep using the cached or default value.
    }
  }

  bool get isEnabled => _remoteConfig.getBool('review_access_enabled');
}
