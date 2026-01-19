import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ifinance/core/error/exceptions.dart';
import 'package:ifinance/core/constants/app_constants.dart';
import 'package:ifinance/features/expenses/domain/entities/expense.dart';
import 'package:ifinance/features/expenses/domain/repositories/expense_repository.dart';
import 'package:ifinance/features/expenses/domain/usecases/add_expense.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}
class FakeExpense extends Fake implements Expense {}

void main() {
  late AddExpense usecase;
  late MockExpenseRepository mockExpenseRepository;

  setUpAll(() {
    registerFallbackValue(FakeExpense());
  });

  setUp(() {
    mockExpenseRepository = MockExpenseRepository();
    usecase = AddExpense(mockExpenseRepository);
  });

  final tExpense = Expense(
    id: '1',
    amount: 100.0,
    date: DateTime.now(),
    description: 'Test',
    tagIds: const [],
  );

  test('should call addExpense on repository when amount is within limit', () async {
    // arrange
    when(() => mockExpenseRepository.addExpense(any())).thenAnswer((_) async => {});
    
    // act
    await usecase(tExpense);
    
    // assert
    verify(() => mockExpenseRepository.addExpense(tExpense)).called(1);
  });

  test('should throw ExpenseLimitExceededException when amount exceeds limit', () async {
    // arrange
    final expensiveExpense = Expense(
      id: '2',
      amount: AppConstants.maxExpenseAmount + 1,
      date: DateTime.now(),
      description: 'Too expensive',
      tagIds: const [],
    );
    
    // act
    final call = usecase(expensiveExpense);
    
    // assert
    expect(call, throwsA(isA<ExpenseLimitExceededException>()));
    verifyZeroInteractions(mockExpenseRepository);
  });
}
