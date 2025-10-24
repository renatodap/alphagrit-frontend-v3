import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alphagrit/data/repositories/winter_arc_repository.dart';
import 'package:alphagrit/app/providers.dart';
import 'winter_arc_guide_screen.dart';
import 'winter_arc_guide_pt_screen.dart';
import 'widgets/paywall_overlay.dart';
import 'winter_arc_theme.dart';

/// Wrapper screen that handles access control for Winter Arc Guide
/// Shows paywall if user doesn't have ebook access
class WinterArcGuideWrapper extends ConsumerStatefulWidget {
  final bool isPortuguese;

  const WinterArcGuideWrapper({
    super.key,
    this.isPortuguese = false,
  });

  @override
  ConsumerState<WinterArcGuideWrapper> createState() => _WinterArcGuideWrapperState();
}

class _WinterArcGuideWrapperState extends ConsumerState<WinterArcGuideWrapper> {
  bool _isLoading = true;
  bool _hasAccess = false;
  String? _error;
  int _retryCount = 0;
  static const int _maxRetries = 5;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _checkAccess());
  }

  Future<void> _checkAccess() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // FIRST: Check if user is authenticated with Supabase
      final session = Supabase.instance.client.auth.currentSession;

      if (session == null) {
        // Not authenticated → No access, show paywall immediately
        if (mounted) {
          setState(() {
            _hasAccess = false;
            _isLoading = false;
          });
        }
        return;
      }

      // SECOND: Check if repository is ready
      final repository = ref.read(winterArcRepositoryProvider);

      if (repository == null) {
        // Repository not ready yet
        _retryCount++;

        if (_retryCount > _maxRetries) {
          // Give up after max retries, show paywall
          if (mounted) {
            setState(() {
              _hasAccess = false;
              _isLoading = false;
              _error = 'Failed to initialize. Please refresh the page.';
            });
          }
          return;
        }

        // Retry with exponential backoff
        await Future.delayed(Duration(milliseconds: 300 * _retryCount));
        if (mounted) _checkAccess();
        return;
      }

      // THIRD: Call backend to check access
      final accessData = await repository.checkAccess(1); // program_id = 1 for Winter Arc
      final hasEbookAccess = accessData['has_ebook_access'] as bool? ?? false;

      if (mounted) {
        setState(() {
          _hasAccess = hasEbookAccess;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Any error → No access, show paywall
      if (mounted) {
        setState(() {
          _hasAccess = false;
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: WinterArcTheme.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(WinterArcTheme.iceBlue),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Checking access...',
                style: TextStyle(
                  fontSize: 14,
                  color: WinterArcTheme.lightGray,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasAccess) {
      // User has access - show the guide
      // If isPortuguese is explicitly set, use that, otherwise use current locale
      final locale = ref.watch(localeProvider);
      final showPortuguese = widget.isPortuguese || locale.languageCode == 'pt';

      return showPortuguese
          ? const WinterArcGuidePtScreen()
          : const WinterArcGuideScreen();
    }

    // User doesn't have access - show paywall
    return Scaffold(
      backgroundColor: WinterArcTheme.black,
      body: PaywallOverlay(contentType: 'ebook'),
    );
  }
}
