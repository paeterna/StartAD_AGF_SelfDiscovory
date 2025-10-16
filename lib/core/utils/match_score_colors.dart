import 'package:flutter/material.dart';

/// Utility for mapping match scores to colors in the career tree
class MatchScoreColors {
  MatchScoreColors._();

  /// Color scale thresholds
  static const double highThreshold = 0.8; // >= 80%
  static const double mediumHighThreshold = 0.5; // >= 50%
  static const double mediumLowThreshold = 0.2; // >= 20%

  /// Get color for a match score (0.0 to 1.0)
  /// Returns grey if score is null (unknown)
  static Color getColor(double? score) {
    if (score == null) return Colors.grey.shade400;

    if (score >= highThreshold) {
      // High match: Green
      return Colors.green.shade600;
    } else if (score >= mediumHighThreshold) {
      // Medium-high: Yellow to Orange gradient
      final t = (score - mediumHighThreshold) / (highThreshold - mediumHighThreshold);
      return Color.lerp(Colors.orange.shade400, Colors.yellow.shade600, t)!;
    } else if (score >= mediumLowThreshold) {
      // Medium-low: Orange to Red gradient
      final t = (score - mediumLowThreshold) / (mediumHighThreshold - mediumLowThreshold);
      return Color.lerp(Colors.red.shade600, Colors.orange.shade400, t)!;
    } else {
      // Low match: Red
      return Colors.red.shade600;
    }
  }

  /// Get background color with opacity for cards/chips
  static Color getBackgroundColor(double? score, {double opacity = 0.2}) {
    return getColor(score).withValues(alpha: opacity);
  }

  /// Get match level label
  static String getLabel(double? score) {
    if (score == null) return 'Unknown Match';

    if (score >= highThreshold) {
      return 'High Match';
    } else if (score >= mediumHighThreshold) {
      return 'Good Match';
    } else if (score >= mediumLowThreshold) {
      return 'Fair Match';
    } else {
      return 'Low Match';
    }
  }

  /// Get icon for match level
  static IconData getIcon(double? score) {
    if (score == null) return Icons.help_outline;

    if (score >= highThreshold) {
      return Icons.check_circle;
    } else if (score >= mediumHighThreshold) {
      return Icons.thumb_up;
    } else if (score >= mediumLowThreshold) {
      return Icons.remove_circle_outline;
    } else {
      return Icons.cancel_outlined;
    }
  }

  /// Legend items for display
  static List<LegendItem> get legendItems => [
        LegendItem(
          color: Colors.green.shade600,
          label: 'High Match (80%+)',
          threshold: highThreshold,
        ),
        LegendItem(
          color: Colors.yellow.shade600,
          label: 'Good Match (50-80%)',
          threshold: mediumHighThreshold,
        ),
        LegendItem(
          color: Colors.orange.shade400,
          label: 'Fair Match (20-50%)',
          threshold: mediumLowThreshold,
        ),
        LegendItem(
          color: Colors.red.shade600,
          label: 'Low Match (<20%)',
          threshold: 0.0,
        ),
        LegendItem(
          color: Colors.grey.shade400,
          label: 'Unknown',
          threshold: null,
        ),
      ];

  /// Calculate aggregate color for a category based on its careers
  static Color getAggregateColor(List<double?> scores) {
    if (scores.isEmpty) return Colors.grey.shade400;

    // Filter out null scores
    final validScores = scores.whereType<double>().toList();
    if (validScores.isEmpty) return Colors.grey.shade400;

    // Calculate average
    final average = validScores.reduce((a, b) => a + b) / validScores.length;
    return getColor(average);
  }

  /// Get gradient for progress bars
  static LinearGradient getGradient(double? score) {
    final color = getColor(score);
    return LinearGradient(
      colors: [
        color.withValues(alpha: 0.3),
        color,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

/// Legend item model
class LegendItem {
  const LegendItem({
    required this.color,
    required this.label,
    required this.threshold,
  });

  final Color color;
  final String label;
  final double? threshold;
}
