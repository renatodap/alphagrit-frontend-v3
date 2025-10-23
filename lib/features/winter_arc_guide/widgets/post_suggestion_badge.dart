import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:alphagrit/data/repositories/winter_arc_repository.dart';
import 'package:go_router/go_router.dart';
import '../winter_arc_theme.dart';

/// Badge that shows when user has post suggestions based on milestones
/// Displays as a floating badge and can be tapped to see suggestion dialog
class PostSuggestionBadge extends StatefulWidget {
  final int programId;
  final WinterArcRepository repository;

  const PostSuggestionBadge({
    super.key,
    required this.programId,
    required this.repository,
  });

  @override
  State<PostSuggestionBadge> createState() => _PostSuggestionBadgeState();
}

class _PostSuggestionBadgeState extends State<PostSuggestionBadge> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadSuggestions();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await widget.repository.getSuggestions(widget.programId);
      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuggestionDialog() {
    if (_suggestions.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PostSuggestionDialog(
        suggestions: _suggestions,
        repository: widget.repository,
        programId: widget.programId,
        onDismiss: (suggestionId) async {
          await widget.repository.dismissSuggestion(widget.programId, suggestionId);
          _loadSuggestions();
        },
        onPost: (suggestionId) async {
          // Navigate to create post screen
          await widget.repository.markSuggestionPosted(widget.programId, suggestionId);
          if (context.mounted) {
            context.push('/community/create-post?programId=${widget.programId}');
          }
          _loadSuggestions();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 16,
      right: 16,
      child: GestureDetector(
        onTap: _showSuggestionDialog,
        child: ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              gradient: WinterArcTheme.accentGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: WinterArcTheme.iceBlue.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.campaign,
                  color: WinterArcTheme.white,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_suggestions.length} ${_suggestions.length == 1 ? 'Milestone' : 'Milestones'}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: WinterArcTheme.white,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  color: WinterArcTheme.white,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog/Bottom Sheet showing post suggestions
class PostSuggestionDialog extends StatelessWidget {
  final List<Map<String, dynamic>> suggestions;
  final WinterArcRepository repository;
  final int programId;
  final Function(int) onDismiss;
  final Function(int) onPost;

  const PostSuggestionDialog({
    super.key,
    required this.suggestions,
    required this.repository,
    required this.programId,
    required this.onDismiss,
    required this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WinterArcTheme.darkGray,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: WinterArcTheme.gray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: WinterArcTheme.accentGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.celebration,
                      color: WinterArcTheme.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share Your Progress!',
                          style: WinterArcTheme.subsectionTitle.copyWith(fontSize: 20),
                        ),
                        Text(
                          'You\'ve hit major milestones',
                          style: TextStyle(
                            fontSize: 13,
                            color: WinterArcTheme.lightGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: WinterArcTheme.lightGray),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Suggestions list
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: suggestions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return _buildSuggestionCard(context, suggestion);
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(BuildContext context, Map<String, dynamic> suggestion) {
    final id = suggestion['id'] as int;
    final title = suggestion['title'] as String;
    final message = suggestion['message'] as String;
    final type = suggestion['suggestion_type'] as String;

    IconData icon;
    Color accentColor;

    if (type.contains('streak')) {
      icon = Icons.local_fire_department;
      accentColor = Colors.orange;
    } else if (type.contains('achievement')) {
      icon = Icons.emoji_events;
      accentColor = Colors.amber;
    } else if (type.contains('weight')) {
      icon = Icons.trending_down;
      accentColor = Colors.green;
    } else {
      icon = Icons.star;
      accentColor = WinterArcTheme.iceBlue;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WinterArcTheme.charcoal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: WinterArcTheme.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: WinterArcTheme.lightGray,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onPost(id);
                  },
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('SHARE'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: WinterArcTheme.iceBlue,
                    side: BorderSide(color: WinterArcTheme.iceBlue),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDismiss(id);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: WinterArcTheme.lightGray,
                  side: BorderSide(color: WinterArcTheme.gray),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                child: const Text('DISMISS'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
