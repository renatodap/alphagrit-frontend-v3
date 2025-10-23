import 'package:dio/dio.dart';
import 'package:alphagrit/infra/api/errors.dart';

/// Repository for Winter Arc progress tracking, checklists, achievements, and leaderboard
class WinterArcRepository {
  final Dio dio;
  WinterArcRepository(this.dio);

  // ===== ACCESS CONTROL =====

  /// Check user's access levels for Winter Arc
  /// Returns: {has_ebook_access, has_community_access, is_premium, product_type}
  Future<Map<String, dynamic>> checkAccess(int programId) async {
    try {
      final res = await dio.get('/winter-arc/programs/$programId/check-access');
      if (res.statusCode == 200) {
        return res.data as Map<String, dynamic>;
      }
      throwApiError(res.statusCode, res.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        // Not authenticated or no access - return no access
        return {
          'has_ebook_access': false,
          'has_community_access': false,
          'is_premium': false,
          'product_type': null,
        };
      }
      rethrow;
    }
  }

  // ===== PROGRESS =====

  /// Get user's progress for a program
  Future<Map<String, dynamic>> getProgress(int programId) async {
    final res = await dio.get('/winter-arc/programs/$programId/progress');
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Update user progress (mission, macros, settings)
  Future<Map<String, dynamic>> updateProgress(
    int programId,
    Map<String, dynamic> updates,
  ) async {
    final res = await dio.put('/winter-arc/programs/$programId/progress', data: updates);
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Increment 3-minute timer completion
  Future<Map<String, dynamic>> incrementTimer(int programId, {int minutes = 3}) async {
    final res = await dio.post(
      '/winter-arc/programs/$programId/progress/timer',
      queryParameters: {'minutes': minutes},
    );
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Create a weight progress snapshot
  Future<Map<String, dynamic>> createSnapshot(
    int programId,
    double weightKg, {
    String? notes,
  }) async {
    final res = await dio.post(
      '/winter-arc/programs/$programId/progress/snapshots',
      data: {'weight_kg': weightKg, if (notes != null) 'notes': notes},
    );
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Get weight progress snapshots
  Future<List<Map<String, dynamic>>> getSnapshots(int programId, {int limit = 50}) async {
    final res = await dio.get(
      '/winter-arc/programs/$programId/progress/snapshots',
      queryParameters: {'limit': limit},
    );
    if (res.statusCode == 200) {
      return (res.data as List).cast<Map<String, dynamic>>();
    }
    throwApiError(res.statusCode, res.data);
  }

  // ===== DAILY CHECKLISTS =====

  /// Get today's daily checklist
  Future<Map<String, dynamic>> getTodayChecklist(int programId) async {
    final res = await dio.get('/winter-arc/programs/$programId/checklists/daily/today');
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Get daily checklist for a specific date
  Future<Map<String, dynamic>> getDailyChecklist(int programId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0]; // YYYY-MM-DD
    final res = await dio.get('/winter-arc/programs/$programId/checklists/daily/$dateStr');
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Update daily checklist for a specific date
  Future<Map<String, dynamic>> updateDailyChecklist(
    int programId,
    DateTime date,
    Map<String, bool> updates,
  ) async {
    final dateStr = date.toIso8601String().split('T')[0]; // YYYY-MM-DD
    final res = await dio.put(
      '/winter-arc/programs/$programId/checklists/daily/$dateStr',
      data: updates,
    );
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Get daily checklists for a date range
  Future<List<Map<String, dynamic>>> getDailyChecklistRange(
    int programId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = startDate.toIso8601String().split('T')[0];
    final end = endDate.toIso8601String().split('T')[0];
    final res = await dio.get(
      '/winter-arc/programs/$programId/checklists/daily/range',
      queryParameters: {'start_date': start, 'end_date': end},
    );
    if (res.statusCode == 200) {
      return (res.data as List).cast<Map<String, dynamic>>();
    }
    throwApiError(res.statusCode, res.data);
  }

  // ===== WEEKLY CHECKLISTS =====

  /// Get current week's checklist
  Future<Map<String, dynamic>> getCurrentWeekChecklist(int programId) async {
    final res = await dio.get('/winter-arc/programs/$programId/checklists/weekly/current');
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Get weekly checklist for a specific ISO week
  Future<Map<String, dynamic>> getWeeklyChecklist(
    int programId,
    int year,
    int week,
  ) async {
    final res = await dio.get('/winter-arc/programs/$programId/checklists/weekly/$year/$week');
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Update weekly checklist for a specific ISO week
  Future<Map<String, dynamic>> updateWeeklyChecklist(
    int programId,
    int year,
    int week,
    Map<String, bool> updates,
  ) async {
    final res = await dio.put(
      '/winter-arc/programs/$programId/checklists/weekly/$year/$week',
      data: updates,
    );
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }

  // ===== ACHIEVEMENTS =====

  /// Get all available achievements
  Future<List<Map<String, dynamic>>> getAllAchievements(int programId) async {
    final res = await dio.get('/winter-arc/programs/$programId/achievements');
    if (res.statusCode == 200) {
      return (res.data as List).cast<Map<String, dynamic>>();
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Get user's unlocked achievements
  Future<List<Map<String, dynamic>>> getUserAchievements(int programId) async {
    final res = await dio.get('/winter-arc/programs/$programId/achievements/user');
    if (res.statusCode == 200) {
      return (res.data as List).cast<Map<String, dynamic>>();
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Get progress toward all achievements
  Future<List<Map<String, dynamic>>> getAchievementProgress(int programId) async {
    final res = await dio.get('/winter-arc/programs/$programId/achievements/progress');
    if (res.statusCode == 200) {
      return (res.data as List).cast<Map<String, dynamic>>();
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Check and unlock achievements
  Future<Map<String, dynamic>> checkAchievements(int programId) async {
    final res = await dio.post('/winter-arc/programs/$programId/achievements/check');
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }

  // ===== LEADERBOARD =====

  /// Get leaderboard for a program
  Future<List<Map<String, dynamic>>> getLeaderboard(
    int programId, {
    int limit = 100,
    int offset = 0,
  }) async {
    final res = await dio.get(
      '/winter-arc/programs/$programId/leaderboard',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    if (res.statusCode == 200) {
      return (res.data as List).cast<Map<String, dynamic>>();
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Get my position on the leaderboard
  Future<Map<String, dynamic>> getMyLeaderboardPosition(int programId) async {
    final res = await dio.get('/winter-arc/programs/$programId/leaderboard/me');
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Get leaderboard context around my position
  Future<Map<String, dynamic>> getLeaderboardContext(
    int programId, {
    int contextSize = 5,
  }) async {
    final res = await dio.get(
      '/winter-arc/programs/$programId/leaderboard/context',
      queryParameters: {'context_size': contextSize},
    );
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }

  // ===== POST SUGGESTIONS =====

  /// Get active post suggestions
  Future<List<Map<String, dynamic>>> getSuggestions(int programId) async {
    final res = await dio.get('/winter-arc/programs/$programId/suggestions');
    if (res.statusCode == 200) {
      return (res.data as List).cast<Map<String, dynamic>>();
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Dismiss a post suggestion
  Future<Map<String, dynamic>> dismissSuggestion(int programId, int suggestionId) async {
    final res = await dio.post(
      '/winter-arc/programs/$programId/suggestions/$suggestionId/dismiss',
    );
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Mark suggestion as posted
  Future<Map<String, dynamic>> markSuggestionPosted(int programId, int suggestionId) async {
    final res = await dio.post(
      '/winter-arc/programs/$programId/suggestions/$suggestionId/posted',
    );
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Check and trigger new suggestions
  Future<List<Map<String, dynamic>>> checkSuggestions(int programId) async {
    final res = await dio.post('/winter-arc/programs/$programId/suggestions/check');
    if (res.statusCode == 200) {
      return (res.data as List).cast<Map<String, dynamic>>();
    }
    throwApiError(res.statusCode, res.data);
  }
}
