import 'package:equatable/equatable.dart';
import '../models/note.dart';

enum NotesStatus { initial, loading, success, failure }

class NotesState extends Equatable {
  final NotesStatus status;
  final List<Note> notes;
  final String? error;
  final String query;

  const NotesState({
    this.status = NotesStatus.initial,
    this.notes = const [],
    this.error,
    this.query = '',
  });

  /// Заметки с учётом поиска; избранные идут первыми
  List<Note> get visibleNotes {
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? notes
        : notes
            .where((n) =>
                n.title.toLowerCase().contains(q) ||
                n.body.toLowerCase().contains(q))
            .toList();
    return [
      ...filtered.where((n) => n.isFavorite),
      ...filtered.where((n) => !n.isFavorite),
    ];
  }

  // error сбрасывается в null, если его не передать
  NotesState copyWith({
    NotesStatus? status,
    List<Note>? notes,
    String? error,
    String? query,
  }) =>
      NotesState(
        status: status ?? this.status,
        notes: notes ?? this.notes,
        error: error,
        query: query ?? this.query,
      );

  @override
  List<Object?> get props => [status, notes, error, query];
}
