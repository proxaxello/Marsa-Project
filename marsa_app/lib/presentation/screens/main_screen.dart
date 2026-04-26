import 'package:flutter/material.dart';
import 'package:marsa_app/presentation/screens/home_screen_simple.dart';
import 'package:marsa_app/presentation/screens/dictionary_screen_redesigned.dart';
import 'package:marsa_app/presentation/screens/practice_screen_simple.dart';
import 'package:marsa_app/presentation/screens/profile_screen_simple.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreenSimple(),
    DictionaryScreenRedesigned(),
    PracticeScreenSimple(),
    ProfileScreenSimple(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFf64a00),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Trang Ch\u1ee7',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.translate),
              label: 'D\u1ecbch',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.extension),
              label: 'Luy\u1ec7n T\u1eadp',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'C\u00e1 Nh\u00e2n',
            ),
          ],
        ),
      ),
    );
  }
}
