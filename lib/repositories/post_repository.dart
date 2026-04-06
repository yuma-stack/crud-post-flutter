import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class PostRepository {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _endpoint = '/posts';

  final http.Client _client;

  PostRepository({http.Client? client}) : _client = client ?? http.Client();

  // ─── READ ALL ────────────────────────────────────────────────────────────────

  Future<List<Post>> fetchPosts() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl$_endpoint'),
        headers: _headers,
      );
      _checkStatus(response);
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Post.fromJson(json as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw RepositoryException('No internet connection.');
    } on HttpException catch (e) {
      throw RepositoryException('HTTP error: ${e.message}');
    }
  }

  // ─── READ ONE ────────────────────────────────────────────────────────────────

  Future<Post> fetchPostById(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl$_endpoint/$id'),
        headers: _headers,
      );
      _checkStatus(response);
      return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } on SocketException {
      throw RepositoryException('No internet connection.');
    } on HttpException catch (e) {
      throw RepositoryException('HTTP error: ${e.message}');
    }
  }

  // ─── CREATE ──────────────────────────────────────────────────────────────────

  Future<Post> createPost({
    required int userId,
    required String title,
    required String body,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl$_endpoint'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'title': title,
          'body': body,
        }),
      );
      _checkStatus(response);
      return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } on SocketException {
      throw RepositoryException('No internet connection.');
    } on HttpException catch (e) {
      throw RepositoryException('HTTP error: ${e.message}');
    }
  }

  // ─── UPDATE ──────────────────────────────────────────────────────────────────

  Future<Post> updatePost(Post post) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl$_endpoint/${post.id}'),
        headers: _headers,
        body: jsonEncode(post.toJson()),
      );
      _checkStatus(response);
      return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } on SocketException {
      throw RepositoryException('No internet connection.');
    } on HttpException catch (e) {
      throw RepositoryException('HTTP error: ${e.message}');
    }
  }

  // ─── DELETE ──────────────────────────────────────────────────────────────────

  Future<void> deletePost(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl$_endpoint/$id'),
        headers: _headers,
      );
      _checkStatus(response);
    } on SocketException {
      throw RepositoryException('No internet connection.');
    } on HttpException catch (e) {
      throw RepositoryException('HTTP error: ${e.message}');
    }
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
      };

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Status ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }

  void dispose() => _client.close();
}

class RepositoryException implements Exception {
  final String message;
  const RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}