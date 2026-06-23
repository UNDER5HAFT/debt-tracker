import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'blocs/debt_manager/debt_manager_cubit.dart';
import 'blocs/theme/theme_cubit.dart';
import 'services/debt_repository.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => DebtRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DebtManagerCubit(
              context.read<DebtRepository>(),
            ),
          ),
          BlocProvider(
            create: (_) => ThemeCubit(HiveService.settingsBox),
          ),
        ],
        child: const DebtManagerApp(),
      ),
    );
  }
}
