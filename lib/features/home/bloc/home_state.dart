part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  final List<Surah> allSurahs;
  final List<Surah> filteredSurahs;
  final Map<int, List<Ayah>> quran;
  final bool isSearching;
  final String query;

  const HomeLoaded({
    required this.allSurahs,
    required this.filteredSurahs,
    required this.quran,
    this.isSearching = false,
    this.query = '',
  });

  HomeLoaded copyWith({
    List<Surah>? allSurahs,
    List<Surah>? filteredSurahs,
    Map<int, List<Ayah>>? quran,
    bool? isSearching,
    String? query,
  }) {
    return HomeLoaded(
      allSurahs: allSurahs ?? this.allSurahs,
      filteredSurahs: filteredSurahs ?? this.filteredSurahs,
      quran: quran ?? this.quran,
      isSearching: isSearching ?? this.isSearching,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [
    allSurahs,
    filteredSurahs,
    quran,
    isSearching,
    query,
  ];
}

final class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
