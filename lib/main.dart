import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/notes_bloc.dart';
import 'bloc/notes_event.dart';
import 'bloc/theme_cubit.dart';
import 'data/notes_repository.dart';
import 'ui/notes_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => NotesRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                NotesBloc(context.read<NotesRepository>())..add(LoadNotes()),
          ),
          BlocProvider(create: (_) => ThemeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) => MaterialApp(
            title: 'Notes',
            theme:
                ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
            darkTheme: ThemeData(
              colorSchemeSeed: Colors.indigo,
              brightness: Brightness.dark,
              useMaterial3: true,
            ),
            themeMode: themeMode,
            home: const NotesPage(),
          ),
        ),
      ),
    );
  }
}
