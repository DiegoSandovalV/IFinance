import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/tag.dart';
import '../../domain/usecases/manage_tags.dart';
import '../bloc/expense_bloc.dart';
import '../../../../../injection_container.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../../../core/constants/app_constants.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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
    int selectedColorValue = 0xFF9E9E9E;
    
    final List<int> colors = [
      0xFFF44336,
      0xFFE91E63,
      0xFF9C27B0,
      0xFF673AB7,
      0xFF3F51B5,
      0xFF2196F3,
      0xFF00BCD4,
      0xFF009688,
      0xFF4CAF50,
      0xFFFFEB3B,
      0xFFFF9800,
      0xFF795548,
    ];

    final Tag? newTag = await showDialog<Tag>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                maxLength: 30,
                decoration: const InputDecoration(
                  labelText: 'Tag Name',
                  hintText: 'e.g. Food, Travel',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select Color'),
              const SizedBox(height: 8),
              SizedBox(
                width: 300,
                height: 150,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final colorValue = colors[index];
                    final isSelected = selectedColorValue == colorValue;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColorValue = colorValue),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(colorValue),
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tag name cannot be empty')),
                  );
                  return;
                }
                Navigator.pop(context, Tag(id: const Uuid().v4(), name: name, colorValue: selectedColorValue));
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    
    if (newTag != null) {
      await sl<AddTag>()(newTag);
      _loadTags();
    }
  }

  Future<void> _confirmDeleteTag(Tag tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text('Are you sure you want to delete "${tag.name}"? This will uncategorize expenses with this tag.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await sl<ExpenseRepository>().deleteTag(tag.id);
      _loadTags();
      setState(() {
        _selectedTags.removeWhere((t) => t.id == tag.id);
      });
    }
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_amountController.text);
    final description = _descriptionController.text;
    if (amount == null|| description.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
        return;
    }

    if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Amount must be greater than 0')));
        return;
    }

    if (description.length > 100) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Description must be at most 100 characters long')));
        return;
    }
    
    final expense = Expense(
      id: const Uuid().v4(),
      amount: amount,
      date: _selectedDate,
      description: description,
      tagIds: _selectedTags.map((e) => e.id).toList(),
    );
    
    context.read<ExpenseBloc>().add(AddExpenseEvent(expense));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Please enter a valid number';
                  }
                  if (amount > AppConstants.maxExpenseAmount) {
                    return 'Amount exceeds limit of \$${AppConstants.maxExpenseAmount}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What was this expense for?',
                ),
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
                  final isSelected = _selectedTags.any((t) => t.id == tag.id);
                  return GestureDetector(
                    onLongPress: () => _confirmDeleteTag(tag),
                    child: FilterChip(
                      label: Text(tag.name),
                      selected: isSelected,
                      selectedColor: Color(tag.colorValue).withOpacity(0.3),
                      checkmarkColor: Color(tag.colorValue),
                      labelStyle: TextStyle(
                        color: isSelected ? Color(tag.colorValue) : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            if (_selectedTags.length >= 3) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Maximum 3 tags per expense allowed.'))
                               );
                               return;
                            }
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.removeWhere((t) => t.id == tag.id);
                          }
                        });
                      },
                    ),
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
      ),
    );
  }
}
