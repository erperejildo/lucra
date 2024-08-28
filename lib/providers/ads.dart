import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final adBannerId =
    Platform.isAndroid ? 'ca-app-pub-2945024608555072/2259823523' : '';
final adInterstitialId =
    Platform.isAndroid ? 'ca-app-pub-2945024608555072/9563598473' : '';
final adRewardedId =
    Platform.isAndroid ? 'ca-app-pub-2945024608555072/1221695678' : '';
const int maxFailedLoadAttempts = 3;

class Ads extends ChangeNotifier {
  bool showingAds = true;
  BannerAd? adBanner;
  InterstitialAd? interstitialAd;
  bool isBannerReady = false;
  bool isInterstitialReady = false;
  int numInterstitialLoadAttempts = 0;

  Ads() {
    initAds();
  }

  Future<void> initAds() async {
    await MobileAds.instance.initialize();
  }

  void hideShowAds(bool show) {
    showingAds = false;
    if (showingAds) {
      // loadBanner();
      loadInterstitial(true);
    } else {
      disposeAds();
    }
    notifyListeners();
  }

  void loadBanner() {
    adBanner = BannerAd(
      adUnitId: adBannerId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerReady = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, err) {
          isBannerReady = false;
          ad.dispose();
        },
        onAdClosed: (Ad ad) {
          isBannerReady = false;
          ad.dispose();
        },
      ),
    )..load();
  }

  void loadInterstitial([bool show = false]) {
    InterstitialAd.load(
      adUnitId: adInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          interstitialAd = ad;
          numInterstitialLoadAttempts = 0;
          interstitialAd!.setImmersiveMode(true);
          if (show) showInterstitialAd();
        },
        onAdFailedToLoad: (LoadAdError error) {
          numInterstitialLoadAttempts += 1;
          interstitialAd = null;
          if (numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            loadInterstitial();
          }
        },
      ),
    );
  }

  showBanner() {
    if (isBannerReady == false) return Container();

    return SizedBox(
      width: adBanner!.size.width.toDouble(),
      height: adBanner!.size.height.toDouble(),
      child: AdWidget(ad: adBanner!),
    );
  }

  Future<void> showInterstitialAd() async {
    if (!showingAds || interstitialAd == null) {
      return;
    }

    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {},
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        loadInterstitial();
      },
    );
    await interstitialAd!.show();
    interstitialAd = null;
  }

  @override
  void dispose() {
    disposeAds();
    super.dispose();
  }

  void disposeAds() {
    adBanner?.dispose();
    adBanner = null;
    isBannerReady = false;
    interstitialAd?.dispose();
    interstitialAd = null;
    isInterstitialReady = false;
  }
}

final Ads ads = Ads();
