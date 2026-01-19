import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifinance/features/expenses/presentation/pages/add_expense_page.dart';
import 'package:ifinance/features/expenses/domain/usecases/manage_tags.dart';
import 'package:ifinance/features/expenses/presentation/bloc/expense_bloc.dart';


class MockGetTags extends Mock implements GetTags {}
class MockExpenseBloc extends Mock implements ExpenseBloc {}

// Fake Event
class FakeExpenseEvent extends Fake implements ExpenseEvent {}

void main() {
  late MockGetTags mockGetTags;
  late MockExpenseBloc mockExpenseBloc;

  setUpAll(() {
    registerFallbackValue(FakeExpenseEvent());
  });

  setUp(() {
    mockGetTags = MockGetTags();
    mockExpenseBloc = MockExpenseBloc();
    final sl = GetIt.instance;
    if (!sl.isRegistered<GetTags>()) {
      sl.registerSingleton<GetTags>(mockGetTags);
    }
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  testWidgets('AddExpensePage shows all fields', (WidgetTester tester) async {
    when(() => mockGetTags()).thenAnswer((_) async => []);
    // Stub stream for BlocProvider (it might subscribe)
    when(() => mockExpenseBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockExpenseBloc.state).thenReturn(ExpenseInitial());
    when(() => mockExpenseBloc.close()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ExpenseBloc>.value(
          value: mockExpenseBloc,
          child: const AddExpensePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Tags'), findsOneWidget);
  });
}
