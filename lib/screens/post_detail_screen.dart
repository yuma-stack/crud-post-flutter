import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import 'post_form_screen.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key});

  Future<void> _handleDelete(BuildContext context) async {
    final provider = context.read<PostProvider>();
    final post = provider.selectedPost;
    if (post == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text('Delete "${post.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await provider.deletePost(post.id);
      if (context.mounted) {
        if (success) {
          Navigator.pop(context); // Back to list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post deleted.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to delete.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final ColorScheme = theme.colorScheme;
    return Consumer<PostProvider>(
      builder: (context, provider, _) {
        final post = provider.selectedPost;

        if (post == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('No post selected.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Post Detail'),
            centerTitle: true,
            //  Background Color
            backgroundColor: ColorScheme.surface.withOpacity(0.8),
            actions: [
              // Edit button
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: provider.isMutating
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostFormScreen(post: post),
                          ),
                        );
                      },
              ),
              // Delete button
              IconButton(
                tooltip: 'Delete',
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: ColorScheme.error,
                ),
                onPressed: provider.isMutating
                    ? null
                    : () => _handleDelete(context),
              ),
            ],
          ),
          body: provider.isMutating
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24), 
                  
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meta chip
                      Row(
                        children: [
                          _MetaChip(
                            icon: Icons.tag,
                            label: 'Post #${post.id}',
                            color: ColorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          _MetaChip(
                            icon: Icons.person_outline,
                            label: 'User ${post.userId}',
                            color: ColorScheme.secondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        post.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Divider(),
                      const SizedBox(height: 16),

                      // Body
                      Text(
                        post.body,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.7,
                          color: theme.colorScheme.onSurface.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
