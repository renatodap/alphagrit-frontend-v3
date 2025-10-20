import 'package:flutter/material.dart';
import '../winter_arc_theme.dart';

class ChapterNavigation extends StatefulWidget {
  final ScrollController scrollController;
  final List<GlobalKey> sectionKeys;

  const ChapterNavigation({
    super.key,
    required this.scrollController,
    required this.sectionKeys,
  });

  @override
  State<ChapterNavigation> createState() => _ChapterNavigationState();
}

class _ChapterNavigationState extends State<ChapterNavigation> {
  int _activeIndex = 0;

  final List<String> _chapters = [
    'Intro',
    'Ch 1: The Test',
    'Ch 2: Body',
    'Ch 3: Nutrition',
    'Ch 4: Mind',
    'Ch 5: Code',
    'Conclusion',
  ];

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final scrollOffset = widget.scrollController.offset;

    for (int i = 0; i < widget.sectionKeys.length; i++) {
      final key = widget.sectionKeys[i];
      final context = key.currentContext;

      if (context != null) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero).dy;

        if (position <= 100 && position > -box.size.height + 100) {
          if (_activeIndex != i) {
            setState(() {
              _activeIndex = i;
            });
          }
          break;
        }
      }
    }
  }

  void _scrollToSection(int index) {
    final key = widget.sectionKeys[index];
    final context = key.currentContext;

    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = WinterArcTheme.isMobile(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: WinterArcTheme.charcoal.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: WinterArcTheme.iceBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: WinterArcTheme.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: isMobile
            ? _buildMobileNav()
            : _buildDesktopNav(),
      ),
    );
  }

  Widget _buildMobileNav() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: WinterArcTheme.spacingS),
      child: Row(
        children: [
          Text(
            'WINTER ARC',
            style: WinterArcTheme.navTextActive.copyWith(fontSize: 16),
          ),
          const Spacer(),
          PopupMenuButton<int>(
            icon: Icon(
              Icons.menu,
              color: WinterArcTheme.iceBlue,
            ),
            color: WinterArcTheme.darkGray,
            onSelected: _scrollToSection,
            itemBuilder: (context) {
              return List.generate(_chapters.length, (index) {
                return PopupMenuItem<int>(
                  value: index,
                  child: Row(
                    children: [
                      if (_activeIndex == index)
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: WinterArcTheme.accentGradient,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Text(
                        _chapters[index],
                        style: _activeIndex == index
                            ? WinterArcTheme.navTextActive
                            : WinterArcTheme.navText,
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNav() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: WinterArcTheme.spacingXL),
      child: Row(
        children: [
          // Logo/Title
          Text(
            'WINTER ARC',
            style: WinterArcTheme.navTextActive.copyWith(fontSize: 18),
          ),

          const SizedBox(width: WinterArcTheme.spacingXL),

          // Navigation items
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_chapters.length, (index) {
                final isActive = _activeIndex == index;

                return GestureDetector(
                  onTap: () => _scrollToSection(index),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: WinterArcTheme.spacingS,
                        vertical: WinterArcTheme.spacingXS,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isActive
                                ? WinterArcTheme.iceBlue
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        _chapters[index],
                        style: isActive
                            ? WinterArcTheme.navTextActive
                            : WinterArcTheme.navText,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
