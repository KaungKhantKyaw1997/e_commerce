import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormattedAmount extends StatelessWidget {
  final double amount;
  final TextStyle mainTextStyle;
  final TextStyle decimalTextStyle;

  const FormattedAmount({
    super.key,
    required this.amount,
    required this.mainTextStyle,
    required this.decimalTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    NumberFormat formatter = NumberFormat('###,###.00', 'en_US');
    String formattedAmount = formatter.format(amount);

    int dotIndex = formattedAmount.indexOf('.');
    String mainPart = formattedAmount.substring(0, dotIndex);
    String decimalPart = formattedAmount.substring(dotIndex + 1);

    return RichText(
      text: TextSpan(
        style: mainTextStyle,
        children: [
          TextSpan(
            text: mainPart.isEmpty ? "0" : mainPart,
          ),
          const TextSpan(
            text: '.',
          ),
          TextSpan(
            text: decimalPart,
            style: decimalTextStyle,
          ),
        ],
      ),
    );
  }
}
