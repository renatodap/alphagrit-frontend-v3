import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void initState() {
    super.initState();
    // Delay to ensure provider is ready
    Future.microtask(() => _checkAccess());
  }

  Future<void> _checkAccess() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(winterArcRepositoryProvider);
      if (repository == null) {
        // Repository not ready yet, try again
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) _checkAccess();
        return;
      }

      // Check access
      final accessData = await repository.checkAccess(1); // program_id = 1 for Winter Arc
      final hasEbookAccess = accessData['has_ebook_access'] as bool? ?? false;

      if (mounted) {
        setState(() {
          _hasAccess = hasEbookAccess;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If there's an error (like not authenticated), assume no access
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
      return widget.isPortuguese
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
