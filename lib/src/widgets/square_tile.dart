import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SquareTile extends StatelessWidget {
  final String icon;
  final Function()? onTap;
  const SquareTile({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(25),
          color: ColorConstants.fillColor,
        ),
        child: SvgPicture.asset(
          icon,
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}
