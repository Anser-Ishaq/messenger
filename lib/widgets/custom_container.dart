import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    super.key,
    required this.child,
    this.color = const Color(0x0A000000),
    this.width = 40,
    this.height = 40,
    this.leftM = 12,
    this.rightM = 12,
    this.topM = 12,
    this.bottomM = 12,
  });

  final Widget child;
  final Color color;
  final double width;
  final double height;
  final double leftM;
  final double rightM;
  final double topM;
  final double bottomM;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.only(
        left: leftM,
        right: rightM,
        top: topM,
        bottom: bottomM,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: child,
      ),
    );
  }
}
