import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noorversealquran/utils/components/theme.dart';
import 'package:noorversealquran/utils/components/theme_local_storage.dart';

class ThemeCubit extends Cubit<AppThemeType> {
  ThemeCubit(AppThemeType initialTheme) : super(initialTheme);

  Future<void> changeTheme(AppThemeType type) async {
    emit(type);
    await ThemeLocalStorage.saveTheme(type);
  }
}
