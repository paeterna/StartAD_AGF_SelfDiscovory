import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:startad_agf_selfdiscovery/core/utils/match_score_colors.dart';

void main() {
  group('MatchScoreColors', () {
    group('getColor', () {
      test('returns grey for null score', () {
        final color = MatchScoreColors.getColor(null);
        expect(color, equals(Colors.grey.shade400));
      });

      test('returns green for high match (>= 0.8)', () {
        final color = MatchScoreColors.getColor(0.9);
        expect(color, equals(Colors.green.shade600));
      });

      test('returns yellow-orange gradient for medium-high (0.5-0.8)', () {
        final color1 = MatchScoreColors.getColor(0.5);
        final color2 = MatchScoreColors.getColor(0.65);
        final color3 = MatchScoreColors.getColor(0.79);

        // All should be in the yellow-orange range
        expect(color1, isNot(equals(Colors.red.shade600)));
        expect(color2, isNot(equals(Colors.green.shade600)));
        expect(color3, isNot(equals(Colors.grey.shade400)));
      });

      test('returns orange-red gradient for medium-low (0.2-0.5)', () {
        final color1 = MatchScoreColors.getColor(0.2);
        final color2 = MatchScoreColors.getColor(0.35);
        final color3 = MatchScoreColors.getColor(0.49);

        // All should be in the orange-red range
        expect(color1, isNot(equals(Colors.green.shade600)));
        expect(color2, isNot(equals(Colors.grey.shade400)));
        expect(color3, isNot(equals(Colors.grey.shade400)));
      });

      test('returns red for low match (< 0.2)', () {
        final color = MatchScoreColors.getColor(0.1);
        expect(color, equals(Colors.red.shade600));
      });

      test('handles edge cases', () {
        expect(MatchScoreColors.getColor(0.0), equals(Colors.red.shade600));
        expect(MatchScoreColors.getColor(1.0), equals(Colors.green.shade600));
        expect(MatchScoreColors.getColor(0.8), equals(Colors.green.shade600));
        expect(MatchScoreColors.getColor(0.5), isNot(equals(Colors.grey.shade400)));
      });
    });

    group('getLabel', () {
      test('returns correct labels for different score ranges', () {
        expect(MatchScoreColors.getLabel(null), equals('Unknown Match'));
        expect(MatchScoreColors.getLabel(0.9), equals('High Match'));
        expect(MatchScoreColors.getLabel(0.8), equals('High Match'));
        expect(MatchScoreColors.getLabel(0.65), equals('Good Match'));
        expect(MatchScoreColors.getLabel(0.5), equals('Good Match'));
        expect(MatchScoreColors.getLabel(0.35), equals('Fair Match'));
        expect(MatchScoreColors.getLabel(0.2), equals('Fair Match'));
        expect(MatchScoreColors.getLabel(0.1), equals('Low Match'));
        expect(MatchScoreColors.getLabel(0.0), equals('Low Match'));
      });
    });

    group('getIcon', () {
      test('returns appropriate icons for different score ranges', () {
        expect(MatchScoreColors.getIcon(null), equals(Icons.help_outline));
        expect(MatchScoreColors.getIcon(0.9), equals(Icons.check_circle));
        expect(MatchScoreColors.getIcon(0.65), equals(Icons.thumb_up));
        expect(MatchScoreColors.getIcon(0.35), equals(Icons.remove_circle_outline));
        expect(MatchScoreColors.getIcon(0.1), equals(Icons.cancel_outlined));
      });
    });

    group('getAggregateColor', () {
      test('returns grey for empty list', () {
        final color = MatchScoreColors.getAggregateColor([]);
        expect(color, equals(Colors.grey.shade400));
      });

      test('returns grey for all null scores', () {
        final color = MatchScoreColors.getAggregateColor([null, null, null]);
        expect(color, equals(Colors.grey.shade400));
      });

      test('calculates average color for valid scores', () {
        final color = MatchScoreColors.getAggregateColor([0.9, 0.8, 0.85]);
        // Average is 0.85, should be green
        expect(color, equals(Colors.green.shade600));
      });

      test('ignores null scores in average', () {
        final color = MatchScoreColors.getAggregateColor([0.9, null, 0.7]);
        // Average of 0.9 and 0.7 is 0.8, should be green
        expect(color, equals(Colors.green.shade600));
      });
    });

    group('legendItems', () {
      test('returns exactly 5 legend items', () {
        final items = MatchScoreColors.legendItems;
        expect(items.length, equals(5));
      });

      test('legend items have required properties', () {
        final items = MatchScoreColors.legendItems;
        for (final item in items) {
          expect(item.color, isNotNull);
          expect(item.label, isNotEmpty);
        }
      });

      test('legend items are in correct order (high to low)', () {
        final items = MatchScoreColors.legendItems;
        expect(items[0].label, contains('High'));
        expect(items[1].label, contains('Good'));
        expect(items[2].label, contains('Fair'));
        expect(items[3].label, contains('Low'));
        expect(items[4].label, contains('Unknown'));
      });
    });

    group('getBackgroundColor', () {
      test('returns color with correct opacity', () {
        final color = MatchScoreColors.getBackgroundColor(0.9);
        expect(color.a, closeTo(0.2, 0.01));
      });

      test('accepts custom opacity', () {
        final color = MatchScoreColors.getBackgroundColor(0.9, opacity: 0.5);
        expect(color.a, closeTo(0.5, 0.01));
      });

      test('handles null score', () {
        final color = MatchScoreColors.getBackgroundColor(null);
        expect(color.a, closeTo(0.2, 0.01));
      });
    });
  });
}
