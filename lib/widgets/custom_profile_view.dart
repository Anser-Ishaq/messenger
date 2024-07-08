import 'package:flutter/material.dart';

class CustomProfileView extends StatelessWidget {
  const CustomProfileView({
    super.key,
    required this.src,
    required this.name,
    this.subtitle = '',
    this.subtitleColor = Colors.black,
  });

  final String src;
  final String name;
  final String subtitle;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green[300], 
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              src,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Text(
          name.trim(),
          maxLines: 1,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.33,
            height: 28.64 / 24
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: subtitleColor,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.2,
            height: 17.9 / 15,
          ),
        ),
      ],
    );
  }
}
