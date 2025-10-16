# ⚡ Quick Start - Winter Arc Community PWA

## 🎯 What Was Built

Complete community PWA with:
- ✅ Real-time community feed (posts auto-update)
- ✅ Create posts with image upload
- ✅ Comment system with replies
- ✅ Like/unlike posts
- ✅ PWA install prompts (install as app on any device)
- ✅ Supabase database schema with RLS security
- ✅ Winter Arc brutal design aesthetic

## 🚀 Deploy in 5 Minutes

### 1. Install Dependencies
```bash
cd frontend
flutter pub get
```

### 2. Apply Database Migration

Copy `backend/db/schema/0002_community.sql` to Supabase SQL Editor and run it.

**Then enable real-time:**
```sql
alter publication supabase_realtime add table posts;
alter publication supabase_realtime add table community_comments;
alter publication supabase_realtime add table community_likes;
```

### 3. Add Routes to Router

Find your router file and add:
```dart
import 'package:alphagrit/features/community/community_feed_screen.dart';
import 'package:alphagrit/features/community/create_post_screen.dart';
import 'package:alphagrit/features/community/post_detail_screen.dart';

// Add these routes:
GoRoute(
  path: '/community/feed',
  builder: (context, state) => CommunityFeedScreen(
    programId: int.parse(state.uri.queryParameters['programId'] ?? '1'),
    programTitle: state.uri.queryParameters['programTitle'] ?? 'Winter Arc',
  ),
),
GoRoute(
  path: '/community/create-post',
  builder: (context, state) => CreatePostScreen(
    programId: int.parse(state.uri.queryParameters['programId'] ?? '1'),
  ),
),
GoRoute(
  path: '/community/post/:postId',
  builder: (context, state) => PostDetailScreen(
    postId: int.parse(state.pathParameters['postId']!),
  ),
),
```

### 4. Link from Winter Arc Success Page

Update `checkout_success_screen.dart` to navigate to community:
```dart
onPressed: () => context.push('/community/feed?programId=1&programTitle=Winter Arc'),
```

### 5. Deploy to Vercel

```bash
git add .
git commit -m "Add Winter Arc community features"
git push origin main
```

Done! Vercel will auto-deploy.

## 📁 New Files Created

```
frontend/
├── lib/
│   ├── domain/models/
│   │   └── community.dart              # Post, Comment, Like models
│   ├── data/repositories/
│   │   └── community_repository.dart    # Supabase operations
│   ├── features/
│   │   ├── community/
│   │   │   ├── community_controller.dart    # Riverpod state management
│   │   │   ├── community_feed_screen.dart   # Main feed with real-time
│   │   │   ├── create_post_screen.dart      # Post creation + image upload
│   │   │   └── post_detail_screen.dart      # Post view + comments
│   │   └── home/
│   │       └── pwa_install_prompt.dart      # Install app banner
│   └── web/
│       ├── manifest.json                # PWA configuration (updated)
│       └── index.html                   # PWA meta tags (updated)
└── pubspec.yaml                         # Added timeago package

backend/
└── db/
    ├── schema/
    │   └── 0002_community.sql           # Database migration
    └── README.md                        # Database setup guide
```

## 🔧 Stripe Webhook Update

In your backend webhook handler, after successful Winter Arc purchase:

```python
# Get Winter Arc program
program = supabase.table('programs').select('id').eq('slug', 'winter-arc').single().execute()

# Grant user access
supabase.table('user_programs').insert({
    'user_id': user_id,
    'program_id': program.data['id']
}).execute()
```

## ✅ Test Locally

```bash
flutter run -d chrome --web-renderer canvaskit
```

Navigate to: `http://localhost:PORT/community/feed?programId=1&programTitle=Winter%20Arc`

## 📊 What Users Will See

1. **Community Feed:** Scroll of posts with images, likes, comment counts
2. **Create Post:** Title + message + image upload
3. **Post Detail:** Full post with comments, like button
4. **PWA Prompt:** Banner explaining how to install as app
5. **Real-time Updates:** New posts/comments appear instantly

## 🎨 Branding

- Frost Blue (#4A90E2) - Primary actions
- Steel Blue (#1E3A5F) - Backgrounds
- Muted Orange (#D97B3A) - Pinned posts
- Bebas Neue font for headers (UPPERCASE, letter-spacing: 2)
- Brutalist design with thick borders

## 🔒 Security

All handled via Supabase RLS:
- Users only see posts in programs they joined
- Users only create posts in their programs
- Image uploads scoped to `community/{user_id}/`

## 📱 PWA Install

Works on:
- iOS Safari: Share → Add to Home Screen
- Android Chrome: Menu → Install App
- Desktop: Install icon in address bar

## 🐛 Common Issues

**"No posts showing"**
→ Grant yourself access to Winter Arc:
```sql
INSERT INTO user_programs (user_id, program_id)
VALUES ('YOUR_UUID', (SELECT id FROM programs WHERE slug = 'winter-arc'));
```

**"Failed to upload image"**
→ Check Supabase Storage has `community` bucket with public access policies.

**"Real-time not working"**
→ Verify replication is enabled for all 3 tables.

## 📞 Full Documentation

See `WINTER_ARC_COMMUNITY_SETUP.md` for complete guide with troubleshooting, monitoring, and post-launch roadmap.

---

**Launch Date:** November 17, 2025
**Program Duration:** 12 weeks (Nov 17 - Feb 9, 2026)
**Estimated Setup Time:** 30-45 minutes

**Built with Claude Code** 🤖
