import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:gal/gal.dart';

class ImageExportService {
  static Future<bool> captureAndSave(
    RenderRepaintBoundary boundary,
    String receiptNumber,
  ) async {
    try {
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return false;
      final pngBytes = byteData.buffer.asUint8List();
      await Gal.putImageBytes(pngBytes, name: 'SnapSale_$receiptNumber');
      return true;
    } catch (_) {
      return false;
    }
  }
}
