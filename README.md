# AlphaGrit (Flutter)

Brutalist, mobile-first fitness and community app (EN/PT) integrating FastAPI + Supabase backend.

## Prereqs
- Flutter 3.24+
- Supabase project (URL + anon key)
- Backend base URL (FastAPI: `/api/v1`)

## Run

```
flutter pub get
flutter run --dart-define=BACKEND_BASE_URL=http://localhost:8000 \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

Web:
```
flutter run -d chrome --web-renderer canvaskit --dart-define=BACKEND_BASE_URL=http://localhost:8000 \
  --dart-define=SUPABASE_URL=your_supabase_url --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

## Build
- Android: `flutter build apk --release` (configure signing)
- iOS: `flutter build ipa --release` (set up signing in Xcode)
- Web: `flutter build web --web-renderer canvaskit`

## Deploy to Vercel (from this repo)

Two options:

1) Build in CI on Vercel (single repo)
- Ensure your Vercel project root is `alphagrit/` (Project Settings → General → Root Directory).
- Files added for you:
  - `alphagrit/vercel.json` → sets build/output and SPA routes
  - `alphagrit/vercel_build.sh` → installs Flutter and builds web
- Vercel Project Settings → Environment Variables:
  - `BACKEND_BASE_URL` (e.g., https://api.yourdomain.com)
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
- Deploy. Output Directory is `build/web`.

2) Prebuild locally and deploy static (separate repo)
- `flutter build web --release --web-renderer canvaskit`
- Create a new repo containing only the contents of `build/web`.
- On Vercel: Framework “Other”, Build Command empty, Output Directory `.`.
- Add SPA rewrites in `vercel.json`:
  `{ "routes": [ { "handle": "filesystem" }, { "src": "/.*", "dest": "/index.html" } ] }`

## Structure
- `lib/app`: router, theme
- `lib/features`: screens by domain (auth, ebooks, programs, metrics, store, profile, admin, legal)
- `lib/infra`: API client (Dio) + Supabase bootstrap
- `l10n`: EN/PT .arb strings (instant toggle supported)

## Integration Notes
- Auth: Supabase Flutter manages session; access token added to REST calls by Dio interceptor.
- Payments: Call backend checkout endpoints; redirect to returned `checkout_url` via `url_launcher`/in-app web page.
- Uploads: Call `/uploads/*` to get `{bucket,path,signed_url?}` then upload via Supabase Storage or signed URL.
- RLS: Enforced server-side; private posts require premium membership tier.

## Legal & Privacy
- Privacy and Terms screens at `/legal/privacy` and `/legal/terms`.
- Require acceptance at signup: store timestamp in `user_profiles`.

## Testing
- Add widget/integration tests under `test/` and `integration_test/` (scaffold as needed).

## Theming
- Colors: Red #FF1A1A, Black #000, White #FFF, Greys #222/#666.
- Fonts: Bebas Neue (headings), Inter (body).
- Brutalist components: GritButton, GritCard.
