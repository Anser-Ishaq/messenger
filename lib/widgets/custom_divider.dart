import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(
        left: 12,
        right: 12,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0x1F000000),
          width: 0.5,
        ),
      ),
    );
  }
}