import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

int helpCount = 2;

class Rewards {
  RewardedAd? rewardedAd;
  int numRewardedLoadAttempts = 0;
  Rewards();

  void createRewardedAd() {
    RewardedAd.load(
      adUnitId: RewardedAd.testAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          numRewardedLoadAttempts = 0;
          rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          rewardedAd = null;
          numRewardedLoadAttempts += 1;
          if (numRewardedLoadAttempts <= 10) {
            createRewardedAd();
          }
        },
      ),
    );
  }

  void showRewardedAd(VoidCallback onRewarded) {
    if (rewardedAd == null) {
      debugPrint('Warning: attempt to show rewarded before loaded.');
      createRewardedAd();
      return;
    }
    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createRewardedAd();
      },
    );

    rewardedAd!.setImmersiveMode(true);
    rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      debugPrint('$ad with reward $RewardItem(${reward.amount}, ${reward.type}');
      helpCount += 2;
      onRewarded();
    });
    rewardedAd = null;
  }
}
