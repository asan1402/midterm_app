import 'package:flutter_test/flutter_test.dart';
import '../lib/bloc/notes_bloc.dart';
import '../lib/bloc/notes_event.dart';
import '../lib/bloc/notes_state.dart';
import '../lib/data/notes_repository.dart';
import '../lib/models/note.dart';

/// Подмена репозитория: тесты не ходят в интернет
class FakeRepository extends NotesRepository {
  @override
  Future<List<Note>> getNotes() async => const [
        Note(id: 1, title: 'Первая', body: 'текст один'),
        Note(id: 2, title: 'Вторая', body: 'текст два'),
      ];

  @override
  Future<void> createNote(String title, String body) async {}

  @override
  Future<void> updateNote(Note note) async {}

  @override
  Future<void> deleteNote(int id) async {}
}

void main() {
  late NotesBloc bloc;

  setUp(() => bloc = NotesBloc(FakeRepository()));
  tearDown(() => bloc.close());

  test('LoadNotes: сначала loading, потом success со списком', () async {
    expectLater(
      bloc.stream,
      emitsInOrder([
        isA<NotesState>()
            .having((s) => s.status, 'status', NotesStatus.loading),
        isA<NotesState>()
            .having((s) => s.status, 'status', NotesStatus.success)
            .having((s) => s.notes.length, 'notes', 2),
      ]),
    );
    bloc.add(LoadNotes());
  });

  test('AddNote: новая заметка появляется первой с id 101', () async {
    bloc.add(AddNote('Новая', 'текст'));
    final state = await bloc.stream.first;
    expect(state.notes.first.id, 101);
    expect(state.notes.first.title, 'Новая');
  });

  test('SearchNotes: фильтрует по заголовку', () async {
    bloc.add(LoadNotes());
    await bloc.stream.firstWhere((s) => s.status == NotesStatus.success);
    bloc.add(SearchNotes('втор'));
    final state = await bloc.stream.first;
    expect(state.visibleNotes.length, 1);
    expect(state.visibleNotes.first.id, 2);
  });
}
