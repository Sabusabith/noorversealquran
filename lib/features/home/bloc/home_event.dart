part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

// Load all Quran data
class LoadQuranData extends HomeEvent {}

// Toggle search bar
class ToggleSearch extends HomeEvent {}

// Update search query
class SearchTextChanged extends HomeEvent {
  final String query;

  const SearchTextChanged(this.query);

  @override
  List<Object?> get props => [query];
}
