import 'package:flutter/material.dart';
import 'package:messanger_ui/screens/chat_screen.dart';
import 'package:messanger_ui/screens/discover_screen.dart';
import 'package:messanger_ui/screens/people_screen.dart';
import 'package:messanger_ui/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screen = [
    const ChatScreen(),
    const PeopleScreen(),
    const DiscoverScreen(),
    const ProfileScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat,
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.people,
            ),
            label: 'People',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage(
                'assets/icons/Discover.png',
              ),
            ),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        elevation: 3,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

  void _onItemTapped(int index) {
    _selectedIndex = index;
    setState(() {
    });
  }

}
