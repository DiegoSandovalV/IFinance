import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: Skeletonizer(
        enabled: true,
        child: ListView.separated(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => Card(
            child: ListTile(
              leading: const CircleAvatar(radius: 24),
              title: const Text('Budget Category Name'),
              subtitle: const Text('Spent: \$100 / \$500'),
              trailing: const Text('20%'),
            ),
          ),
        ),
      ),
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Skeletonizer(
        enabled: true,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Recent Monthly Trends'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: 4,
                   separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Skeletonizer(
        enabled: true,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: List.generate(
            6,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                   const CircleAvatar(radius: 20),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Container(height: 16, width: 150, color: Colors.grey),
                         const SizedBox(height: 8),
                         Container(height: 12, width: 200, color: Colors.grey),
                       ],
                     ),
                   ),
                   Switch(value: false, onChanged: (_) {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
