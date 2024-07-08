import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/companies.dart';
import 'package:messanger_ui/components/header.dart';
import 'package:messanger_ui/components/searchbox.dart';
import 'package:messanger_ui/services/database_service.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final GetIt _getIt = GetIt.instance;
  bool buttonFocused = true;

  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  _buildUI() {
    return SafeArea(
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          children: [
            Header(
              pfp: _databaseService.userModel.pfpURL!,
              screenText: 'Discover',
              containIcons: false,
            ),
            const Searchbox(),
            _navigationTile(),
            if (buttonFocused) _recentSection(),
            if (buttonFocused) _moreSection(),
          ],
        ),
      ),
    );
  }

  Widget _navigationTile() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  buttonFocused = true;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: buttonFocused ? const Color(0x0A000000) : Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'FOR YOU',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        buttonFocused ? Colors.black : const Color(0x80000000),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  buttonFocused = false;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: buttonFocused ? Theme.of(context).scaffoldBackgroundColor : const Color(0x0A000000),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'BUSINESSES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        buttonFocused ? const Color(0x80000000) : Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentSection() {
    return recent.isNotEmpty
        ? Container(
            height: 133,
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Recent',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.33,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recent.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0x26000000),
                                  width: 0.33,
                                ),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: SvgPicture.network(
                                    recent[index]['logoUrl']!,
                                    placeholderBuilder: (context) =>
                                        const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0x80000000),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 18,
                              child: Text(
                                recent[index]['name']!,
                                style: const TextStyle(
                                  color: Color(0x80000000),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.08,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _moreSection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(
          left: 4,
          right: 4,
          top: 10,
        ),
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
              alignment: Alignment.centerLeft,
              child: const Text(
                'More',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.33,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: companies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    minLeadingWidth: 70,
                    minVerticalPadding: 5,
                    onTap: () {
                      if (recent.contains(companies[index])) {
                      } else {
                        recent.add(companies[index]);
                      }
                      setState(() {});
                    },
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0x26000000),
                          width: 0.33,
                        ),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: SvgPicture.network(
                            companies[index]['logoUrl']!,
                            placeholderBuilder: (context) => const SizedBox(
                              width: 20,
                              height: 20,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0x80000000),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      companies[index]['name']!,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.45,
                      ),
                    ),
                    subtitle: Text(
                      companies[index]['description']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0x80000000),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.08,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
