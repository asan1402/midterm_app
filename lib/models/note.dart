import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final int id;
  final String title;
  final String body;
  // Хранится только в приложении, на сервер не отправляется
  final bool isFavorite;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    this.isFavorite = false,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as int,
        title: json['title'] as String,
        body: json['body'] as String,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'body': body, 'userId': 1};

  Note copyWith({int? id, String? title, String? body, bool? isFavorite}) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  @override
  List<Object?> get props => [id, title, body, isFavorite];
}
