import 'package:dio/dio.dart';
import '../models/note.dart';

/// Понятная пользователю ошибка (вместо технического текста DioException)
class NotesException implements Exception {
  final String message;
  const NotesException(this.message);

  @override
  String toString() => message;
}

class NotesRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          throw const NotesException('Нет соединения с сервером');
        case DioExceptionType.badResponse:
          throw NotesException('Ошибка сервера (${e.response?.statusCode})');
        default:
          throw const NotesException('Не удалось выполнить запрос');
      }
    }
  }

  Future<List<Note>> getNotes() => _guard(() async {
        final response =
            await _dio.get('/posts', queryParameters: {'_limit': 15});
        return (response.data as List).map((e) => Note.fromJson(e)).toList();
      });

  Future<void> createNote(String title, String body) => _guard(() async {
        await _dio
            .post('/posts', data: {'title': title, 'body': body, 'userId': 1});
      });

  Future<void> updateNote(Note note) => _guard(() async {
        // Сервер знает только заметки с id до 100, для новых запрос не нужен
        if (note.id > 100) return;
        await _dio.put('/posts/${note.id}', data: note.toJson());
      });

  Future<void> deleteNote(int id) => _guard(() async {
        if (id > 100) return;
        await _dio.delete('/posts/$id');
      });
}
