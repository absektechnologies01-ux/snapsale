import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../models/category_model.dart';
import '../../providers/catalog_provider.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final CategoryModel? category;
  const AddEditCategoryScreen({super.key, this.category});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emojiCtrl;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.category?.name ?? '');
    _emojiCtrl =
        TextEditingController(text: widget.category?.iconEmoji ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emojiCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final catalog = context.read<CatalogProvider>();
    final emoji =
        _emojiCtrl.text.trim().isEmpty ? null : _emojiCtrl.text.trim();
    if (_isEdit) {
      await catalog.updateCategory(
          widget.category!, _nameCtrl.text.trim(), emoji);
    } else {
      await catalog.addCategory(_nameCtrl.text.trim(), iconEmoji: emoji);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              _isEdit ? AppStrings.editCategory : AppStrings.addCategory)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emojiCtrl,
                decoration: const InputDecoration(
                  labelText: 'Icon (emoji, optional)',
                  prefixIcon:
                      Icon(Icons.emoji_emotions_outlined, size: 20),
                  hintText: 'e.g. 🥤',
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length > 2) {
                    return 'Use a single emoji';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: AppStrings.itemName,
                  prefixIcon: Icon(Icons.category_outlined, size: 20),
                  hintText: 'e.g. Beverages',
                ),
                validator: (v) => (v?.trim().isEmpty ?? true)
                    ? 'Category name is required'
                    : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                  onPressed: _save, child: const Text(AppStrings.save)),
            ],
          ),
        ),
      ),
    );
  }
}
