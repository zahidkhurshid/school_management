import 'package:flutter/material.dart';
import '../widgets/animated_bottom_bar.dart';
import 'academic_screen.dart';
import 'fee_management_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'student_stats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2;

  final List<Widget> _screens = [
    const AcademicScreen(),
    const StudentStatsScreen(),
    const HomeScreen(),
    const FeeManagementScreen(),
    const ProfileScreen(),
  ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: AnimatedBottomBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
        items: [
          BottomNavItem(
            icon: Icons.school,
            label: 'Academic',
          ),
          BottomNavItem(
            icon: Icons.bar_chart,
            label: 'Stats',
          ),
          BottomNavItem(
            icon: Icons.home,
            label: 'Home',
            isCenter: true,
          ),
          BottomNavItem(
            icon: Icons.payment,
            label: 'Fees',
          ),
          BottomNavItem(
            icon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
