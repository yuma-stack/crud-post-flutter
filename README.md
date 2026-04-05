# flutter_provider_app — Full CRUD with Provider

A Flutter app demonstrating **Create, Read, Update, Delete** operations using the `provider` package and the [JSONPlaceholder](https://jsonplaceholder.typicode.com) REST API.

---

## Architecture

```
lib/
├── models/
│   └── post.dart              # Immutable Post model with copyWith & fromJson/toJson
├── repositories/
│   └── post_repository.dart   # All HTTP calls (GET, POST, PUT, DELETE)
├── providers/
│   └── post_provider.dart     # State management — holds list, selected post, status
├── screens/
│   ├── post_list_screen.dart  # List with swipe-to-delete, FAB to create
│   ├── post_detail_screen.dart# Full post view with edit & delete actions
│   └── post_form_screen.dart  # Shared form for Create and Edit
└── main.dart                  # ChangeNotifierProvider + MaterialApp
```

### Data flow

```
Screen  ──read──▶  PostProvider  ──calls──▶  PostRepository  ──HTTP──▶  API
Screen  ◀─listen─  PostProvider  ◀─returns─  PostRepository  ◀─JSON──   API
```

---

## CRUD operations

| Action | Repository method | Provider method | Screen |
|--------|-------------------|-----------------|--------|
| List all | `fetchPosts()` | `fetchPosts()` | `PostListScreen` |
| View one | `fetchPostById(id)` | `selectPost(post)` | `PostDetailScreen` |
| Create | `createPost(...)` | `createPost(...)` | `PostFormScreen` |
| Update | `updatePost(post)` | `updatePost(post)` | `PostFormScreen` |
| Delete | `deletePost(id)` | `deletePost(id)` | List (swipe) / Detail |

---

## Getting started

```bash
flutter pub get
flutter run
```

### Run tests

```bash
# Generate mocks first
dart run build_runner build --delete-conflicting-outputs

# Then run tests
flutter test
```

---

## Key design decisions

- **`PostStatus` enum** — `idle | loading | success | failure` — separates list-loading from mutation loading via `isMutating`.
- **`copyWith`** on `Post` — makes immutable updates clean in the form screen.
- **Optimistic-style local updates** — provider updates `_posts` immediately after a successful API call without re-fetching the whole list.
- **`Dismissible` swipe-to-delete** — with confirmation dialog before any destructive action.
- **Shared `PostFormScreen`** — detects edit vs create via the nullable `post` parameter.
