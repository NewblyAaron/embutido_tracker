import 'package:embutido_tracker/ui/home/map/map_page.dart';
import 'package:embutido_tracker/ui/home/profile/profile_page.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  final PageController _pageController = PageController(initialPage: 1);
  final List<Widget> _pages = [ProfilePage(), MapPage(), Placeholder()];
  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
    BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
    BottomNavigationBarItem(
      icon: Icon(Icons.abc),
      label: "Placeholder",
    ),
  ];

  void _onBottomNavBarItemTapped(int index) => setState(() {
    _selectedIndex = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavBarItemTapped,
        items: _navItems,
      ),
    );
  }
}
