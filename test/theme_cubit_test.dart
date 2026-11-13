import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/bloc/theme_cubit.dart';

void main() {
  test('ThemeCubit.next: system → light → dark → system', () {
    final cubit = ThemeCubit();
    expect(cubit.state, ThemeMode.system);

    cubit.next();
    expect(cubit.state, ThemeMode.light);

    cubit.next();
    expect(cubit.state, ThemeMode.dark);

    cubit.next();
    expect(cubit.state, ThemeMode.system);

    cubit.close();
  });

  test('ThemeCubit.setMode задаёт режим напрямую', () {
    final cubit = ThemeCubit();
    cubit.setMode(ThemeMode.dark);
    expect(cubit.state, ThemeMode.dark);
    cubit.close();
  });
}
