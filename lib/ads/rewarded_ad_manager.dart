import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

class RewardedAdManager extends ChangeNotifier {
  RewardedAdManager({
    required this.adUnitId,
    bool enabled = false,
  }) : _enabled = enabled;

  final String adUnitId;

  bool _enabled;
  bool _isLoading = false;
  bool _isShowing = false;
  RewardedAd? _rewardedAd;
  Completer<bool>? _showCompleter;
  bool _rewardEarned = false;
  ScaffoldMessengerState? _activeMessenger;
  String? _fallbackMessage;

  bool get isEnabled => _enabled;

  bool get isAdAvailable =>
      !_enabled ? true : _rewardedAd != null && !_isLoading && !_isShowing;

  Future<bool> showAd(BuildContext context) async {
    if (!_enabled) {
      return true;
    }

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final fallbackMessage =
        l10n?.rewardAdUnavailable ?? 'Ad is not available right now.';

    final ad = _rewardedAd;
    if (ad == null) {
      await preload();
      _showFallbackMessage(messenger, fallbackMessage);
      return false;
    }

    _activeMessenger = messenger;
    _fallbackMessage = fallbackMessage;
    _rewardEarned = false;
    final completer = Completer<bool>();
    _showCompleter = completer;

    try {
      await ad.show(
        onUserEarnedReward: (adWithoutView, reward) {
          _rewardEarned = true;
          onUserEarnedReward(reward);
        },
      );
    } catch (_) {
      _showFallbackMessage(messenger, fallbackMessage);
      _finishAd(ad, rewarded: false);
      return false;
    }

    return completer.future;
  }

  Future<void> preload() async {
    if (!_enabled || _isLoading || _rewardedAd != null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    RewardedAd.load(
      adUnitId: _effectiveAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          _configureAdCallbacks(ad);
          notifyListeners();
          onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          notifyListeners();
          onAdFailedToLoad(error);
        },
      ),
    );
  }

  void setEnabled(bool value) {
    if (_enabled == value) {
      return;
    }
    _enabled = value;
    if (!_enabled) {
      _disposeAd();
    } else {
      unawaited(preload());
    }
    notifyListeners();
  }

  void _configureAdCallbacks(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowing = true;
        notifyListeners();
      },
      onAdDismissedFullScreenContent: (ad) {
        _finishAd(ad, rewarded: _rewardEarned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _showStoredFallbackMessage();
        onAdFailedToShow(error);
        _finishAd(ad, rewarded: false);
      },
    );
  }

  void _finishAd(RewardedAd ad, {required bool rewarded}) {
    ad.dispose();
    if (identical(_rewardedAd, ad)) {
      _rewardedAd = null;
    }
    _isShowing = false;
    _isLoading = false;
    final completer = _showCompleter;
    _showCompleter = null;
    if (_enabled) {
      unawaited(preload());
    }
    notifyListeners();

    if (rewarded) {
      onAdRewardConsumed();
    }

    completer?.complete(rewarded);
    _activeMessenger = null;
    _fallbackMessage = null;
  }

  void _disposeAd() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isLoading = false;
    _isShowing = false;
    _showCompleter?.complete(false);
    _showCompleter = null;
    _activeMessenger = null;
    _fallbackMessage = null;
  }

  void _showFallbackMessage(
    ScaffoldMessengerState messenger,
    String message,
  ) {
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  void _showStoredFallbackMessage() {
    final messenger = _activeMessenger;
    final message = _fallbackMessage;
    if (messenger != null && message != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String get _effectiveAdUnitId =>
      kDebugMode ? RewardedAd.testAdUnitId : adUnitId;

  void onUserEarnedReward(RewardItem reward) {}

  void onAdFailedToLoad(LoadAdError error) {}

  void onAdFailedToShow(AdError error) {}

  void onAdLoaded() {}

  void onAdRewardConsumed() {}

  @override
  void dispose() {
    _disposeAd();
    super.dispose();
  }
}
