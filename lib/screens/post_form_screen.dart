import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';

/// Used for both Create (post == null) and Update (post != null).
class PostFormScreen extends StatefulWidget {
  final Post? post;

  const PostFormScreen({super.key, this.post});

  bool get isEditing => post != null;

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _bodyController = TextEditingController(text: widget.post?.body ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  // ─── Submit ──────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<PostProvider>();
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (widget.isEditing) {
      final updated = widget.post!.copyWith(title: title, body: body);
      final result = await provider.updatePost(updated);

      if (!mounted) return;
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to update.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      final result = await provider.createPost(title: title, body: body);

      if (!mounted) return;
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to create.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Post' : 'New Post'),
        centerTitle: true,
      ),
      body: Consumer<PostProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header hint
                  if (!widget.isEditing) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(
                          0.4,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'New posts are sent to JSONPlaceholder (mock API) and will appear at the top of your list.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Title field
                  TextFormField(
                    controller: _titleController,
                    enabled: !provider.isMutating,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      hintText: 'Enter a clear, descriptive title',
                      prefixIcon: Icon(Icons.title_rounded),
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 120,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Title is required.';
                      }
                      if (v.trim().length < 3) {
                        return 'Title must be at least 3 characters.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Body field
                  TextFormField(
                    controller: _bodyController,
                    enabled: !provider.isMutating,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 7,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Body *',
                      hintText: 'Write your post content here...',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 100),
                        child: Icon(Icons.article_outlined),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.indigo),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Body is required.';
                      }
                      if (v.trim().length < 10) {
                        return 'Body must be at least 10 characters.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  FilledButton.icon(
                    onPressed: provider.isMutating ? null : _submit,
                    icon: provider.isMutating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            widget.isEditing
                                ? Icons.save_rounded
                                : Icons.send_rounded,
                          ),
                    label: Text(
                      provider.isMutating
                          ? (widget.isEditing ? 'Saving...' : 'Creating...')
                          : (widget.isEditing ? 'Save Changes' : 'Create Post'),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),

                  if (widget.isEditing) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: provider.isMutating
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
