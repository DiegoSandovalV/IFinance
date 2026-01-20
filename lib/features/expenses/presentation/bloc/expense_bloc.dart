import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ifinance/core/error/exceptions.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/tag.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/manage_tags.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpenses getExpenses;
  final AddExpense addExpense;
  final GetTags getTags;
  
  StreamSubscription? _expensesSubscription;
  List<Tag> _tags = [];

  ExpenseBloc({
    required this.getExpenses,
    required this.addExpense,
    required this.getTags,
  }) : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<FilterExpenses>(_onFilterExpenses);
    on<ExpensesUpdated>(_onExpensesUpdated);
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    try {
      _tags = await getTags();
      _expensesSubscription?.cancel();
      _expensesSubscription = getExpenses.watch(startDate: event.startDate, endDate: event.endDate).listen(
        (expenses) => add(ExpensesUpdated(expenses)),
        onError: (error) {
        }
      );
    } catch (e) {
      emit(const ExpenseError('Failed to load initial data'));
    }
  }

  Future<void> _onExpensesUpdated(ExpensesUpdated event, Emitter<ExpenseState> emit) async {
    try {
      _tags = await getTags();
    } catch (_) {
    }
    final total = event.expenses.fold(0.0, (sum, e) => sum + e.amount);
    emit(ExpenseLoaded(expenses: event.expenses, tags: _tags, totalAmount: total));
  }
  

  Future<void> _onAddExpense(AddExpenseEvent event, Emitter<ExpenseState> emit) async {
    try {
      await addExpense(event.expense);
    } on ExpenseLimitExceededException catch (e) {
      emit(ExpenseError(e.message));
    } catch (e) {
      emit(const ExpenseError('Failed to add expense'));
    }
  }

  void _onFilterExpenses(FilterExpenses event, Emitter<ExpenseState> emit) {
     add(LoadExpenses(startDate: event.startDate, endDate: event.endDate));
  }

  @override
  Future<void> close() {
    _expensesSubscription?.cancel();
    return super.close();
  }
}
