import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class UndoAdController extends ChangeNotifier {
  UndoAdController({bool? integrationEnabled, String? adUnitId})
    : _integrationEnabled =
          integrationEnabled ??
          const bool.fromEnvironment('enableUndoAd', defaultValue: true),
      _adUnitId = adUnitId ?? _kDefaultAdUnitId {
    if (useAdFlow) {
      unawaited(_loadAd());
    }
  }

  static const String _kDefaultAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  final bool _integrationEnabled;
  final String _adUnitId;

  RewardedAd? _rewardedAd;
  Future<bool>? _loadingAd;
  Future<bool>? _pendingAd;
  bool _showingAd = false;

  bool get useAdFlow {
    if (!_integrationEnabled) {
      return false;
    }
    if (kIsWeb) {
      return false;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      default:
        return false;
    }
  }

  bool get isAdAvailable =>
      !useAdFlow ? true : _rewardedAd != null && !_showingAd;

  Future<bool> showAd(BuildContext _) {
    if (!useAdFlow) {
      return Future.value(true);
    }
    if (_pendingAd != null) {
      return _pendingAd!;
    }

    final future = _performShowAd();
    _pendingAd = future;
    future.whenComplete(() {
      _pendingAd = null;
    });
    return future;
  }

  Future<bool> _performShowAd() async {
    final loaded = await _ensureAdLoaded();
    if (!loaded) {
      return false;
    }
    final ad = _rewardedAd;
    if (ad == null) {
      return false;
    }

    bool rewardEarned = false;
    final completer = Completer<bool>();

    _showingAd = true;
    notifyListeners();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        _handleAdClosed(ad, rewardEarned, completer);
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        _handleAdFailedToShow(ad, completer);
      },
    );

    try {
      ad.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          rewardEarned = true;
        },
      );
    } on Object {
      _handleAdFailedToShow(ad, completer);
    }

    return completer.future;
  }

  Future<bool> _ensureAdLoaded() async {
    if (!useAdFlow) {
      return true;
    }
    if (_rewardedAd != null) {
      return true;
    }
    if (_loadingAd != null) {
      return _loadingAd!;
    }
    return _loadAd();
  }

  Future<bool> _loadAd() {
    final completer = Completer<bool>();
    _loadingAd = completer.future;

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _loadingAd = null;
          notifyListeners();
          completer.complete(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _loadingAd = null;
          notifyListeners();
          completer.complete(false);
        },
      ),
    );

    return completer.future;
  }

  void _handleAdClosed(
    RewardedAd ad,
    bool rewardEarned,
    Completer<bool> completer,
  ) {
    _showingAd = false;
    ad.dispose();
    _rewardedAd = null;
    notifyListeners();
    if (useAdFlow) {
      unawaited(_loadAd());
    }
    if (!completer.isCompleted) {
      completer.complete(rewardEarned);
    }
  }

  void _handleAdFailedToShow(RewardedAd ad, Completer<bool> completer) {
    _showingAd = false;
    ad.dispose();
    _rewardedAd = null;
    notifyListeners();
    if (useAdFlow) {
      unawaited(_loadAd());
    }
    if (!completer.isCompleted) {
      completer.complete(false);
    }
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }
}
