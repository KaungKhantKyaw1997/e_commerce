import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/utils/capitalize_by_word.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomDropDown extends StatelessWidget {
  final String value;
  final Color fillColor;
  final List<String> items;
  final double itemWidth;
  final Function(String?)? onChanged;

  CustomDropDown({
    required this.value,
    required this.fillColor,
    required this.items,
    required this.onChanged,
    this.itemWidth = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          style: FontConstants.body1,
          borderRadius: BorderRadius.circular(8),
          icon: SvgPicture.asset(
            "assets/icons/down_arrow.svg",
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Colors.black,
              BlendMode.srcIn,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Container(
                width: itemWidth != 0.0
                    ? MediaQuery.of(context).size.width - itemWidth
                    : null,
                child: Text(
                  capitalizeByWord(item),
                  style: FontConstants.body1,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
