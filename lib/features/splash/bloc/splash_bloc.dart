import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoading());
    // Get version
    final info = await PackageInfo.fromPlatform();
    final version = "Version ${info.version}";
    emit(SplashLoaded(version));

    await Future.delayed(const Duration(seconds: 4));

    emit(SplashCompleted());
  }
}
