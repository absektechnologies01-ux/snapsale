import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/shop_settings_provider.dart';
import '../../providers/subscription_provider.dart';
import '../subscription/payment_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = context.read<ShopSettingsProvider>().settings;
    _nameCtrl = TextEditingController(text: s.shopName);
    _addressCtrl = TextEditingController(text: s.address);
    _phoneCtrl = TextEditingController(text: s.phone);
    _emailCtrl = TextEditingController(text: s.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await context.read<ShopSettingsProvider>().save(
          shopName: _nameCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
        );
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.settingsSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.shopSettings)),
      body: Consumer<ShopSettingsProvider>(
        builder: (ctx, provider, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogoSection(provider),
                const SizedBox(height: 24),
                _buildField(
                  controller: _nameCtrl,
                  label: AppStrings.shopName,
                  icon: Icons.store_outlined,
                  validator: (v) =>
                      (v?.trim().isEmpty ?? true) ? 'Shop name is required' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _addressCtrl,
                  label: AppStrings.shopAddress,
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _phoneCtrl,
                  label: AppStrings.shopPhone,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _emailCtrl,
                  label: AppStrings.shopEmail,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(AppStrings.saveSettings),
                ),
                const SizedBox(height: 24),
                _buildSubscriptionTile(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(ShopSettingsProvider provider) {
    final logoPath = provider.settings.logoPath;
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: provider.pickLogo,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider, width: 2),
              ),
              child: logoPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(logoPath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => _logoPlaceholder(),
                      ),
                    )
                  : _logoPlaceholder(),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: provider.pickLogo,
            icon: const Icon(Icons.photo_library_outlined, size: 16),
            label: const Text(AppStrings.changeLogo,
                style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _logoPlaceholder() => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 32, color: AppColors.primary),
          SizedBox(height: 4),
          Text('Add Logo',
              style:
                  TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      );

  Widget _buildSubscriptionTile() {
    final sub = context.watch<SubscriptionProvider>();
    final expiry = sub.expiryDate;
    final Color statusColor = sub.isBlocked || sub.isInGracePeriod
        ? AppColors.error
        : sub.isDueSoon
            ? AppColors.warningAmber
            : AppColors.successGreen;
    final String statusLabel = sub.isBlocked
        ? 'Expired'
        : sub.isInGracePeriod
            ? 'Grace period'
            : sub.isDueSoon
                ? 'Expiring soon'
                : 'Active';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.workspace_premium_outlined,
              color: AppColors.primary, size: 20),
        ),
        title: const Text('Subscription',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(
          expiry != null
              ? 'Expires ${expiry.day}/${expiry.month}/${expiry.year}'
              : 'No active subscription',
          style:
              const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentScreen()),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }
}
