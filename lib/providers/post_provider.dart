import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';

enum PostStatus { idle, loading, success, failure }

class PostProvider extends ChangeNotifier {
  final PostRepository _repository;

  PostProvider({PostRepository? repository})
      : _repository = repository ?? PostRepository();

  // ─── State ───────────────────────────────────────────────────────────────────

  List<Post> _posts = [];
  Post? _selectedPost;
  PostStatus _status = PostStatus.idle;
  String? _errorMessage;

  // Whether a specific mutation (create / update / delete) is in progress
  bool _isMutating = false;

  // ─── Getters ─────────────────────────────────────────────────────────────────

  List<Post> get posts => List.unmodifiable(_posts);
  Post? get selectedPost => _selectedPost;
  PostStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == PostStatus.loading;
  bool get isMutating => _isMutating;
  bool get hasError => _status == PostStatus.failure;

  // ─── READ ALL ────────────────────────────────────────────────────────────────

  Future<void> fetchPosts() async {
    _setStatus(PostStatus.loading);
    try {
      _posts = await _repository.fetchPosts();
      _setStatus(PostStatus.success);
    } on RepositoryException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('An unexpected error occurred.');
    }
  }

  // ─── READ ONE ────────────────────────────────────────────────────────────────

  Future<void> fetchPostById(int id) async {
    _setStatus(PostStatus.loading);
    try {
      _selectedPost = await _repository.fetchPostById(id);
      _setStatus(PostStatus.success);
    } on RepositoryException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('An unexpected error occurred.');
    }
  }

  void selectPost(Post post) {
    _selectedPost = post;
    notifyListeners();
  }

  void clearSelectedPost() {
    _selectedPost = null;
    notifyListeners();
  }

  // ─── CREATE ──────────────────────────────────────────────────────────────────

  /// Returns the created [Post] on success, or null on failure.
  Future<Post?> createPost({
    required String title,
    required String body,
    int userId = 1,
  }) async {
    _startMutation();
    try {
      final newPost = await _repository.createPost(
        userId: userId,
        title: title,
        body: body,
      );
      // JSONPlaceholder returns id: 101 for all creates; prepend to list.
      _posts = [newPost, ..._posts];
      _setStatus(PostStatus.success);
      return newPost;
    } on RepositoryException catch (e) {
      _setError(e.message);
      return null;
    } catch (_) {
      _setError('Failed to create post.');
      return null;
    } finally {
      _stopMutation();
    }
  }

  // ─── UPDATE ──────────────────────────────────────────────────────────────────

  /// Returns the updated [Post] on success, or null on failure.
  Future<Post?> updatePost(Post post) async {
    _startMutation();
    try {
      final updated = await _repository.updatePost(post);
      _posts = [
        for (final p in _posts) p.id == updated.id ? updated : p,
      ];
      if (_selectedPost?.id == updated.id) _selectedPost = updated;
      _setStatus(PostStatus.success);
      return updated;
    } on RepositoryException catch (e) {
      _setError(e.message);
      return null;
    } catch (_) {
      _setError('Failed to update post.');
      return null;
    } finally {
      _stopMutation();
    }
  }

  // ─── DELETE ──────────────────────────────────────────────────────────────────

  /// Returns true on success.
  Future<bool> deletePost(int id) async {
    _startMutation();
    try {
      await _repository.deletePost(id);
      _posts = _posts.where((p) => p.id != id).toList();
      if (_selectedPost?.id == id) _selectedPost = null;
      _setStatus(PostStatus.success);
      return true;
    } on RepositoryException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Failed to delete post.');
      return false;
    } finally {
      _stopMutation();
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    if (_status == PostStatus.failure) _status = PostStatus.idle;
    notifyListeners();
  }

  void _setStatus(PostStatus s) {
    _status = s;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = PostStatus.failure;
    _errorMessage = message;
    notifyListeners();
  }

  void _startMutation() {
    _isMutating = true;
    notifyListeners();
  }

  void _stopMutation() {
    _isMutating = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}