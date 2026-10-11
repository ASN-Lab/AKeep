import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AppCurrency {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(num value) => _formatter.format(value);
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove all non-digits
    String cleanText = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final number = int.parse(cleanText);
    final formatter = NumberFormat('#,###', 'id_ID');
    final newText = formatter.format(number);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
