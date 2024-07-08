import 'package:flutter/material.dart';
import 'package:messanger_ui/widgets/custom_container.dart';

class CustomIconButtom extends StatelessWidget {
  const CustomIconButtom({
    super.key,
    required this.iconData,
    required this.title,
  });

  final IconData iconData;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomContainer(
          child: IconButton(icon: Icon(iconData),
          onPressed: (){},
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0x80000000),
            letterSpacing: -0.01,
            height: 14.32 / 12,
          ),
        ),
      ],
    );
  }
}
