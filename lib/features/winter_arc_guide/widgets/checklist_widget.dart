import 'package:flutter/material.dart';
import '../winter_arc_theme.dart';

class ChecklistWidget extends StatefulWidget {
  final String title;
  final List<String> items;
  final bool showProgress;

  const ChecklistWidget({
    super.key,
    required this.title,
    required this.items,
    this.showProgress = true,
  });

  @override
  State<ChecklistWidget> createState() => _ChecklistWidgetState();
}

class _ChecklistWidgetState extends State<ChecklistWidget> {
  late List<bool> _checkedItems;

  @override
  void initState() {
    super.initState();
    _checkedItems = List.generate(widget.items.length, (_) => false);
  }

  int get _completedCount => _checkedItems.where((checked) => checked).length;

  double get _progress => _completedCount / widget.items.length;

  @override
  Widget build(BuildContext context) {
    final isMobile = WinterArcTheme.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL),
      decoration: BoxDecoration(
        color: WinterArcTheme.darkGray,
        borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        border: Border.all(
          color: WinterArcTheme.iceBlue.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: WinterArcTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: isMobile
                      ? WinterArcTheme.subsectionTitleMobile.copyWith(fontSize: 18)
                      : WinterArcTheme.subsectionTitle.copyWith(fontSize: 22),
                ),
              ),
              if (widget.showProgress) ...[
                const SizedBox(width: WinterArcTheme.spacingM),
                _buildProgressCircle(isMobile),
              ],
            ],
          ),

          if (widget.showProgress) ...[
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildProgressBar(),
          ],

          const SizedBox(height: WinterArcTheme.spacingM),

          // Checklist items
          ...List.generate(widget.items.length, (index) {
            return _buildChecklistItem(
              widget.items[index],
              _checkedItems[index],
              (value) {
                setState(() {
                  _checkedItems[index] = value;
                });
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(bool isMobile) {
    return Container(
      width: isMobile ? 50 : 60,
      height: isMobile ? 50 : 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: WinterArcTheme.iceBlue,
          width: 3,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_completedCount',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w800,
                color: WinterArcTheme.white,
              ),
            ),
            Text(
              '/${widget.items.length}',
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                color: WinterArcTheme.lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: WinterArcTheme.charcoal,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: _progress,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                gradient: WinterArcTheme.accentGradient,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(_progress * 100).toStringAsFixed(0)}% Complete',
          style: TextStyle(
            fontSize: 12,
            color: WinterArcTheme.lightGray,
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(String text, bool isChecked, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Container(
        margin: const EdgeInsets.only(bottom: WinterArcTheme.spacingS),
        padding: const EdgeInsets.all(WinterArcTheme.spacingS),
        decoration: BoxDecoration(
          color: isChecked
              ? WinterArcTheme.iceBlue.withOpacity(0.1)
              : WinterArcTheme.charcoal,
          borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
          border: Border.all(
            color: isChecked
                ? WinterArcTheme.iceBlue.withOpacity(0.5)
                : WinterArcTheme.gray.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isChecked ? WinterArcTheme.iceBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isChecked ? WinterArcTheme.iceBlue : WinterArcTheme.gray,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: WinterArcTheme.white,
                    )
                  : null,
            ),

            const SizedBox(width: WinterArcTheme.spacingS),

            // Text
            Expanded(
              child: Text(
                text,
                style: WinterArcTheme.bodyMedium.copyWith(
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  color: isChecked
                      ? WinterArcTheme.lightGray
                      : WinterArcTheme.offWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
