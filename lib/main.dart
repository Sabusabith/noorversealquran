import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noorversealquran/core/app_snackbar.dart';
import 'package:noorversealquran/core/theme/cubit/theme_cubit.dart';
import 'package:noorversealquran/features/splash/bloc/splash_bloc.dart';
import 'package:noorversealquran/features/splash/bloc/splash_event.dart';
import 'package:noorversealquran/features/splash/presentation/splash.dart';
import 'package:noorversealquran/utils/components/theme.dart';
import 'package:noorversealquran/utils/components/theme_local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedTheme = await ThemeLocalStorage.loadTheme();

  runApp(MyApp(initialTheme: savedTheme));
}

class MyApp extends StatelessWidget {
  final AppThemeType initialTheme;

  const MyApp({super.key, required this.initialTheme});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(initialTheme),
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
