import 'package:flutter/material.dart';
import 'package:messanger_ui/widgets/custom_container.dart';

class Header extends StatefulWidget {
  const Header({
    super.key,
    required this.pfp,
    required this.screenText,
    this.icon1,
    this.icon2,
    this.containIcons = true,
    this.onPressedIcon1,
    this.onPressedIcon2,
  });
  final String pfp;
  final String screenText;
  final IconData? icon1;
  final IconData? icon2;
  final bool containIcons;
  final VoidCallback? onPressedIcon1;
  final VoidCallback? onPressedIcon2;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      height: 64,
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(12.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                widget.pfp,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(
                horizontal: 5,
              ),
              child: Text(
                widget.screenText,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          widget.containIcons
              ? CustomContainer(
                  rightM: 6,
                  child: IconButton(
                    onPressed: widget.onPressedIcon1,
                    icon: Icon(
                      widget.icon1,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          widget.containIcons
              ? CustomContainer(
                  leftM: 6,
                  child: IconButton(
                    onPressed: widget.onPressedIcon2,
                    icon: Icon(
                      widget.icon2,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
