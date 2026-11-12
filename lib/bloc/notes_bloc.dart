import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/notes_repository.dart';
import '../models/note.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepository repository;

  NotesBloc(this.repository) : super(const NotesState()) {
    on<LoadNotes>(_onLoad);
    on<AddNote>(_onAdd);
    on<UpdateNote>(_onUpdate);
    on<DeleteNote>(_onDelete);
    on<ToggleFavorite>(_onToggleFavorite);
    on<SearchNotes>(_onSearch);
  }

  String _message(Object e) =>
      e is NotesException ? e.message : 'Что-то пошло не так';

  // Сбрасываем старую ошибку, чтобы одинаковая ошибка снова показалась
  void _clearError(Emitter<NotesState> emit) {
    if (state.error != null) emit(state.copyWith());
  }

  Future<void> _onLoad(LoadNotes event, Emitter<NotesState> emit) async {
    if (event.refresh) {
      _clearError(emit);
    } else {
      emit(state.copyWith(status: NotesStatus.loading));
    }
    try {
      final notes = await repository.getNotes();
      emit(state.copyWith(status: NotesStatus.success, notes: notes));
    } catch (e) {
      emit(state.copyWith(
        // при обновлении свайпом список остаётся, ошибка уйдёт в SnackBar
        status: event.refresh ? NotesStatus.success : NotesStatus.failure,
        error: _message(e),
      ));
    } finally {
      event.done?.complete();
    }
  }

  Future<void> _onAdd(AddNote event, Emitter<NotesState> emit) async {
    _clearError(emit);
    try {
      await repository.createNote(event.title, event.body);
      // Сервер всегда возвращает id 101, поэтому выдаём свой уникальный id
      final newId = state.notes.isEmpty
          ? 1
          : state.notes.map((n) => n.id).reduce((a, b) => a > b ? a : b) + 1;
      final note = Note(
        id: newId < 101 ? 101 : newId,
        title: event.title,
        body: event.body,
      );
      emit(state.copyWith(
        status: NotesStatus.success,
        notes: [note, ...state.notes],
      ));
    } catch (e) {
      emit(state.copyWith(error: _message(e)));
    }
  }

  Future<void> _onUpdate(UpdateNote event, Emitter<NotesState> emit) async {
    _clearError(emit);
    try {
      await repository.updateNote(event.note);
      final notes = state.notes
          .map((n) => n.id == event.note.id ? event.note : n)
          .toList();
      emit(state.copyWith(status: NotesStatus.success, notes: notes));
    } catch (e) {
      emit(state.copyWith(error: _message(e)));
    }
  }

  Future<void> _onDelete(DeleteNote event, Emitter<NotesState> emit) async {
    _clearError(emit);
    try {
      await repository.deleteNote(event.id);
      final notes = state.notes.where((n) => n.id != event.id).toList();
      emit(state.copyWith(status: NotesStatus.success, notes: notes));
    } catch (e) {
      emit(state.copyWith(error: _message(e)));
    }
  }

  // Избранное хранится только в приложении, запрос к серверу не нужен
  void _onToggleFavorite(ToggleFavorite event, Emitter<NotesState> emit) {
    final notes = state.notes
        .map((n) => n.id == event.id ? n.copyWith(isFavorite: !n.isFavorite) : n)
        .toList();
    emit(state.copyWith(notes: notes));
  }

  void _onSearch(SearchNotes event, Emitter<NotesState> emit) {
    emit(state.copyWith(query: event.query));
  }
}
