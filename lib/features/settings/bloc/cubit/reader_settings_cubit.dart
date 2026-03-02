import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noorversealquran/features/settings/repo/reder_settings_storage.dart';
import 'reader_settings_state.dart';

class ReaderSettingsCubit extends Cubit<ReaderSettingsState> {
  ReaderSettingsCubit()
    : super(
        const ReaderSettingsState(arabicFontSize: 24, translationFontSize: 13),
      );

  Future<void> load() async {
    final arabic = await ReaderSettingsStorage.loadArabicSize();
    final translation = await ReaderSettingsStorage.loadTranslationSize();

    emit(
      ReaderSettingsState(
        arabicFontSize: arabic,
        translationFontSize: translation,
      ),
    );
  }

  Future<void> updateArabic(double size) async {
    await ReaderSettingsStorage.saveArabicSize(size);
    emit(state.copyWith(arabicFontSize: size));
  }

  Future<void> updateTranslation(double size) async {
    await ReaderSettingsStorage.saveTranslationSize(size);
    emit(state.copyWith(translationFontSize: size));
  }
}
