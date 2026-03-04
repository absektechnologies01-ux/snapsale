import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareFile(File file, {String? subject}) async {
    final xFile = XFile(file.path);
    await Share.shareXFiles(
      [xFile],
      subject: subject ?? 'Receipt from SnapSale',
    );
  }
}
