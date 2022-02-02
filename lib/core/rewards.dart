import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

int helpCount = 2;

class Rewards {
  final BannerAd myBanner = BannerAd(
    adUnitId: Platform.isAndroid ? 'ca-app-pub-7041305716395438/8678472773' : 'ca-app-pub-7041305716395438/1702000889',
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (ad) => debugPrint('Ad loaded.'),
      // Called when an ad request failed.
      onAdFailedToLoad: (ad, error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        debugPrint('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (ad) => debugPrint('Ad opened.'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (ad) => debugPrint('Ad closed.'),
      // Called when an impression occurs on the ad.
      onAdImpression: (ad) => debugPrint('Ad impression.'),
    ),
  );
  RewardedAd? rewardedAd;
  int numRewardedLoadAttempts = 0;
  
  Rewards() {
    createBannerAd();
    createBannerAd();
  }

  void createBannerAd() {
    myBanner.load();
  }

  void createRewardedAd() {
    RewardedAd.load(
      adUnitId: Platform.isAndroid ? 'ca-app-pub-7041305716395438/4728884824' : 'ca-app-pub-7041305716395438/9351173032',
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
