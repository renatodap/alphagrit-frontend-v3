class UserProfile {
  final String userId;
  final String? name;
  final String? bio;
  final String? avatarUrl;
  final String? language;
  final String? unitPreference;
  final bool? isAdmin;
  final bool? notifyEmailSummaries;
  final bool? notifyReplies;
  final bool? notifyCoachResponses;
  UserProfile({required this.userId, this.name, this.bio, this.avatarUrl, this.language, this.unitPreference, this.isAdmin, this.notifyEmailSummaries, this.notifyReplies, this.notifyCoachResponses});

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        userId: (j['user_id'] ?? '') as String,
        name: j['name'] as String?,
        bio: j['bio'] as String?,
        avatarUrl: j['avatar_url'] as String?,
        language: j['language'] as String?,
        unitPreference: j['unit_preference'] as String?,
        isAdmin: j['is_admin'] as bool?,
        notifyEmailSummaries: j['notify_email_summaries'] as bool?,
        notifyReplies: j['notify_replies'] as bool?,
        notifyCoachResponses: j['notify_coach_responses'] as bool?,
      );

  Map<String, dynamic> toUpdateJson() => {
        if (name != null) 'name': name,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (language != null) 'language': language,
        if (unitPreference != null) 'unit_preference': unitPreference,
        if (notifyEmailSummaries != null) 'notify_email_summaries': notifyEmailSummaries,
        if (notifyReplies != null) 'notify_replies': notifyReplies,
        if (notifyCoachResponses != null) 'notify_coach_responses': notifyCoachResponses,
      };
}

