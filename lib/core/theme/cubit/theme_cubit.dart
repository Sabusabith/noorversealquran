import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noorversealquran/utils/components/theme.dart';

class ThemeCubit extends Cubit<AppThemeType> {
  ThemeCubit() : super(AppThemeType.maroonGold);

  void changeTheme(AppThemeType type) {
    emit(type);
  }
}
