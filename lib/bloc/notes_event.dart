import 'dart:async';
import 'package:equatable/equatable.dart';
import '../models/note.dart';

abstract class NotesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotes extends NotesEvent {
  /// true при обновлении свайпом: список остаётся на экране, без спиннера
  final bool refresh;

  /// Завершается, когда загрузка закончена (нужно для RefreshIndicator)
  final Completer<void>? done;

  LoadNotes({this.refresh = false, this.done});

  @override
  List<Object?> get props => [refresh];
}

class AddNote extends NotesEvent {
  final String title;
  final String body;
  AddNote(this.title, this.body);

  @override
  List<Object?> get props => [title, body];
}

class UpdateNote extends NotesEvent {
  final Note note;
  UpdateNote(this.note);

  @override
  List<Object?> get props => [note];
}

class DeleteNote extends NotesEvent {
  final int id;
  DeleteNote(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleFavorite extends NotesEvent {
  final int id;
  ToggleFavorite(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchNotes extends NotesEvent {
  final String query;
  SearchNotes(this.query);

  @override
  List<Object?> get props => [query];
}
