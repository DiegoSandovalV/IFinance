import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/expense_bloc.dart';
import '../../domain/entities/tag.dart';
import 'add_expense_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                 if (state is ExpenseLoaded) {
                   return SliverList(
                     delegate: SliverChildListDelegate([
                       _buildChartSection(context, state),
                       const SizedBox(height: 24),
                       Text('Recent Transactions', style: Theme.of(context).textTheme.headlineMedium),
                       const SizedBox(height: 16),
                       ...state.expenses.map((e) => _buildExpenseCard(context, e, state.tags)).toList(),
                       if (state.expenses.isEmpty)
                         const Center(child: Padding(
                           padding: EdgeInsets.all(32.0),
                           child: Text('No expenses yet.'),
                         )),
                       const SizedBox(height: 80), // Bottom padding for FAB/Nav
                     ]),
                   );
                 } else if (state is ExpenseLoading) {
                    return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                 } else if (state is ExpenseError) {
                    return SliverFillRemaining(child: Center(child: Text(state.message)));
                 }
                 return const SliverToBoxAdapter(child: SizedBox());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        title: Text(
          'Good afternoon!',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24), // Scale down for title
        ),
        background: Container(color: Theme.of(context).scaffoldBackgroundColor),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_month_rounded),
          onPressed: () {},
        ),
        IconButton(
          icon: const CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'), // Placeholder
            backgroundColor: Colors.grey,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context, ExpenseLoaded state) {
    final tagMap = {for (var t in state.tags) t.id: t};
    final Map<String, double> totals = {};
    
    // Calculate totals logic (reused from previous step)
    for (var e in state.expenses) {
      if (e.tagIds.isEmpty) {
        totals['uncategorized'] = (totals['uncategorized'] ?? 0) + e.amount;
      } else {
        // Assign to first tag for chart simplicity
        final tId = e.tagIds.first;
        totals[tId] = (totals[tId] ?? 0) + e.amount;
      }
    }
    
    final sections = totals.entries.map((e) {
       final name = e.key == 'uncategorized' ? 'Others' : (tagMap[e.key]?.name ?? 'Unknown');
       final color = Colors.primaries[totals.keys.toList().indexOf(e.key) % Colors.primaries.length];
       return PieChartSectionData(
         value: e.value,
         color: color,
         radius: 25,
         showTitle: false,
       );
    }).toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 70,
                    sectionsSpace: 4,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total Spent', style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      '\$${state.totalAmount.toStringAsFixed(0)}', 
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 36),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: totals.entries.map((e) {
               final name = e.key == 'uncategorized' ? 'Others' : (tagMap[e.key]?.name ?? 'Unknown');
               final color = Colors.primaries[totals.keys.toList().indexOf(e.key) % Colors.primaries.length];
               return Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                   const SizedBox(width: 8),
                   Text(name, style: Theme.of(context).textTheme.bodyMedium),
                 ],
               );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, dynamic expense, List<Tag> allTags) {
     final tagMap = {for (var t in allTags) t.id: t};
     final tagName = expense.tagIds.isNotEmpty ? (tagMap[expense.tagIds.first]?.name ?? 'Uncategorized') : 'Uncategorized';
     final dateStr = DateFormat('MMM d').format(expense.date);

     return Container(
       margin: const EdgeInsets.only(bottom: 12),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.grey.withOpacity(0.1)),
       ),
       child: ListTile(
         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
         leading: Container(
           padding: const EdgeInsets.all(10),
           decoration: BoxDecoration(
             color: Theme.of(context).primaryColor.withOpacity(0.1),
             borderRadius: BorderRadius.circular(12),
           ),
           child: Icon(Icons.shopping_bag_outlined, color: Theme.of(context).primaryColor),
         ),
         title: Text(expense.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
         subtitle: Text('$dateStr • $tagName', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
         trailing: Text(
           '-\$${expense.amount.toStringAsFixed(2)}', 
           style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
         ),
       ),
     );
  }
}
