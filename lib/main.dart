import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noorversealquran/core/app_snackbar.dart';
import 'package:noorversealquran/core/theme/cubit/theme_cubit.dart';
import 'package:noorversealquran/features/splash/bloc/splash_bloc.dart';
import 'package:noorversealquran/features/splash/bloc/splash_event.dart';
import 'package:noorversealquran/features/splash/presentation/splash.dart';
import 'package:noorversealquran/utils/components/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, AppThemeType>(
        builder: (context, themeType) {
          return MaterialApp(
            themeAnimationDuration: const Duration(milliseconds: 300),
            themeAnimationCurve: Curves.easeInOut,
            scaffoldMessengerKey: AppSnackbar.messengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppThemes.getTheme(themeType),
            home: BlocProvider(
              create: (_) => SplashBloc()..add(SplashStarted()),
              child: const SplashPage(),
            ),
          );
        },
      ),
    );
  }
}
