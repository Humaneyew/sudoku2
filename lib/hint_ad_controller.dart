import 'ads/rewarded_ad_manager.dart';

class HintAdController extends RewardedAdManager {
  HintAdController({
    String adUnitId = _kDefaultHintAdUnitId,
    bool enabled = false,
  }) : super(adUnitId: adUnitId, enabled: enabled);

  static const String _kDefaultHintAdUnitId =
      'ca-app-pub-6446977731818151/3486498295';

  bool get isAdAvailable => super.isAdAvailable;

  void enableForClassicMode(bool enabled) => setEnabled(enabled);
}
