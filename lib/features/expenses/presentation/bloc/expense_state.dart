part of 'expense_bloc.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();
  
  @override
  List<Object> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;
  final List<Tag> tags;
  final double totalAmount;

  const ExpenseLoaded({required this.expenses, required this.tags, required this.totalAmount});

  @override
  List<Object> get props => [expenses, tags, totalAmount];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object> get props => [message];
}
