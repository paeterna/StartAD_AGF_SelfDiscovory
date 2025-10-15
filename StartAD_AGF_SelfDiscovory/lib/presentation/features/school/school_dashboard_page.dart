import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../application/school/school_providers.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/school.dart';
import '../../widgets/gradient_background.dart';

/// School administrator dashboard
class SchoolDashboardPage extends ConsumerWidget {
  const SchoolDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolAsync = ref.watch(mySchoolProvider);
    final theme = Theme.of(context);

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('School Dashboard'),
          actions: [
            // Settings button
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push(AppRoutes.settings),
              tooltip: 'Settings',
            ),
            // Logout button
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  context.go(AppRoutes.schoolLogin);
                }
              },
              tooltip: 'Logout',
            ),
          ],
        ),
        body: schoolAsync.when(
          data: (school) {
            if (school == null) {
              return const Center(
                child: Text('No school found for your account'),
              );
            }
            return _SchoolDashboardContent(school: school);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading school: $error'),
          ),
        ),
      ),
    );
  }
}

class _SchoolDashboardContent extends ConsumerWidget {
  final School school;

  const _SchoolDashboardContent({required this.school});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AppScaffoldBody(
      child: SingleChildScrollView(
        padding: context.responsivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // School Header
            Row(
              children: [
                Icon(
                  Icons.school,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: ResponsiveSpacing.md(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (school.code != null)
                        Text(
                          'Code: ${school.code}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveSpacing.xl(context)),

            // KPI Cards
            _KpiCards(schoolId: school.id),

            SizedBox(height: ResponsiveSpacing.xl(context)),

            // Desktop: Two column layout
            if (context.isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column: Top students and career distribution
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopStudentsCard(schoolId: school.id),
                        SizedBox(height: ResponsiveSpacing.lg(context)),
                        _CareerDistributionCard(schoolId: school.id),
                      ],
                    ),
                  ),
                  SizedBox(width: ResponsiveSpacing.xl(context)),
                  // Right column: School radar
                  Expanded(
                    flex: 1,
                    child: _SchoolRadarCard(schoolId: school.id),
                  ),
                ],
              )
            else
              // Mobile/Tablet: Stacked layout
              Column(
                children: [
                  _TopStudentsCard(schoolId: school.id),
                  SizedBox(height: ResponsiveSpacing.lg(context)),
                  _SchoolRadarCard(schoolId: school.id),
                  SizedBox(height: ResponsiveSpacing.lg(context)),
                  _CareerDistributionCard(schoolId: school.id),
                ],
              ),

            SizedBox(height: ResponsiveSpacing.xl(context)),

            // Students Table Section
            _StudentsTableSection(schoolId: school.id),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// KPI Cards
// =====================================================

class _KpiCards extends ConsumerWidget {
  final String schoolId;

  const _KpiCards({required this.schoolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(schoolKpisProvider(schoolId));

    return kpisAsync.when(
      data: (kpis) {
        if (context.isMobile) {
          // Mobile: Stacked
          return Column(
            children: [
              _KpiCard(
                icon: Icons.people,
                title: 'Total Students',
                value: kpis.totalStudents.toString(),
                color: Colors.blue,
              ),
              SizedBox(height: ResponsiveSpacing.sm(context)),
              _KpiCard(
                icon: Icons.insert_chart,
                title: 'Avg Profile Completion',
                value: '${kpis.avgProfileCompletion.toStringAsFixed(1)}%',
                color: Colors.green,
              ),
              SizedBox(height: ResponsiveSpacing.sm(context)),
              _KpiCard(
                icon: Icons.verified,
                title: 'Avg Match Confidence',
                value: '${(kpis.avgMatchConfidence * 100).toStringAsFixed(1)}%',
                color: Colors.orange,
              ),
              SizedBox(height: ResponsiveSpacing.sm(context)),
              _KpiCard(
                icon: Icons.star,
                title: 'Top Career Cluster',
                value: kpis.topCareerCluster ?? 'N/A',
                color: Colors.purple,
              ),
            ],
          );
        } else {
          // Tablet/Desktop: Grid
          return GridView.count(
            crossAxisCount: context.responsive(xs: 2, sm: 2, md: 2, lg: 4),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: ResponsiveSpacing.md(context),
            crossAxisSpacing: ResponsiveSpacing.md(context),
            childAspectRatio: context.responsive(xs: 1.5, sm: 1.5, md: 1.8, lg: 2.2),
            children: [
              _KpiCard(
                icon: Icons.people,
                title: 'Total Students',
                value: kpis.totalStudents.toString(),
                color: Colors.blue,
              ),
              _KpiCard(
                icon: Icons.insert_chart,
                title: 'Avg Profile Completion',
                value: '${kpis.avgProfileCompletion.toStringAsFixed(1)}%',
                color: Colors.green,
              ),
              _KpiCard(
                icon: Icons.verified,
                title: 'Avg Match Confidence',
                value: '${(kpis.avgMatchConfidence * 100).toStringAsFixed(1)}%',
                color: Colors.orange,
              ),
              _KpiCard(
                icon: Icons.star,
                title: 'Top Career Cluster',
                value: kpis.topCareerCluster ?? 'N/A',
                color: Colors.purple,
              ),
            ],
          );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ResponsiveCard(
      enableHover: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// =====================================================
// Top Students Card
// =====================================================

class _TopStudentsCard extends ConsumerWidget {
  final String schoolId;

  const _TopStudentsCard({required this.schoolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(schoolTopStudentsProvider(schoolId));
    final theme = Theme.of(context);

    return ResponsiveCard(
      enableHover: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 5 Students',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          studentsAsync.when(
            data: (students) {
              if (students.isEmpty) {
                return const Text('No student data available');
              }
              return Column(
                children: students.map((student) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        context.push('/school/student/${student.userId}');
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: theme.colorScheme.primary,
                              child: Text(
                                student.displayName?.substring(0, 1).toUpperCase() ?? '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.displayName ?? 'Unknown',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Overall: ${student.overallStrength.toStringAsFixed(1)} | '
                                    'Completion: ${student.profileCompletion.toStringAsFixed(0)}%',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// Career Distribution Card
// =====================================================

class _CareerDistributionCard extends ConsumerWidget {
  final String schoolId;

  const _CareerDistributionCard({required this.schoolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distributionAsync = ref.watch(schoolCareerDistributionProvider(schoolId));
    final theme = Theme.of(context);

    return ResponsiveCard(
      enableHover: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Career Distribution',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          distributionAsync.when(
            data: (distribution) {
              if (distribution.isEmpty) {
                return const Text('No career match data available');
              }

              return Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: distribution.map((item) {
                          return PieChartSectionData(
                            value: item.studentCount.toDouble(),
                            title: '${item.studentCount}',
                            color: _getColorForCluster(item.cluster),
                            radius: 100,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Legend
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: distribution.map((item) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _getColorForCluster(item.cluster),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${item.cluster} (${item.studentCount})',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 250,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }

  Color _getColorForCluster(String cluster) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];
    return colors[cluster.hashCode % colors.length];
  }
}

// =====================================================
// School Radar Card
// =====================================================

class _SchoolRadarCard extends ConsumerWidget {
  final String schoolId;

  const _SchoolRadarCard({required this.schoolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final featureAveragesAsync = ref.watch(schoolFeatureAveragesProvider(schoolId));

    return ResponsiveCard(
      enableHover: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.radar,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'School Profile (Cohort Averages)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          featureAveragesAsync.when(
            data: (averages) {
              if (averages.isEmpty) {
                return AspectRatio(
                  aspectRatio: 1.0,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No data available yet',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Students need to complete assessments',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Group features by family
              final interests = averages.where((f) => f.family == 'interests').toList();
              final cognition = averages.where((f) => f.family == 'cognition').toList();
              final traits = averages.where((f) => f.family == 'traits').toList();

              return Column(
                children: [
                  // Feature family tabs or sections
                  _buildFeatureFamilySection(context, 'Interests', interests, Icons.favorite_outline),
                  const SizedBox(height: 16),
                  _buildFeatureFamilySection(context, 'Cognition', cognition, Icons.psychology_outlined),
                  const SizedBox(height: 16),
                  _buildFeatureFamilySection(context, 'Traits', traits, Icons.person_outline),
                ],
              );
            },
            loading: () => const AspectRatio(
              aspectRatio: 1.0,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => AspectRatio(
              aspectRatio: 1.0,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading school data',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureFamilySection(
    BuildContext context,
    String title,
    List<SchoolFeatureAverage> features,
    IconData icon,
  ) {
    if (features.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildFeatureBar(context, feature),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBar(BuildContext context, SchoolFeatureAverage feature) {
    final theme = Theme.of(context);
    final score = feature.avgScore.clamp(0.0, 100.0);

    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            feature.label,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(
              _getColorForScore(context, score),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${score.toStringAsFixed(0)}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getColorForScore(BuildContext context, double score) {
    final theme = Theme.of(context);
    if (score >= 80) return Colors.green;
    if (score >= 60) return theme.colorScheme.primary;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}

// =====================================================
// Students Table Section (Placeholder)
// =====================================================

class _StudentsTableSection extends ConsumerWidget {
  final String schoolId;

  const _StudentsTableSection({required this.schoolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ResponsiveCard(
      enableHover: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'All Students',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  // TODO: Navigate to full students list page
                },
                icon: const Icon(Icons.list),
                label: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Students table with search and filters will be here'),
        ],
      ),
    );
  }
}
