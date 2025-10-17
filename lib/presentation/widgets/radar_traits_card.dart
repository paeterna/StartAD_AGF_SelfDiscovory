import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/traits/traits_providers.dart';
import '../../core/utils/feature_labels.dart';
import '../../data/models/radar_data.dart';

/// Widget displaying a radar chart of user's trait profile vs cohort average
class RadarTraitsCard extends ConsumerWidget {
  const RadarTraitsCard({
    super.key,
    this.family,
    this.title,
    this.showLegend = true,
  });

  /// Optional filter by feature family (riasec, cognition, traits)
  /// If null, shows all features
  final String? family;

  /// Optional custom title
  final String? title;

  /// Whether to show legend
  final bool showLegend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radarDataAsync = ref.watch(radarDataByFamilyProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title ?? _getDefaultTitle(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Radar chart
            radarDataAsync.when(
              data: (radarDataByFamily) {
                final dataPoints = _getFilteredData(radarDataByFamily);

                // Show empty state if less than 3 features have data
                if (dataPoints.length < 3) {
                  return _buildEmptyState(context);
                }

                return Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: _buildRadarChart(context, dataPoints),
                    ),
                    if (showLegend) ...[
                      const SizedBox(height: 16),
                      _buildLegend(context),
                    ],
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Unable to load trait data',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDefaultTitle() {
    if (family == null) return 'Your Trait Profile';
    switch (family!.toLowerCase()) {
      case 'riasec':
        return 'Career Interests (RIASEC)';
      case 'cognition':
        return 'Cognitive Abilities';
      case 'traits':
        return 'Personality Traits';
      default:
        return 'Your Trait Profile';
    }
  }

  List<RadarDataPoint> _getFilteredData(RadarDataByFamily dataByFamily) {
    if (family == null) return dataByFamily.all;

    switch (family!.toLowerCase()) {
      case 'riasec':
        return dataByFamily.riasec;
      case 'cognition':
        return dataByFamily.cognition;
      case 'traits':
        return dataByFamily.traits;
      default:
        return dataByFamily.all;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Not enough data yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete more activities to see your profile',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarChart(
    BuildContext context,
    List<RadarDataPoint> dataPoints,
  ) {
    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        radarBorderData: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 2,
        ),
        tickBorderData: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
        gridBorderData: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 1,
        ),
        tickCount: 5,
        ticksTextStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
          fontSize: 10,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        titleTextStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        getTitle: (index, angle) {
          if (index >= dataPoints.length) {
            return const RadarChartTitle(text: '');
          }
          // Use short label without family prefix
          final shortLabel = getShortFeatureLabel(dataPoints[index].featureKey);
          return RadarChartTitle(
            text: _abbreviateLabel(shortLabel),
          );
        },
        dataSets: [
          // User scores
          RadarDataSet(
            fillColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.2),
            borderColor: Theme.of(context).colorScheme.primary,
            borderWidth: 2,
            entryRadius: 3,
            dataEntries: dataPoints
                .map((point) => RadarEntry(value: point.userScore))
                .toList(),
          ),
          // Cohort average
          RadarDataSet(
            fillColor: Colors.grey.withValues(alpha: 0.1),
            borderColor: Colors.grey,
            borderWidth: 2,
            entryRadius: 0,
            dataEntries: dataPoints
                .map((point) => RadarEntry(value: point.cohortMean))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          context,
          'Your Score',
          Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 24),
        _buildLegendItem(
          context,
          'Average',
          Colors.grey,
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  /// Abbreviate long feature labels for better display
  String _abbreviateLabel(String label) {
    final abbreviations = {
      'Realistic': 'Real',
      'Investigative': 'Inv',
      'Artistic': 'Art',
      'Social': 'Soc',
      'Enterprising': 'Ent',
      'Conventional': 'Conv',
      'Extraversion': 'Extr',
      'Agreeableness': 'Agr',
      'Conscientiousness': 'Cons',
      'Emotional Stability': 'Emot',
      'Openness': 'Open',
    };

    return abbreviations[label] ?? label;
  }
}
