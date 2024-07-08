import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {

  final Color color;
  const CustomBackButton({
    super.key,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    Color? iconColor = Theme.of(context).iconTheme.color;
    return GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 25,
            color: color == const Color(0xFF0584FE) ? color : iconColor ?? color,
          ),
        );
  }
}
