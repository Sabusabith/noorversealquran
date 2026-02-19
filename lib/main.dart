import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noorversealquran/core/app_snackbar.dart';
import 'package:noorversealquran/features/splash/bloc/splash_bloc.dart';
import 'package:noorversealquran/features/splash/bloc/splash_event.dart';
import 'package:noorversealquran/features/splash/presentation/splash.dart';
import 'package:noorversealquran/utils/common/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: AppSnackbar.messengerKey,

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kprimeryColor,
        scaffoldBackgroundColor: kbgColor,
        appBarTheme: AppBarTheme(
          backgroundColor: kprimeryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: BlocProvider(
        create: (_) => SplashBloc()..add(SplashStarted()),
        child: SplashPage(),
      ),
    );
  }
}
