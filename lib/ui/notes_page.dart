import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../bloc/theme_cubit.dart';
import '../models/note.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _searchCtrl = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  static String _themeTooltip(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Тема: светлая';
      case ThemeMode.dark:
        return 'Тема: тёмная';
      case ThemeMode.system:
        return 'Тема: системная';
    }
  }

  void _toggleSearch() {
    setState(() => _searching = !_searching);
    if (!_searching) {
      _searchCtrl.clear();
      context.read<NotesBloc>().add(SearchNotes(''));
    }
  }

  Future<void> _openEditor({Note? note}) async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (_) => _NoteDialog(note: note),
    );
    if (result == null || !mounted) return;
    final bloc = context.read<NotesBloc>();
    if (note == null) {
      bloc.add(AddNote(result[0], result[1]));
    } else {
      bloc.add(UpdateNote(note.copyWith(title: result[0], body: result[1])));
    }
  }

  Future<void> _confirmDelete(Note note) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить заметку?'),
        content: Text(note.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<NotesBloc>().add(DeleteNote(note.id));
    }
  }

  Future<void> _refresh() {
    final done = Completer<void>();
    context.read<NotesBloc>().add(LoadNotes(refresh: true, done: done));
    return done.future;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotesBloc, NotesState>(
      // SnackBar для ошибок добавления, изменения, удаления и обновления
      listenWhen: (prev, curr) =>
          curr.error != null &&
          curr.status != NotesStatus.failure &&
          curr.error != prev.error,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.error!)));
      },
      child: Scaffold(
        appBar: AppBar(
          title: _searching
              ? BlocBuilder<NotesBloc, NotesState>(
                  buildWhen: (p, c) => p.notes != c.notes || p.query != c.query,
                  builder: (context, state) => TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Поиск...',
                      border: InputBorder.none,
                      suffixText: 'Найдено: ${state.visibleNotes.length}',
                    ),
                    onChanged: (v) =>
                        context.read<NotesBloc>().add(SearchNotes(v)),
                  ),
                )
              : BlocBuilder<NotesBloc, NotesState>(
                  buildWhen: (p, c) => p.notes.length != c.notes.length,
                  builder: (context, state) => Text(state.notes.isEmpty
                      ? 'Заметки'
                      : 'Заметки (${state.notes.length})'),
                ),
          actions: [
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) => IconButton(
                tooltip: _themeTooltip(mode),
                icon: Icon(_themeIcon(mode)),
                onPressed: () => context.read<ThemeCubit>().next(),
              ),
            ),
            IconButton(
              icon: Icon(_searching ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openEditor(),
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {
            if (state.status == NotesStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == NotesStatus.failure && state.notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Ошибка: ${state.error}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<NotesBloc>().add(LoadNotes()),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            }

            final notes = state.visibleNotes;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: notes.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Text(state.notes.isEmpty
                              ? 'Заметок нет'
                              : 'Ничего не найдено'),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return ListTile(
                          leading: IconButton(
                            icon: Icon(
                              note.isFavorite ? Icons.star : Icons.star_border,
                              color: note.isFavorite ? Colors.amber : null,
                            ),
                            onPressed: () => context
                                .read<NotesBloc>()
                                .add(ToggleFavorite(note.id)),
                          ),
                          title: Text(note.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(note.body,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          onTap: () => _openEditor(note: note),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDelete(note),
                          ),
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}

/// Диалог создания/редактирования. Контроллеры освобождаются в dispose().
class _NoteDialog extends StatefulWidget {
  final Note? note;
  const _NoteDialog({this.note});

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.note?.body ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Введите заголовок');
      return;
    }
    Navigator.pop(context, [title, _bodyCtrl.text.trim()]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.note == null ? 'Новая заметка' : 'Редактировать'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Заголовок',
                errorText: _titleError,
              ),
            ),
            TextField(
              controller: _bodyCtrl,
              decoration: const InputDecoration(labelText: 'Текст'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(onPressed: _save, child: const Text('Сохранить')),
      ],
    );
  }
}
