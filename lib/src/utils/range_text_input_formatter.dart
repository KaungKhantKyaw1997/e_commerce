import 'package:flutter/services.dart';

class RangeTextInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  RangeTextInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int number = int.tryParse(newValue.text) ?? 0;
    if (number < min) {
      return TextEditingValue(text: min.toString());
    } else if (number > max) {
      return TextEditingValue(text: max.toString());
    }
    return newValue;
  }
}
