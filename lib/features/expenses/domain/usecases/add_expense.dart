import 'package:ifinance/core/constants/app_constants.dart';
import 'package:ifinance/core/error/exceptions.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class AddExpense {
  final ExpenseRepository repository;

  AddExpense(this.repository);

  Future<void> call(Expense expense) async {
    if (expense.amount > AppConstants.maxExpenseAmount) {
      throw ExpenseLimitExceededException(
          'Expense amount cannot exceed \$${AppConstants.maxExpenseAmount}');
    }
    return repository.addExpense(expense);
  }
}
