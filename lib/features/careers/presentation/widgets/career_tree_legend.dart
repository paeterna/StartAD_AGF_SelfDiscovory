import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/utils/match_score_colors.dart';

/// Legend widget showing color-to-match-score mapping
class CareerTreeLegend extends StatelessWidget {
  const CareerTreeLegend({super.key, this.compact = false});

  /// Whether to show compact version
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final legendItems = MatchScoreColors.legendItems;

    if (compact) {
      return Wrap(
        spacing: 8,
        runSpacing: 4,
        children: legendItems.map((item) => _CompactLegendItem(item: item)).toList(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Match Score Legend',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ...legendItems.map((item) => _LegendItem(item: item)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual legend item
class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.item});

  final LegendItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: item.color.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact legend item (just chip)
class _CompactLegendItem extends StatelessWidget {
  const _CompactLegendItem({required this.item});

  final LegendItem item;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(item.label),
      avatar: CircleAvatar(
        backgroundColor: item.color,
        radius: 8,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
