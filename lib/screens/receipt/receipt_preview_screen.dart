import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/receipt_model.dart';
import '../../providers/receipt_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/image_export_service.dart';
import '../../services/pdf_service.dart';
import '../../services/share_service.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/receipt/receipt_widget.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  final ReceiptModel receipt;
  const ReceiptPreviewScreen({super.key, required this.receipt});

  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _loading = false;
  String _loadingMsg = '';

  Future<void> _downloadPdf() async {
    setState(() {
      _loading = true;
      _loadingMsg = 'Generating PDF...';
    });
    try {
      final file = await PdfService.generateReceiptPdf(widget.receipt);
      if (mounted) {
        await Printing.sharePdf(
          bytes: await file.readAsBytes(),
          filename: 'receipt_${widget.receipt.receiptNumber}.pdf',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveImage() async {
    setState(() {
      _loading = true;
      _loadingMsg = 'Saving image...';
    });
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Could not render receipt');
      final success = await ImageExportService.captureAndSave(
        boundary,
        widget.receipt.receiptNumber,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Receipt saved to gallery!'
                : 'Failed to save image'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _share() async {
    setState(() {
      _loading = true;
      _loadingMsg = 'Preparing...';
    });
    try {
      final file = await PdfService.generateReceiptPdf(widget.receipt);
      await ShareService.shareFile(file,
          subject: 'Receipt ${widget.receipt.receiptNumber}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Receipt?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style:
                  TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && mounted) {
      final receiptProvider = context.read<ReceiptProvider>();
      final dashboardProvider = context.read<DashboardProvider>();
      await receiptProvider.deleteReceipt(widget.receipt.id);
      dashboardProvider.refresh(receiptProvider.allReceipts);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.receiptPreview),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: _delete,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        message: _loadingMsg,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ReceiptWidget(
                      receipt: widget.receipt,
                      repaintKey: _repaintKey,
                    ),
                  ),
                ),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          _ActionBtn(
            icon: Icons.picture_as_pdf_outlined,
            label: 'PDF',
            onTap: _downloadPdf,
          ),
          const SizedBox(width: 10),
          _ActionBtn(
            icon: Icons.image_outlined,
            label: 'Image',
            onTap: _saveImage,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _share,
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text(AppStrings.share),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48)),
      ),
    );
  }
}
