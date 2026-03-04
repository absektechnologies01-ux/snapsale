import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/receipt_item_model.dart';
import '../../models/receipt_model.dart';

class ReceiptWidget extends StatelessWidget {
  final ReceiptModel receipt;
  final GlobalKey? repaintKey;

  const ReceiptWidget({super.key, required this.receipt, this.repaintKey});

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: AppSizes.receiptWidth,
      color: AppColors.receiptBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _dashed(),
          const SizedBox(height: 8),
          _buildMetaRow('Receipt #', receipt.receiptNumber),
          const SizedBox(height: 4),
          _buildMetaRow(
              'Date', DateFormatter.formatDateTime(receipt.createdAt)),
          const SizedBox(height: 8),
          _dashed(),
          const SizedBox(height: 8),
          _buildTableHeader(),
          const Divider(height: 12, thickness: 0.5, color: AppColors.divider),
          ...receipt.items.map(_buildItemRow),
          const Divider(height: 12, thickness: 0.5, color: AppColors.divider),
          _buildTotalRow(),
          const SizedBox(height: 12),
          _dashed(),
          const SizedBox(height: 12),
          _buildFooter(),
          const SizedBox(height: 8),
        ],
      ),
    );

    if (repaintKey != null) {
      return RepaintBoundary(key: repaintKey, child: content);
    }
    return content;
  }

  Widget _buildHeader() {
    return Column(
      children: [
        if (receipt.shopLogoPath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(receipt.shopLogoPath!),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => const SizedBox.shrink(),
            ),
          )
        else
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.store, color: Colors.white, size: 30),
          ),
        const SizedBox(height: 8),
        Text(
          receipt.shopName.isNotEmpty ? receipt.shopName : 'SnapSale',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        if (receipt.shopAddress.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            receipt.shopAddress,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
        if (receipt.shopPhone.isNotEmpty) ...[
          const SizedBox(height: 1),
          Text(
            'Tel: ${receipt.shopPhone}',
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
        if (receipt.shopEmail.isNotEmpty) ...[
          const SizedBox(height: 1),
          Text(
            receipt.shopEmail,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
        Text(value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTableHeader() {
    return const Row(
      children: [
        Expanded(
          child: Text('Item',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground)),
        ),
        SizedBox(
          width: 28,
          child: Text('Qty',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground),
              textAlign: TextAlign.center),
        ),
        SizedBox(
          width: 55,
          child: Text('Price',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground),
              textAlign: TextAlign.right),
        ),
        SizedBox(
          width: 60,
          child: Text('Total',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground),
              textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _buildItemRow(ReceiptItemModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.itemName,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.onBackground),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text('${item.quantity}',
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 55,
            child: Text(
              CurrencyFormatter.formatGHS(item.unitPrice),
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              CurrencyFormatter.formatGHS(item.subtotal),
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'TOTAL',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        Text(
          CurrencyFormatter.formatGHS(receipt.grandTotal),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return const Column(
      children: [
        Text(
          'Thank you for your purchase!',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2),
        Text(
          '— SnapSale —',
          style: TextStyle(fontSize: 10, color: AppColors.divider),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _dashed() {
    return Row(
      children: List.generate(
        38,
        (_) => const Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1),
            child: Divider(
                thickness: 1,
                color: AppColors.divider,
                height: 1),
          ),
        ),
      ),
    );
  }
}
