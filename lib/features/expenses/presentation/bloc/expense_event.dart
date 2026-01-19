part of 'expense_bloc.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadExpenses({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class AddExpenseEvent extends ExpenseEvent {
  final Expense expense;

  const AddExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

class FilterExpenses extends ExpenseEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterExpenses({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class ExpensesUpdated extends ExpenseEvent {
  final List<Expense> expenses;

  const ExpensesUpdated(this.expenses);

  @override
  List<Object?> get props => [expenses];
}

