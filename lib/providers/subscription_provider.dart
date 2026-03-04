import 'package:flutter/foundation.dart';
import '../services/subscription_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  bool get isActive => SubscriptionService.isActive;
  bool get isDueSoon => SubscriptionService.isDueSoon;
  bool get isInGracePeriod => SubscriptionService.isInGracePeriod;
  bool get isBlocked => SubscriptionService.isBlocked;
  int get daysUntilExpiry => SubscriptionService.daysUntilExpiry;
  int get daysOverdue => SubscriptionService.daysOverdue;
  DateTime? get expiryDate => SubscriptionService.expiryDate;
  String? get billingEmail => SubscriptionService.billingEmail;

  Future<void> activate(String paymentRef) async {
    await SubscriptionService.activate(paymentRef);
    notifyListeners();
  }

  Future<void> setBillingEmail(String email) async {
    await SubscriptionService.setBillingEmail(email);
    notifyListeners();
  }

  void refresh() => notifyListeners();
}
