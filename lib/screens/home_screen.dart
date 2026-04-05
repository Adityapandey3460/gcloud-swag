// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../theme.dart';
import 'scanner_screen.dart';
import 'students_screen.dart';
import 'dashboard_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  // 1. Change this to a getter and remove 'const'
  List<Widget> get _screens => [
    const ScannerScreen(),
    // 2. Pass the redirection function to StudentsScreen
    StudentsScreen(onRedirectToScanner: () {
      setState(() => _tab = 0);
    }),
    const DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.blueBg,
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.qr_code_scanner_outlined),
              selectedIcon: Icon(Icons.qr_code_scanner, color: AppColors.blue),
              label: 'Scanner',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people, color: AppColors.blue),
              label: 'Students',
            ),
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: AppColors.blue),
              label: 'Dashboard',
            ),
          ],
        ),
      ),
    );
  }
}

