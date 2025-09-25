import 'ads/rewarded_ad_manager.dart';

class LifeAdController extends RewardedAdManager {
  LifeAdController({
    String adUnitId = _kDefaultLifeAdUnitId,
    bool enabled = false,
  }) : super(adUnitId: adUnitId, enabled: enabled);

  static const String _kDefaultLifeAdUnitId =
      'ca-app-pub-6446977731818151/2236447068';

  void enableForClassicMode(bool enabled) => setEnabled(enabled);
}
