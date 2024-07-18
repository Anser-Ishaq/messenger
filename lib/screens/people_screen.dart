import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/components/header.dart';
import 'package:messanger_ui/components/searchbox.dart';
import 'package:messanger_ui/services/database_service.dart';
import 'package:messanger_ui/users.dart';
import 'package:messanger_ui/models/usermodel.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GetIt _getIt = GetIt.instance;
  bool _showRecentlyActive = false;

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait =
              MediaQuery.of(context).orientation == Orientation.portrait;
          final activePeopleHeight =
              constraints.maxHeight * (isPortrait ? 0.585 : 0.4);

          return !isPortrait
              ? SingleChildScrollView(
                  child: _screenContent(activePeopleHeight),
                )
              : _screenContent(activePeopleHeight);
        },
      ),
    );
  }

  Widget _screenContent(double activePeopleHeight) {
    return Column(
      children: [
        Header(
          pfp: _databaseService.userModel.pfpURL!,
          screenText: 'People',
          containIcons: true,
          icon1: Icons.chat_bubble,
          icon2: Icons.person_add,
          onPressedIcon1: () {},
          onPressedIcon2: () {},
        ),
        Searchbox(
          searchController: _searchController,
        ),
        _storyBox(),
        _activePeople(activePeopleHeight),
        _recentlyActivePeopleText(),
        _recentlyActivePeople(activePeopleHeight),
      ],
    );
  }

  Widget _storyBox() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(12.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x0A000000),
            ),
            child: Center(
              child: IconButton(
                onPressed: () {},
                icon: const Center(
                  child: Icon(
                    Icons.add,
                  ),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your story',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                    )),
                Text(
                  'Add to your story',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.08,
                    color: Color(0x80000000),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _activePeople(double height) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      height: _showRecentlyActive ? 0 : height,
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) => _buildUserTile(users[index]),
      ),
    );
  }

  Widget _recentlyActivePeopleText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 12, right: 12, top: 10),
          alignment: Alignment.centerLeft,
          child: const Text(
            'RECENTLY ACTIVE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0x56000000),
            ),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.only(right: 1),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Center(
            child: IconButton(
              onPressed: () {
                setState(() {
                  _showRecentlyActive = !_showRecentlyActive;
                });
              },
              color: const Color(0x56000000),
              icon: const Icon(Icons.arrow_drop_down_rounded),
            ),
          ),
        ),
      ],
    );
  }

  Widget _recentlyActivePeople(double height) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      height: _showRecentlyActive ? height : 0,
      curve: Curves.easeInOut,
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) => _buildUserTile(users[index]),
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
            child: ClipOval(
              child: Image.asset(
                user.pfpURL!,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.username!,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 14),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0x0A000000),
                        ),
                        child: Center(
                          child: IconButton(
                            padding: const EdgeInsets.all(0),
                            onPressed: () {},
                            icon: const Icon(
                              Icons.waving_hand_rounded,
                              size: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  color: const Color(0x1F000000),
                  margin: const EdgeInsets.only(left: 4.5, right: 15.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
