// Configure via --dart-define at build time; fallback to placeholders.
class Env {
  static const backendBaseUrl = String.fromEnvironment('BACKEND_BASE_URL', defaultValue: 'http://localhost:8000');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
}

