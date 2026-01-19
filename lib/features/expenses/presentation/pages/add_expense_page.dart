import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/tag.dart';
import '../../domain/usecases/manage_tags.dart';
import '../bloc/expense_bloc.dart';
import '../../../../../injection_container.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<Tag> _selectedTags = [];
  List<Tag> _availableTags = [];
  
  @override
  void initState() {
    super.initState();
    _loadTags();
  }
  
  Future<void> _loadTags() async {
    final tags = await sl<GetTags>()();
    setState(() {
      _availableTags = tags;
    });
  }

  Future<void> _promptCreateTag() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Tag'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Tag Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add')),
        ],
      ),
    );
    
    if (name != null && name.isNotEmpty) {
      final newTag = Tag(id: const Uuid().v4(), name: name);
      await sl<AddTag>()(newTag);
      _loadTags();
    }
  }

  void _saveExpense() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || _descriptionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
        return;
    }
    
    final expense = Expense(
      id: const Uuid().v4(),
      amount: amount,
      date: _selectedDate,
      description: _descriptionController.text,
      tagIds: _selectedTags.map((e) => e.id).toList(),
    );
    
    context.read<ExpenseBloc>().add(AddExpenseEvent(expense));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date'),
              trailing: Text(DateFormat.yMMMd().format(_selectedDate)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tags', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add), onPressed: _promptCreateTag),
              ],
            ),
            Wrap(
              spacing: 8.0,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveExpense, 
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
