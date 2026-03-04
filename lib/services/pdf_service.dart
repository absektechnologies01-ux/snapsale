import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/receipt_model.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';

class PdfService {
  static const PdfColor _primary = PdfColor.fromInt(0xFF6D1A36);
  static const PdfColor _black = PdfColor.fromInt(0xFF1A1A1A);
  static const PdfColor _grey = PdfColor.fromInt(0xFF6B6B6B);
  static const PdfColor _divider = PdfColor.fromInt(0xFFE0D5D8);

  static Future<File> generateReceiptPdf(ReceiptModel receipt) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    if (receipt.shopLogoPath != null) {
      try {
        final bytes = await File(receipt.shopLogoPath!).readAsBytes();
        logoImage = pw.MemoryImage(bytes);
      } catch (_) {}
    }

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity,
            marginAll: 4 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Logo
              if (logoImage != null)
                pw.Container(
                  width: 50,
                  height: 50,
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                ),

              // Shop Name
              pw.Text(
                receipt.shopName,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: _primary,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 2),

              // Shop details
              if (receipt.shopAddress.isNotEmpty)
                pw.Text(receipt.shopAddress,
                    style: const pw.TextStyle(fontSize: 8, color: _grey),
                    textAlign: pw.TextAlign.center),
              if (receipt.shopPhone.isNotEmpty)
                pw.Text('Tel: ${receipt.shopPhone}',
                    style: const pw.TextStyle(fontSize: 8, color: _grey),
                    textAlign: pw.TextAlign.center),
              if (receipt.shopEmail.isNotEmpty)
                pw.Text(receipt.shopEmail,
                    style: const pw.TextStyle(fontSize: 8, color: _grey),
                    textAlign: pw.TextAlign.center),

              _dividerLine(),

              // Receipt number & date
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Receipt #',
                      style: const pw.TextStyle(fontSize: 8, color: _grey)),
                  pw.Text(receipt.receiptNumber,
                      style: pw.TextStyle(
                          fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date:',
                      style: const pw.TextStyle(fontSize: 8, color: _grey)),
                  pw.Text(DateFormatter.formatDateTime(receipt.createdAt),
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),

              _dividerLine(),

              // Table header
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text('Item',
                        style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: _black)),
                  ),
                  pw.Container(
                    width: 24,
                    child: pw.Text('Qty',
                        style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: _black),
                        textAlign: pw.TextAlign.center),
                  ),
                  pw.Container(
                    width: 35,
                    child: pw.Text('Price',
                        style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: _black),
                        textAlign: pw.TextAlign.right),
                  ),
                  pw.Container(
                    width: 38,
                    child: pw.Text('Total',
                        style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: _black),
                        textAlign: pw.TextAlign.right),
                  ),
                ],
              ),
              _thinDivider(),

              // Items
              ...receipt.items.map((item) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Text(item.itemName,
                              style: const pw.TextStyle(fontSize: 8, color: _black)),
                        ),
                        pw.Container(
                          width: 24,
                          child: pw.Text('${item.quantity}',
                              style: const pw.TextStyle(fontSize: 8),
                              textAlign: pw.TextAlign.center),
                        ),
                        pw.Container(
                          width: 35,
                          child: pw.Text(
                              CurrencyFormatter.format(item.unitPrice),
                              style: const pw.TextStyle(fontSize: 7),
                              textAlign: pw.TextAlign.right),
                        ),
                        pw.Container(
                          width: 38,
                          child: pw.Text(
                              CurrencyFormatter.format(item.subtotal),
                              style: const pw.TextStyle(fontSize: 7),
                              textAlign: pw.TextAlign.right),
                        ),
                      ],
                    ),
                  )),

              _dividerLine(),

              // Grand Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL',
                      style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: _primary)),
                  pw.Text(CurrencyFormatter.format(receipt.grandTotal),
                      style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: _primary)),
                ],
              ),

              _dividerLine(),

              // Footer
              pw.SizedBox(height: 4),
              pw.Text('Thank you for your purchase!',
                  style: const pw.TextStyle(fontSize: 8, color: _grey),
                  textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 2),
              pw.Text('Powered by SnapSale',
                  style: const pw.TextStyle(fontSize: 7, color: _divider),
                  textAlign: pw.TextAlign.center),
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file =
        File('${dir.path}/receipt_${receipt.receiptNumber}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _dividerLine() => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Divider(color: _divider, thickness: 0.5),
      );

  static pw.Widget _thinDivider() => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Divider(color: _divider, thickness: 0.3),
      );
}
