class ReaderSettingsState {
  final double arabicFontSize;
  final double translationFontSize;

  const ReaderSettingsState({
    required this.arabicFontSize,
    required this.translationFontSize,
  });

  ReaderSettingsState copyWith({
    double? arabicFontSize,
    double? translationFontSize,
  }) {
    return ReaderSettingsState(
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
    );
  }
}
