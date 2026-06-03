import 'package:flutter/services.dart';

class RutFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    if (newValue.text.length > 12) {
      return oldValue;
    }

    // Keep only digits and K/k
    String cleanedText = newValue.text.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();

    if (cleanedText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted = _formatRut(cleanedText);

    // Put the cursor at the end
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _formatRut(String rutClean) {
    if (rutClean.length <= 1) return rutClean;

    String dv = rutClean.substring(rutClean.length - 1);
    String body = rutClean.substring(0, rutClean.length - 1);

    String formattedBody = '';
    int count = 0;
    for (int i = body.length - 1; i >= 0; i--) {
      formattedBody = body[i] + formattedBody;
      count++;
      if (count == 3 && i > 0) {
        formattedBody = '.$formattedBody';
        count = 0;
      }
    }

    return '$formattedBody-$dv';
  }
}
