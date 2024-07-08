import 'package:flutter/material.dart';

class Searchbox extends StatefulWidget {
  const Searchbox({super.key});

  @override
  State<Searchbox> createState() => _SearchboxState();
}

class _SearchboxState extends State<Searchbox> {
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(
        left: 4.0,
        right: 4.0,
        top: 4,
        bottom: 8,
      ),
      child: Container(
        height: 25,
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        decoration: BoxDecoration(
          color: const Color(0x0A000000),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: 20,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: TextField(
                expands: true,
                maxLines: null,
                controller: _searchController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
