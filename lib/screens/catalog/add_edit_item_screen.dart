import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/item_model.dart';
import '../../providers/catalog_provider.dart';

class AddEditItemScreen extends StatefulWidget {
  final ItemModel? item;
  const AddEditItemScreen({super.key, this.item});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;
  String? _selectedCategoryId;
  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _priceCtrl = TextEditingController(
        text: item != null ? item.price.toStringAsFixed(2) : '');
    _stockCtrl = TextEditingController(
        text: item != null ? '${item.stockQuantity}' : '');
    // Normalize: empty string means no category (treat as null = Uncategorized)
    final rawCat = item?.categoryId;
    _selectedCategoryId = (rawCat != null && rawCat.isNotEmpty) ? rawCat : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final catalog = context.read<CatalogProvider>();
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;
    if (_isEdit) {
      await catalog.updateItem(
        widget.item!,
        name: _nameCtrl.text.trim(),
        price: price,
        stockQuantity: stock,
        categoryId: _selectedCategoryId ?? '',
      );
    } else {
      await catalog.addItem(
        name: _nameCtrl.text.trim(),
        price: price,
        stockQuantity: stock,
        categoryId: _selectedCategoryId ?? '',
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(_isEdit ? AppStrings.editItem : AppStrings.addItem)),
      body: Consumer<CatalogProvider>(
        builder: (ctx, catalog, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: AppStrings.itemName,
                    prefixIcon:
                        Icon(Icons.inventory_2_outlined, size: 20),
                  ),
                  validator: (v) => (v?.trim().isEmpty ?? true)
                      ? 'Item name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: const InputDecoration(
                    labelText: AppStrings.unitPrice,
                    prefixText: '${AppStrings.currency} ',
                    prefixStyle: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600),
                    prefixIcon:
                        Icon(Icons.attach_money_outlined, size: 20),
                  ),
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return 'Price is required';
                    if (double.tryParse(v!.trim()) == null) {
                      return 'Enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: AppStrings.stock,
                    prefixIcon:
                        Icon(Icons.warehouse_outlined, size: 20),
                  ),
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return 'Stock is required';
                    if (int.tryParse(v!.trim()) == null) {
                      return 'Enter a whole number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: AppStrings.category,
                    prefixIcon:
                        Icon(Icons.category_outlined, size: 20),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Uncategorized'),
                    ),
                    ...catalog.categories.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(
                              '${c.iconEmoji != null ? '${c.iconEmoji} ' : ''}${c.name}'),
                        )),
                  ],
                  onChanged: (v) =>
                      setState(() => _selectedCategoryId = v),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                    onPressed: _save,
                    child: const Text(AppStrings.save)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
