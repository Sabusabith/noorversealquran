import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashLoaded extends SplashState {
  final String version;

  SplashLoaded(this.version);

  @override
  List<Object?> get props => [version];
}

class SplashCompleted extends SplashState {}
