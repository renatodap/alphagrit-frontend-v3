# Winter Arc Community - Implementation Guide

## 🎯 Overview

This guide covers setting up the Winter Arc PWA with full community features by November 17th.

**What's Been Built:**
- ✅ PWA manifest and meta tags (install as app on iOS/Android)
- ✅ Supabase community database schema (posts, comments, likes)
- ✅ Community feed with real-time updates
- ✅ Create post screen with image upload
- ✅ Post detail with commenting system
- ✅ PWA install prompts

**What's Left:**
1. Run `flutter pub get` to install new dependencies
2. Apply database migration to Supabase
3. Update router to add new screens
4. Update Stripe webhook to grant community access
5. Deploy to Vercel

---

## 📋 Step-by-Step Implementation

### Step 1: Install Dependencies (2 minutes)

```bash
cd frontend
flutter pub get
```

New package added:
- `timeago: ^3.7.0` - For "2 hours ago" timestamps

### Step 2: Apply Supabase Database Migration (5 minutes)

1. Go to [Supabase Dashboard](https://app.supabase.com) → Your Project
2. Navigate to **SQL Editor**
3. Copy the entire contents of `backend/db/schema/0002_community.sql`
4. Paste into SQL editor and click **Run**
5. Verify tables were created:
   ```sql
   SELECT * FROM programs WHERE slug = 'winter-arc';
   ```

6. **IMPORTANT**: Enable real-time replication:
   - Go to **Database > Replication**
   - Enable these tables:
     - `posts`
     - `community_comments`
     - `community_likes`

   Or run this SQL:
   ```sql
   alter publication supabase_realtime add table posts;
   alter publication supabase_realtime add table community_comments;
   alter publication supabase_realtime add table community_likes;
   ```

### Step 3: Update Router (10 minutes)

Find your `router.dart` or `app_router.dart` file and add these routes:

```dart
import 'package:alphagrit/features/community/community_feed_screen.dart';
import 'package:alphagrit/features/community/create_post_screen.dart';
import 'package:alphagrit/features/community/post_detail_screen.dart';

// Add these routes to your GoRouter configuration:

GoRoute(
  path: '/community/feed',
  builder: (context, state) {
    final programId = int.parse(state.uri.queryParameters['programId'] ?? '1');
    final programTitle = state.uri.queryParameters['programTitle'] ?? 'Winter Arc';
    return CommunityFeedScreen(
      programId: programId,
      programTitle: programTitle,
    );
  },
),

GoRoute(
  path: '/community/create-post',
  builder: (context, state) {
    final programId = int.parse(state.uri.queryParameters['programId'] ?? '1');
    return CreatePostScreen(programId: programId);
  },
),

GoRoute(
  path: '/community/post/:postId',
  builder: (context, state) {
    final postId = int.parse(state.pathParameters['postId']!);
    return PostDetailScreen(postId: postId);
  },
),
```

### Step 4: Add PWA Install Prompt to Home Screen (5 minutes)

Update your home screen or landing page to show the install prompt:

```dart
import 'package:alphagrit/features/home/pwa_install_prompt.dart';

// In your home screen widget:
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        // Your existing home screen content

        // Add this at the bottom:
        const PWAInstallPrompt(),
      ],
    ),
  );
}
```

### Step 5: Update Winter Arc Landing to Link to Community (5 minutes)

Update `lib/features/winter_arc/winter_arc_landing.dart`:

After the checkout success, add a button to access community:

```dart
ElevatedButton(
  onPressed: () {
    // Get Winter Arc program ID (you'll need to fetch this)
    context.push('/community/feed?programId=1&programTitle=Winter Arc');
  },
  child: const Text('JOIN COMMUNITY'),
),
```

### Step 6: Update Stripe Webhook for Community Access (Backend)

**Location:** `backend/app/api/webhooks/stripe_webhook.py` (or similar)

When a Winter Arc purchase succeeds, grant access to the program:

```python
# After successful payment for Winter Arc
if product_id == 'winter_arc' or ebook_slug == 'winter-arc':
    # Get Winter Arc program ID
    program = supabase.table('programs').select('id').eq('slug', 'winter-arc').single().execute()
    program_id = program.data['id']

    # Grant user access to Winter Arc program
    supabase.table('user_programs').insert({
        'user_id': user_id,
        'program_id': program_id
    }).execute()
```

### Step 7: Test Locally (10 minutes)

```bash
cd frontend
flutter run -d chrome --web-renderer canvaskit
```

**Test Checklist:**
- [ ] Can navigate to community feed
- [ ] Can create a post with image upload
- [ ] Can view post details
- [ ] Can add comments
- [ ] Can like posts
- [ ] PWA install prompt shows on web
- [ ] Real-time updates work (open in two tabs, post in one, see in other)

### Step 8: Deploy to Vercel (5 minutes)

```bash
cd frontend
git add .
git commit -m "Add Winter Arc community PWA features

- Community feed with real-time posts
- Create post with image upload
- Comments system
- Like/unlike posts
- PWA manifest and install prompts
- Supabase integration"

git push origin main
```

Vercel will auto-deploy. Monitor at:
- Dashboard: https://vercel.com/dashboard
- Live site: https://alphagrit-frontent.vercel.app

**If cache issues:**
1. Go to Vercel dashboard
2. Click "Redeploy"
3. Uncheck "Use existing Build Cache"

---

## 🗄️ Database Schema Reference

### Tables Created

**community_comments**
```
id                SERIAL PRIMARY KEY
post_id           INTEGER → posts.id
user_id           UUID → auth.users.id
content           TEXT
parent_comment_id INTEGER (for nested replies)
created_at        TIMESTAMP
updated_at        TIMESTAMP
```

**community_likes**
```
id         SERIAL PRIMARY KEY
post_id    INTEGER → posts.id
user_id    UUID → auth.users.id
created_at TIMESTAMP
UNIQUE(post_id, user_id)
```

**posts (enhanced)**
```
+ title          TEXT
+ likes_count    INTEGER DEFAULT 0
+ comments_count INTEGER DEFAULT 0
+ is_pinned      BOOLEAN DEFAULT false
+ updated_at     TIMESTAMP
```

**programs (enhanced)**
```
+ start_date TIMESTAMP
+ end_date   TIMESTAMP
+ slug       TEXT UNIQUE
```

### Storage Bucket

**Bucket:** `community`
- **Path:** `community/{user_id}/posts/{filename}`
- **Public:** Yes
- **Max size:** Configured in Supabase settings

---

## 🔒 Security (RLS Policies)

All implemented via Row Level Security:

1. **Posts:**
   - Users can only view posts in programs they've joined
   - Users can only create posts in their programs
   - Users can only edit/delete their own posts

2. **Comments:**
   - Users can only comment on posts in their programs
   - Users can only edit/delete their own comments

3. **Likes:**
   - Users can like any post in their programs
   - One like per user per post (enforced by unique constraint)

4. **Storage:**
   - Users can upload to `community/{their_user_id}/`
   - Anyone can view images
   - Users can only delete their own images

---

## 🎨 Winter Arc Branding

**Colors:**
- Frost Blue: `#4A90E2` (primary actions, accents)
- Steel Blue: `#1E3A5F` (backgrounds, gradients)
- Muted Orange: `#D97B3A` (highlights, pinned posts)
- Black: `#1A1A1A` (backgrounds)
- Slate Gray: `#2C2C34` (cards)

**Typography:**
- Headers: Bebas Neue (bold, uppercase, letter-spacing: 2)
- Body: Inter (clean, readable)

---

## 📱 PWA Features

**Installable on:**
- ✅ iOS Safari (Add to Home Screen)
- ✅ Android Chrome (Install App)
- ✅ Desktop Chrome/Edge (Install icon in address bar)

**Capabilities:**
- Standalone app mode (no browser UI)
- Custom splash screen
- Home screen icon with Winter Arc branding
- App shortcuts (Winter Arc, Community)
- Offline support (via Flutter's service worker)

**Installation Prompt:**
- Shows on first visit
- Dismissible for 7 days
- Platform-specific instructions

---

## 🚀 Launch Checklist (November 17)

### Pre-Launch (Nov 16)
- [ ] Database migration applied to production Supabase
- [ ] Real-time replication enabled
- [ ] Storage bucket created and policies active
- [ ] Routes added to router
- [ ] All features tested locally
- [ ] Code deployed to Vercel
- [ ] Winter Arc program created in database with correct dates

### Launch Day (Nov 17)
- [ ] Verify Winter Arc program is active (`start_date <= now()`)
- [ ] Test purchasing Winter Arc ebook grants community access
- [ ] Test user can access community feed
- [ ] Test creating posts, comments, likes
- [ ] Test PWA install on iOS and Android
- [ ] Monitor Sentry for errors

### Post-Launch Monitoring
- [ ] Check Supabase metrics for database load
- [ ] Monitor storage usage for community images
- [ ] Track user engagement in community
- [ ] Gather feedback for improvements

---

## 🐛 Troubleshooting

### "RLS policy prevents access to posts"
**Fix:** Ensure user has entry in `user_programs` table:
```sql
INSERT INTO user_programs (user_id, program_id)
VALUES ('YOUR_USER_ID', (SELECT id FROM programs WHERE slug = 'winter-arc'));
```

### "Failed to upload image"
**Fix:** Check storage bucket exists and policies are active:
1. Go to Supabase Storage
2. Verify `community` bucket exists
3. Check policies allow inserts for authenticated users

### "Real-time updates not working"
**Fix:** Enable replication:
```sql
alter publication supabase_realtime add table posts;
alter publication supabase_realtime add table community_comments;
alter publication supabase_realtime add table community_likes;
```

### "PWA not installing on iOS"
**Fix:** Ensure:
1. Site is served over HTTPS (Vercel handles this)
2. `manifest.json` is linked in `index.html`
3. Apple touch icons are present
4. User is using Safari (not Chrome on iOS)

---

## 📊 Monitoring

### Supabase Dashboard
- **Database > Tables** - Monitor post/comment/like counts
- **Storage > community** - Track image uploads and storage usage
- **Database > Replication** - Verify real-time is active
- **Logs** - Check for RLS policy errors

### Vercel Dashboard
- **Deployments** - Verify successful builds
- **Analytics** - Track page views for community screens
- **Functions** - Monitor build times and errors

### User Metrics to Track
- Posts created per day
- Comments per post (engagement rate)
- Likes per post
- PWA installs (via analytics)
- Active users in community

---

## 🎯 Next Steps (Post-Launch)

**Week 1 (Nov 17-24):**
- Monitor community engagement
- Fix any bugs reported by users
- Add moderation tools if needed

**Week 2 (Nov 24-Dec 1):**
- Add push notifications for new comments/likes
- Implement post reporting/flagging
- Add admin moderation dashboard

**Month 2 (December):**
- Add user profiles with achievements
- Implement daily check-ins
- Build native iOS/Android apps (optional)
- Add in-app messaging between users

**Future Features:**
- Leaderboards
- Progress photos gallery
- Workout sharing
- Meal plan sharing
- Achievement badges
- Streak tracking

---

## 💡 Tips for Success

1. **Community Guidelines:** Post clear rules and enforce them from day 1
2. **Seed Content:** Have a few power users create initial posts to set the tone
3. **Engagement:** Like and comment on early posts to encourage participation
4. **Moderation:** Be ready to handle spam/inappropriate content quickly
5. **Feedback:** Listen to user feedback and iterate rapidly

---

## 📞 Support Resources

- **Supabase Docs:** https://supabase.com/docs
- **Flutter Web Docs:** https://docs.flutter.dev/platform-integration/web
- **PWA Guide:** https://web.dev/progressive-web-apps/
- **Go Router Docs:** https://pub.dev/packages/go_router
- **Riverpod Docs:** https://riverpod.dev/

---

**Built with Claude Code - November 2025**
**Target Launch: November 17, 2025**
**Duration: 12 weeks (Nov 17 - Feb 9, 2026)**
