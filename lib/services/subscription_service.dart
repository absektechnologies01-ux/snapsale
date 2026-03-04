import 'package:hive/hive.dart';
import '../core/constants/payment_config.dart';

class SubscriptionService {
  static const String _boxName = 'subscription';
  static const String _expiryKey = 'expiry';
  static const String _refKey = 'last_ref';
  static const String _emailKey = 'billing_email';
  static const String _trialKey = 'trial_started';

  static Box get _box => Hive.box(_boxName);

  static Future<void> init() async {
    await Hive.openBox(_boxName);
    // On first ever launch, grant a free trial period
    if (_box.get(_trialKey) == null) {
      final trialExpiry = DateTime.now()
          .add(const Duration(days: PaymentConfig.trialDays));
      await _box.put(_expiryKey, trialExpiry.toIso8601String());
      await _box.put(_trialKey, true);
    }
  }

  static DateTime? get expiryDate {
    final raw = _box.get(_expiryKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw as String);
  }

  static String? get billingEmail => _box.get(_emailKey) as String?;

  static Future<void> setBillingEmail(String email) =>
      _box.put(_emailKey, email);

  /// Subscription is currently valid (not yet expired)
  static bool get isActive {
    final e = expiryDate;
    return e != null && DateTime.now().isBefore(e);
  }

  /// Active but expiring within [warningDays] — show subtle banner
  static bool get isDueSoon {
    final e = expiryDate;
    if (e == null || !isActive) return false;
    return e.difference(DateTime.now()).inDays < PaymentConfig.warningDays;
  }

  /// Past expiry but still within grace period — show persistent alert
  static bool get isInGracePeriod {
    final e = expiryDate;
    if (e == null) return false;
    final overdue = DateTime.now().difference(e).inDays;
    return overdue >= 0 && overdue < PaymentConfig.graceDays;
  }

  /// Past expiry AND past grace period — block the app
  static bool get isBlocked {
    final e = expiryDate;
    if (e == null) return true;
    return DateTime.now().difference(e).inDays >= PaymentConfig.graceDays;
  }

  static int get daysUntilExpiry {
    final e = expiryDate;
    if (e == null) return 0;
    return e.difference(DateTime.now()).inDays;
  }

  static int get daysOverdue {
    final e = expiryDate;
    if (e == null || isActive) return 0;
    return DateTime.now().difference(e).inDays;
  }

  /// Activate/extend subscription by 30 days from today (or from current
  /// expiry if still active — allows early renewal without losing days).
  static Future<void> activate(String paymentRef) async {
    final base = isActive ? expiryDate! : DateTime.now();
    final newExpiry =
        base.add(const Duration(days: 30));
    await _box.put(_expiryKey, newExpiry.toIso8601String());
    await _box.put(_refKey, paymentRef);
  }

  static String get lastPaymentRef =>
      (_box.get(_refKey) as String?) ?? '';

  static String generateRef() =>
      'SNP-SUB-${DateTime.now().millisecondsSinceEpoch}';
}
