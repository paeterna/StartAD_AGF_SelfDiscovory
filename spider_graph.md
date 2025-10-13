this is an implementation to create a spider chart in the dashboard.

1) Add dependency

pubspec.yaml

dependencies:
  fl_chart: ^0.66.0   # or latest

2) SQL (server) — ordered scores endpoint (optional but efficient)

If you prefer a single call, create a compact view that returns ordered user scores (0–100) and cohort means:

create or replace view public.v_user_radar as
select
  f.id              as feature_index,
  f.key             as feature_key,
  initcap(replace(f.key, '_', ' ')) as feature_label,
  f.family          as family,
  coalesce(ufs.score_mean, 50.0) as user_score_0_100,
  coalesce(fcs.mean, 50.0)       as cohort_mean_0_100
from public.features f
left join public.user_feature_scores ufs
  on ufs.feature_key = f.key and ufs.user_id = auth.uid()
left join public.feature_cohort_stats fcs
  on fcs.feature_key = f.key
order by f.id;


RLS (read your own only):

alter view public.v_user_radar set (security_invoker = on);


If you can’t add a view, the client code below performs the equivalent left join and ordering.

3) Repository — fetch radar data (with or without the view)

lib/data/traits/traits_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class RadarPoint {
  final int index;             // stable axis index
  final String key;            // feature_key
  final String label;          // human label
  final String family;         // interests / cognition / traits
  final double user;           // 0..100
  final double cohort;         // 0..100

  RadarPoint({
    required this.index,
    required this.key,
    required this.label,
    required this.family,
    required this.user,
    required this.cohort,
  });
}

class TraitsRepository {
  final SupabaseClient _supa;
  TraitsRepository(this._supa);

  /// Preferred (uses view)
  Future<List<RadarPoint>> fetchRadarPointsFromView() async {
    final res = await _supa.from('v_user_radar').select();
    if (res is! List) throw Exception('Failed to fetch v_user_radar');
    final rows = (res as List).cast<Map<String, dynamic>>();

    return rows.map((m) {
      return RadarPoint(
        index: (m['feature_index'] as num).toInt(),
        key: m['feature_key'] as String,
        label: m['feature_label'] as String,
        family: m['family'] as String,
        user: (m['user_score_0_100'] as num).toDouble(),
        cohort: (m['cohort_mean_0_100'] as num).toDouble(),
      );
    }).toList()
      ..sort((a, b) => a.index.compareTo(b.index));
  }

  /// Fallback (no view): run the left-join client-side
  Future<List<RadarPoint>> fetchRadarPointsClientJoin() async {
    final userId = _supa.auth.currentUser!.id;

    // 1) features ordered by id
    final features = await _supa.from('features')
        .select('id,key,family')
        .order('id', ascending: true);
    if (features is! List) throw Exception('Failed to fetch features');

    // 2) user_feature_scores
    final ufs = await _supa.from('user_feature_scores')
        .select('feature_key,score_mean')
        .eq('user_id', userId);
    final ufsMap = <String, double>{
      for (final m in (ufs as List).cast<Map<String, dynamic>>())
        m['feature_key'] as String: (m['score_mean'] as num).toDouble()
    };

    // 3) cohort stats (mean)
    final cohort = await _supa.from('feature_cohort_stats')
        .select('feature_key,mean');
    final cohortMap = <String, double>{
      for (final m in (cohort as List).cast<Map<String, dynamic>>())
        m['feature_key'] as String: (m['mean'] as num).toDouble()
    };

    // 4) build ordered list
    final out = <RadarPoint>[];
    for (final f in features.cast<Map<String, dynamic>>()) {
      final idx = (f['id'] as num).toInt();
      final key = f['key'] as String;
      final fam = f['family'] as String;
      out.add(
        RadarPoint(
          index: idx,
          key: key,
          label: _labelize(key),
          family: fam,
          user: (ufsMap[key] ?? 50.0).clamp(0, 100),
          cohort: (cohortMap[key] ?? 50.0).clamp(0, 100),
        ),
      );
    }
    return out;
  }

  String _labelize(String key) {
    // "trait_emotional_intelligence" -> "Emotional Intelligence"
    final cleaned = key
        .replaceAll('trait_', '')
        .replaceAll('interest_', '')
        .replaceAll('cognition_', '')
        .replaceAll('_', ' ');
    return cleaned.split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }
}

4) Radar widget (fl_chart) — user vs cohort, with smart labeling

lib/presentation/widgets/radar_traits_card.dart

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/traits/traits_repository.dart';

class RadarTraitsCard extends StatelessWidget {
  const RadarTraitsCard({
    super.key,
    required this.points,         // ordered by index
    this.title = 'Your Strengths & Growth Areas',
    this.subtitle = 'Compared to peers',
    this.showCohort = true,
  });

  final List<RadarPoint> points;
  final String title;
  final String subtitle;
  final bool showCohort;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = points.map((p) => p.label).toList(growable: false);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(subtitle, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.2,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  radarBorderData: BorderSide.none,
                  tickBorderData: const BorderSide(width: 0.5, color: Colors.white24),
                  gridBorderData: const BorderSide(width: 0.5, color: Colors.white12),
                  backgroundColor: Colors.transparent,
                  // 0..100 domain → convert to 0..1 for RadarEntry
                  ticksTextStyle: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  // 5 concentric rings (0,25,50,75,100)
                  tickCount: 5,
                  radarBackgroundColor: Colors.transparent,
                  titleTextStyle: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  titlePositionPercentageOffset: 1.12,
                  getTitle: (index, angle) => _titleWidget(labels[index], angle, theme),
                  dataSets: [
                    if (showCohort)
                      RadarDataSet(
                        // cohort mean
                        dataEntries: points
                            .map((p) => RadarEntry(value: p.cohort / 100.0))
                            .toList(),
                        fillColor: theme.colorScheme.primary.withOpacity(0.10),
                        borderColor: theme.colorScheme.primary.withOpacity(0.25),
                        entryRadius: 0,
                        borderWidth: 2,
                      ),
                    RadarDataSet(
                      // user
                      dataEntries: points
                          .map((p) => RadarEntry(value: p.user / 100.0))
                          .toList(),
                      fillColor: theme.colorScheme.secondary.withOpacity(0.18),
                      borderColor: theme.colorScheme.secondary,
                      entryRadius: 2.5,
                      borderWidth: 3,
                    ),
                  ],
                ),
                swapAnimationDuration: const Duration(milliseconds: 350),
              ),
            ),
            const SizedBox(height: 12),
            _Legend(showCohort: showCohort),
            const SizedBox(height: 8),
            _Insights(points: points),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Keeps labels readable around the circle
  Widget _titleWidget(String text, double angle, ThemeData theme) {
    final color = theme.colorScheme.onSurface.withOpacity(0.85);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: color,
      fontWeight: FontWeight.w600,
    );

    // Shorten very long labels to fit
    final short = text.length > 22 ? '${text.substring(0, 20)}…' : text;

    // Slight rotate to follow circumference (optional)
    final rot = AngleTween.normalize(angle + math.pi / 2);
    return Transform.rotate(
      angle: rot,
      child: Text(short, textAlign: TextAlign.center, style: style),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.showCohort});
  final bool showCohort;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final dot = (Color c) => Container(
      width: 10, height: 10,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );

    return Row(
      children: [
        if (showCohort) ...[
          dot(t.colorScheme.primary),
          const SizedBox(width: 6),
          Text('Cohort average', style: t.textTheme.labelMedium),
          const SizedBox(width: 16),
        ],
        dot(t.colorScheme.secondary),
        const SizedBox(width: 6),
        Text('You', style: t.textTheme.labelMedium),
      ],
    );
  }
}

/// Auto-explain top strengths and growth areas (simple, actionable)
class _Insights extends StatelessWidget {
  const _Insights({required this.points});
  final List<RadarPoint> points;

  @override
  Widget build(BuildContext context) {
    // Top 3 strengths / bottom 3 growth areas
    final sorted = [...points]..sort((a, b) => b.user.compareTo(a.user));
    final strengths = sorted.take(3).toList();
    final growth = sorted.reversed.take(3).toList();

    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Highlights', style: t.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12, runSpacing: 6,
          children: [
            ...strengths.map((p) => _chip(context, p.label, p.user, true)),
            ...growth.map((p) => _chip(context, p.label, p.user, false)),
          ],
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, double score, bool up) {
    final t = Theme.of(context);
    final color = up
        ? t.colorScheme.tertiaryContainer
        : t.colorScheme.errorContainer.withOpacity(0.7);
    final fg = t.colorScheme.onTertiaryContainer;

    return Chip(
      backgroundColor: color,
      side: BorderSide.none,
      label: Text(
        up ? 'Strength • $label (${score.round()})'
           : 'Grow • $label (${score.round()})',
        style: t.textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }
}

/// Small utility for angle normalization
class AngleTween {
  static double normalize(double a) {
    while (a > math.pi) a -= 2 * math.pi;
    while (a < -math.pi) a += 2 * math.pi;
    return a;
  }
}

5) Screen wiring (fetch + render)

lib/presentation/features/dashboard/traits_radar_section.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/traits/traits_repository.dart';
import '../../widgets/radar_traits_card.dart';

class TraitsRadarSection extends StatefulWidget {
  const TraitsRadarSection({super.key, this.useView = true});
  final bool useView;

  @override
  State<TraitsRadarSection> createState() => _TraitsRadarSectionState();
}

class _TraitsRadarSectionState extends State<TraitsRadarSection> {
  late final TraitsRepository repo;
  late Future<List<RadarPoint>> future;

  @override
  void initState() {
    super.initState();
    repo = TraitsRepository(Supabase.instance.client);
    future = widget.useView ? repo.fetchRadarPointsFromView()
                            : repo.fetchRadarPointsClientJoin();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RadarPoint>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Card(child: SizedBox(height: 360, child: Center(child: CircularProgressIndicator())));
        }
        if (snap.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Radar failed: ${snap.error}'),
            ),
          );
        }
        final pts = snap.data!;
        if (pts.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No trait data yet. Take a quiz to unlock insights.'),
            ),
          );
        }
        return RadarTraitsCard(points: pts);
      },
    );
  }
}


Usage on your dashboard:

// inside Dashboard body
const TraitsRadarSection(useView: true),

6) UX notes / extensibility

Normalization: We plot 0–100 directly (scaled to 0–1 in the chart). Your EMA pipeline already bounds scores.

Benchmark: Showing Cohort Average helps users contextualize strengths. Toggle via showCohort.

Localization: For Arabic RTL, wrap the card in a Directionality(textDirection: TextDirection.rtl, child: RadarTraitsCard(...)) if your app-wide direction isn’t already set.

Families (color bands): You can split the radar into three separate mini-radars by family (interests, cognition, traits) to reduce clutter on small screens.

Drill-down: Tap a label → navigate to a dedicated page with recommended micro-challenges to lift that trait (ties into your roadmap).

7) Optional: filter to “traits only”

If you want a radar that excludes interests/cognition and shows traits only:

final traitsOnly = pts.where((p) => p.family == 'traits').toList();
return RadarTraitsCard(points: traitsOnly, subtitle: 'Personality & work styles');
