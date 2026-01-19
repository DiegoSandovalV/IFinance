import 'package:get_it/get_it.dart';
import 'core/auth/auth_service.dart';
import 'features/expenses/data/datasources/local_data_source.dart';
import 'features/expenses/data/repositories/expense_repository_impl.dart';
import 'features/expenses/domain/repositories/expense_repository.dart';
import 'features/expenses/domain/usecases/add_expense.dart';
import 'features/expenses/domain/usecases/get_expenses.dart';
import 'features/expenses/domain/usecases/manage_tags.dart';
import 'features/expenses/presentation/bloc/expense_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(
    () => ExpenseBloc(
      getExpenses: sl(),
      addExpense: sl(),
      getTags: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetExpenses(sl()));
  sl.registerLazySingleton(() => AddExpense(sl()));
  sl.registerLazySingleton(() => GetTags(sl()));
  sl.registerLazySingleton(() => AddTag(sl()));

  // Repository
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(sl()),
  );

  // Data Sources
  final database = AppDatabase();
  sl.registerLazySingleton(() => database);

  // Core
  sl.registerLazySingleton<AuthService>(() => MockAuthService());
}
