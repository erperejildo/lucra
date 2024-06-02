import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lucra/providers/ads.dart';
import 'package:provider/provider.dart';

const List<String> _androidProductIds = <String>[
  'pro',
];

class Shop {
  // ProductDetailsResponse products;
  // QueryPurchaseDetailsResponse purchases;
  bool isAvailable = false;
  List<String> notFoundIds = [];
  List<ProductDetails> products = [];
  List<PurchaseDetails> purchases = [];
  bool purchasePending = false;
  bool loading = true;
  String? queryProductError;
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  Shop();

  Future<void> initStore() async {
    final bool isAvailableTemp = await inAppPurchase.isAvailable();
    if (!isAvailable) {
      isAvailable = isAvailableTemp;
      products = [];
      purchases = [];
      notFoundIds = [];
      purchasePending = false;
      loading = false;
      return;
    }

    final ProductDetailsResponse productDetailResponse =
        await inAppPurchase.queryProductDetails(_androidProductIds.toSet());

    if (productDetailResponse.error != null) {
      queryProductError = productDetailResponse.error!.message;
      isAvailable = isAvailable;
      products = productDetailResponse.productDetails;
      purchases = <PurchaseDetails>[];
      notFoundIds = productDetailResponse.notFoundIDs;
      purchasePending = false;
      loading = false;
      return;
    }
  }

  Future<void> getProduct(BuildContext context) async {
    if (!await shop.inAppPurchase.isAvailable()) return;
    await shop.initStore();
    await shop
        .getProducts()
        .then((value) async => await shop.getPastPurchases(context));
  }

  Future<List<ProductDetails>> getProducts() async {
    if (products.isEmpty) {
      final ProductDetailsResponse products =
          await inAppPurchase.queryProductDetails(_androidProductIds.toSet());
      if (products.productDetails.isNotEmpty) {
        // double check the order of the products
        // if (Helpers.containsInStringIgnoreCase(
        //     products.productDetails[0].title, "plus")) {
        //   this.products.addAll(products.productDetails);
        // } else {
        //   // pro comes first
        //   this.products.add(products.productDetails[1]);
        //   this.products.add(products.productDetails[0]);
        // }
        this.products.addAll(products.productDetails);
      }
    }
    return products;
  }

  Future<List<PurchaseDetails>> getPastPurchases(BuildContext context) async {
    if (purchases.isEmpty) {
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          inAppPurchase.purchaseStream;

      _subscription =
          purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
        if (purchaseDetailsList.isEmpty) {
          // no versions bought
          Provider.of<Ads>(context, listen: false).hideShowAds(true);
        } else {
          // this.purchases.addAll(purchaseDetailsList);
          listenToPurchaseUpdated(context, purchaseDetailsList);
        }
        // _subscription.cancel();
      }, onDone: () {
        _subscription.cancel();
      }, onError: (error) {
        // handle error here.
        _subscription.cancel();
      });

      await inAppPurchase.restorePurchases();
    }
    return purchases;
  }

  verifyPurchase(purchase) {
    if (purchase != null &&
        (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) &&
        purchase.purchaseID != null) {
      return purchase;
    } else {
      return false;
    }
  }

  Future buyProduct(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void showPendingUI() {
    purchasePending = true;
  }

  void handleError(IAPError error) {
    purchasePending = false;
  }

  void handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  Future<void> listenToPurchaseUpdated(
      BuildContext context, List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          purchasePending = true;
          break;
        case PurchaseStatus.restored || PurchaseStatus.purchased:
          final purchaseValid = await verifyPurchase(purchaseDetails);
          if (purchaseValid != false) {
            // ignore: use_build_context_synchronously
            Provider.of<Ads>(context, listen: false).hideShowAds(false);
          }
          break;
        case PurchaseStatus.error:
          purchasePending = false;
          break;
        default:
          break;
      }
    }
  }
}

final Shop shop = Shop();
