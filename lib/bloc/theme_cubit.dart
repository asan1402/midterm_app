import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit: упрощённый Bloc без событий, состояние меняется вызовом метода.
/// Состояние здесь это режим темы: системная, светлая или тёмная.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void setMode(ThemeMode mode) => emit(mode);

  /// Системная → светлая → тёмная → системная
  void next() {
    switch (state) {
      case ThemeMode.system:
        emit(ThemeMode.light);
        break;
      case ThemeMode.light:
        emit(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        emit(ThemeMode.system);
        break;
    }
  }
}
