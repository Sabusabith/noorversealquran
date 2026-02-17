import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:noorversealquran/data/model/ayah_model.dart';
import 'package:noorversealquran/features/home/data/model/surah_model.dart.dart';

import '../data/repository/home_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final QuranRepository repository;

  HomeBloc(this.repository) : super(const HomeInitial()) {
    on<LoadQuranData>(_onLoadQuranData);
    on<ToggleSearch>(_onToggleSearch);
    on<SearchTextChanged>(_onSearchTextChanged);
  }

  Future<void> _onLoadQuranData(
    LoadQuranData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final surahs = await repository.loadSurahMeta();
      final quran = await repository.loadQuranAyahs();

      emit(HomeLoaded(allSurahs: surahs, filteredSurahs: surahs, quran: quran));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  void _onToggleSearch(ToggleSearch event, Emitter<HomeState> emit) {
    final current = state;
    if (current is HomeLoaded) {
      emit(
        current.copyWith(
          isSearching: !current.isSearching,
          query: !current.isSearching ? '' : current.query,
          filteredSurahs: !current.isSearching
              ? current.allSurahs
              : current.filteredSurahs,
        ),
      );
    }
  }

  void _onSearchTextChanged(SearchTextChanged event, Emitter<HomeState> emit) {
    final current = state;
    if (current is HomeLoaded) {
      final filtered = current.allSurahs
          .where(
            (s) =>
                s.nameEn.toLowerCase().contains(event.query.toLowerCase()) ||
                s.nameAr.toLowerCase().contains(event.query.toLowerCase()),
          )
          .toList();

      emit(current.copyWith(filteredSurahs: filtered, query: event.query));
    }
  }
}
