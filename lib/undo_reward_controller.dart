import 'package:flutter/material.dart';

import 'ads/rewarded_ad_manager.dart';

class UndoRewardController extends RewardedAdManager {
  UndoRewardController({
    String adUnitId = _kDefaultUndoAdUnitId,
    bool enabled = false,
  }) : super(adUnitId: adUnitId, enabled: enabled);

  static const String _kDefaultUndoAdUnitId =
      'ca-app-pub-6446977731818151/8662254615';

  bool get isRewardEnabled => isEnabled;
  bool get isRewardAvailable => super.isAdAvailable;

  void enableForClassicMode(bool enabled) => setEnabled(enabled);

  Future<bool> showReward(BuildContext context) => showAd(context);
}
