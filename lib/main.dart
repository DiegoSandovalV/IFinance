import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/expenses/presentation/bloc/expense_bloc.dart';
import 'features/expenses/presentation/pages/main_page.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<ExpenseBloc>()..add(const LoadExpenses()),
        ),
      ],
      child: MaterialApp(
        title: 'IFinance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainPage(),
      ),
    );
  }
}
