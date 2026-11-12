import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/notes_bloc.dart';
import 'bloc/notes_event.dart';
import 'data/notes_repository.dart';
import 'ui/notes_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => NotesRepository(),
      child: BlocProvider(
        create: (context) =>
            NotesBloc(context.read<NotesRepository>())..add(LoadNotes()),
        child: MaterialApp(
          title: 'Notes',
          theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: const NotesPage(),
        ),
      ),
    );
  }
}
