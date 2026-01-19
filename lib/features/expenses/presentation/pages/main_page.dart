import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_page.dart';
import 'add_expense_page.dart';
import 'skeleton_pages.dart';
import '../bloc/expense_bloc.dart'; // Ensure Bloc is updated before this if logic changes

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(), // 0
    const BudgetsPage(),   // 1
    const SizedBox(), // 2 - Placeholder for Add button
    const ReportsPage(),   // 3
    const SettingsPage(),  // 4
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddExpensePage()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
           const BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
           const BottomNavigationBarItem(icon: Icon(Icons.pie_chart_rounded), label: 'Budgets'),
           BottomNavigationBarItem(
             icon: Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: Theme.of(context).primaryColor,
                 shape: BoxShape.circle,
                 boxShadow: [
                   BoxShadow(
                     color: Theme.of(context).primaryColor.withOpacity(0.3),
                     blurRadius: 10,
                     offset: const Offset(0, 4),
                   ),
                 ],
               ),
               child: const Icon(Icons.add, color: Colors.white),
             ),
             label: '',
           ),
           const BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
           const BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
