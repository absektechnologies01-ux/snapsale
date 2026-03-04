import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/payment_config.dart';
import '../../providers/shop_settings_provider.dart';
import '../../providers/subscription_provider.dart';

class PaymentScreen extends StatefulWidget {
  /// If true the screen acts as a blocking gate (no back navigation).
  final bool isGate;

  const PaymentScreen({super.key, this.isGate = false});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _showingWebview = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sub = context.read<SubscriptionProvider>();
      final shop = context.read<ShopSettingsProvider>();
      _emailCtrl.text = sub.billingEmail ??
          (shop.settings.email.isNotEmpty ? shop.settings.email : '');
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<bool> _isOnline() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.any((c) => c != ConnectivityResult.none);
    } catch (_) {
      // Plugin not available on this platform / not yet registered —
      // proceed and let the WebView handle offline errors.
      return true;
    }
  }

  Future<void> _startPayment() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMsg = 'Enter a valid email address to continue.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    if (!await _isOnline()) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMsg =
            'No internet connection. Please connect to the internet to pay.';
      });
      return;
    }

    if (!mounted) return;
    await context.read<SubscriptionProvider>().setBillingEmail(email);

    if (!mounted) return;
    setState(() {
      _loading = false;
      _showingWebview = true;
    });
  }

  void _onPaymentResult(String message) async {
    final data = jsonDecode(message) as Map<String, dynamic>;
    final status = data['status'] as String;

    if (status == 'success') {
      final ref = data['reference'] as String? ??
          'REF-${DateTime.now().millisecondsSinceEpoch}';

      if (!mounted) return;
      await context.read<SubscriptionProvider>().activate(ref);

      if (!mounted) return;
      setState(() => _showingWebview = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful! Subscription activated.'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      if (!widget.isGate) Navigator.pop(context);
    } else if (status == 'error') {
      if (mounted) {
        setState(() {
          _showingWebview = false;
          _errorMsg = 'Payment error: ${data['message'] ?? 'Unknown error. Please try again.'}';
        });
      }
    } else {
      // closed — user dismissed without paying
      if (mounted) setState(() => _showingWebview = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isGate,
      child: Scaffold(
        appBar: _showingWebview
            ? AppBar(
                title: const Text('Secure Payment'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      setState(() => _showingWebview = false),
                ),
              )
            : (widget.isGate
                ? null
                : AppBar(title: const Text('Subscription'))),
        body: _showingWebview
            ? _PaystackWebView(
                email: _emailCtrl.text.trim(),
                onResult: _onPaymentResult,
              )
            : _buildInfoPage(),
      ),
    );
  }

  Widget _buildInfoPage() {
    final sub = context.watch<SubscriptionProvider>();
    final expiry = sub.expiryDate;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.isGate) const SizedBox(height: 16),

            // Header
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.store_rounded, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'SnapSale',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    PaymentConfig.monthlyFeeLabel,
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Status
            if (sub.isBlocked)
              _StatusCard(
                icon: Icons.lock_outline,
                color: AppColors.error,
                title: 'Access Paused',
                message:
                    'Your subscription expired ${sub.daysOverdue} day${sub.daysOverdue == 1 ? '' : 's'} ago. '
                    'Renew now to continue using SnapSale.',
              )
            else if (sub.isInGracePeriod)
              _StatusCard(
                icon: Icons.warning_amber_rounded,
                color: AppColors.warningAmber,
                title: 'Subscription Expired',
                message:
                    'You have ${PaymentConfig.graceDays - sub.daysOverdue} day${(PaymentConfig.graceDays - sub.daysOverdue) == 1 ? '' : 's'} '
                    'before access is paused. Please renew.',
              )
            else if (expiry != null)
              _StatusCard(
                icon: Icons.check_circle_outline,
                color: AppColors.successGreen,
                title: 'Active Subscription',
                message:
                    'Expires on ${expiry.day}/${expiry.month}/${expiry.year}. '
                    'Renewing now extends from your current expiry.',
              ),

            const SizedBox(height: 20),

            const _FeatureRow(
                Icons.receipt_long_outlined, 'Unlimited receipt generation'),
            const SizedBox(height: 10),
            const _FeatureRow(
                Icons.inventory_2_outlined, 'Full catalog & stock management'),
            const SizedBox(height: 10),
            const _FeatureRow(
                Icons.picture_as_pdf_outlined, 'PDF & image export'),
            const SizedBox(height: 10),
            const _FeatureRow(
                Icons.bar_chart_rounded, 'Sales dashboard & analytics'),

            const SizedBox(height: 28),

            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Billing Email',
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                errorText: _errorMsg,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _loading ? null : _startPayment,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      sub.isActive
                          ? 'Renew — ${PaymentConfig.monthlyFeeLabel}'
                          : 'Subscribe — ${PaymentConfig.monthlyFeeLabel}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),

            const SizedBox(height: 12),

            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_outlined,
                    size: 14, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text(
                  'Internet required to process payment',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Paystack inline payment via WebView ──────────────────────────────────────

class _PaystackWebView extends StatefulWidget {
  final String email;
  final ValueChanged<String> onResult;

  const _PaystackWebView({required this.email, required this.onResult});

  @override
  State<_PaystackWebView> createState() => _PaystackWebViewState();
}

class _PaystackWebViewState extends State<_PaystackWebView> {
  late final WebViewController _controller;
  bool _webLoading = true;

  @override
  void initState() {
    super.initState();
    final ref = 'SNP-${DateTime.now().millisecondsSinceEpoch}';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'PaymentChannel',
        onMessageReceived: (msg) => widget.onResult(msg.message),
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _webLoading = false);
        },
      ))
      ..loadHtmlString(
        _html(
          publicKey: PaymentConfig.paystackPublicKey,
          email: widget.email,
          pesewas: PaymentConfig.monthlyAmountPesewas,
          ref: ref,
        ),
        // baseUrl gives the page a proper HTTPS origin so Paystack's JS
        // is allowed to run and create its payment iframe.
        baseUrl: 'https://checkout.paystack.com',
      );
  }

  static String _html({
    required String publicKey,
    required String email,
    required int pesewas,
    required String ref,
  }) =>
      '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body { font-family: sans-serif; display: flex; flex-direction: column;
           align-items: center; justify-content: center;
           min-height: 100vh; margin: 0; background: #f5f5f5; }
    .spinner { border: 3px solid #eee; border-top: 3px solid #6D1A36;
               border-radius: 50%; width: 40px; height: 40px;
               animation: spin .8s linear infinite; }
    @keyframes spin { to { transform: rotate(360deg); } }
    p { color: #666; font-size: 14px; margin-top: 12px; }
  </style>
</head>
<body>
  <div class="spinner"></div><p>Opening secure payment…</p>
  <script>
    function initPaystack() {
      try {
        var handler = PaystackPop.setup({
          key: '$publicKey',
          email: '$email',
          amount: $pesewas,
          currency: 'GHS',
          ref: '$ref',
          label: 'SnapSale Monthly',
          callback: function(r) {
            PaymentChannel.postMessage(
              JSON.stringify({status:'success', reference: r.reference})
            );
          },
          onClose: function() {
            PaymentChannel.postMessage(JSON.stringify({status:'closed'}));
          }
        });
        handler.openIframe();
      } catch(e) {
        PaymentChannel.postMessage(JSON.stringify({status:'error', message: e.toString()}));
      }
    }
  </script>
  <script src="https://js.paystack.co/v1/inline.js" onload="initPaystack()"></script>
</body>
</html>
''';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_webLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

// ── Reusable helper widgets ───────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  const _StatusCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(message,
                    style: TextStyle(
                        fontSize: 13,
                        color: color.withValues(alpha: 0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}
