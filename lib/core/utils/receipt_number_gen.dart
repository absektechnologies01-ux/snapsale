class ReceiptNumberGen {
  static String generate(int counter) {
    final year = DateTime.now().year.toString().substring(2);
    final paddedCounter = counter.toString().padLeft(5, '0');
    return 'SNP-$year$paddedCounter';
  }
}
