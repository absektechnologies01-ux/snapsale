/// Paystack payment configuration.
/// Replace [paystackPublicKey] with your key from dashboard.paystack.co
class PaymentConfig {
  PaymentConfig._();

  /// Your Paystack public key (starts with pk_live_ or pk_test_)
  static const String paystackPublicKey =
      'pk_test_f0cbf29d93b793dc0ad05ccf25bafdb3143a28cd';

  /// Monthly subscription fee in pesewas (GHS × 100). 50 GHS = 5000 pesewas.
  static const int monthlyAmountPesewas = 5000;

  /// Human-readable monthly fee string
  static const String monthlyFeeLabel = 'GHS 50.00 / month';

  /// Days before expiry to start showing the warning banner
  static const int warningDays = 7;

  /// Grace period after expiry before the app is blocked (days)
  static const int graceDays = 7;

  /// Free trial on first install (days)
  static const int trialDays = 30;
}
