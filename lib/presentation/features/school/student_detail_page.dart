import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/school/school_providers.dart';
import '../../../core/responsive/responsive.dart';
import '../../../data/models/school.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/radar_traits_card.dart';

/// Student detail page for school admins to view individual student progress
class StudentDetailPage extends ConsumerStatefulWidget {
  final String studentId;

  const StudentDetailPage({
    required this.studentId,
    super.key,
  });

  @override
  ConsumerState<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends ConsumerState<StudentDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentAsync = ref.watch(studentDetailProvider(widget.studentId));

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Student Details'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.radar), text: 'Traits Radar'),
              Tab(icon: Icon(Icons.history), text: 'History'),
              Tab(icon: Icon(Icons.work_outline), text: 'Career Matches'),
            ],
          ),
        ),
        body: studentAsync.when(
          data: (student) {
            if (student == null) {
              return const Center(child: Text('Student not found'));
            }
            return TabBarView(
              controller: _tabController,
              children: [
                _buildTraitsRadarTab(student),
                _buildHistoryTab(student),
                _buildCareerMatchesTab(student),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading student: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentHeader(TopStudent student) {
    final lastActive = student.lastActivity != null
        ? DateFormat.yMMMd().format(student.lastActivity!)
        : 'Never';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.displayName ?? 'Unknown Student',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student.email ?? 'No email',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Last active: $lastActive',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // KPI metrics
            context.responsive(
              xs: Column(
                children: [
                  _buildKpiMetric(
                    'Profile Completion',
                    '75%',
                    Icons.account_circle,
                  ),
                  const SizedBox(height: 12),
                  _buildKpiMetric('Overall Strength', '82%', Icons.star),
                  const SizedBox(height: 12),
                  _buildKpiMetric(
                    'Assessments Completed',
                    '12',
                    Icons.check_circle,
                  ),
                ],
              ),
              md: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildKpiMetric(
                      'Profile Completion',
                      '75%',
                      Icons.account_circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildKpiMetric(
                      'Overall Strength',
                      '82%',
                      Icons.star,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildKpiMetric(
                      'Assessments Completed',
                      '12',
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitsRadarTab(TopStudent student) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student header
          _buildStudentHeader(student),
          const SizedBox(height: 24),

          Text(
            'Feature Scores',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Radar chart - Using the actual RadarTraitsCard widget
          // Note: This shows the currently logged-in user's data
          // TODO: Update RadarTraitsCard to accept userId parameter for school admin view
          const RadarTraitsCard(
            showLegend: true,
          ),
          const SizedBox(height: 24),

          // Feature breakdown list
          Text(
            'Detailed Breakdown',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildFeatureListTile('Creative & Artistic', 85),
                _buildFeatureListTile('Analytical Thinking', 78),
                _buildFeatureListTile('Social Connection', 92),
                _buildFeatureListTile('Leadership', 75),
                _buildFeatureListTile('Problem Solving', 88),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureListTile(String feature, int score) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          '$score',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(feature),
      trailing: SizedBox(
        width: 100,
        child: LinearProgressIndicator(
          value: score / 100,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }

  Widget _buildHistoryTab(TopStudent student) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student header
          _buildStudentHeader(student),
          const SizedBox(height: 24),

          Text(
            'Assessment History',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Timeline of assessments
          Card(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildHistoryItem(
                  'RIASEC Interest Assessment',
                  'Completed on Oct 10, 2024',
                  Icons.quiz,
                  Colors.green,
                ),
                _buildHistoryItem(
                  'Memory Match Game',
                  'Completed on Oct 8, 2024',
                  Icons.games,
                  Colors.blue,
                ),
                _buildHistoryItem(
                  'Problem Solving Quiz',
                  'Completed on Oct 5, 2024',
                  Icons.psychology,
                  Colors.purple,
                ),
                _buildHistoryItem(
                  'Personality Assessment',
                  'Completed on Oct 1, 2024',
                  Icons.person,
                  Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    String title,
    String date,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(date),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios, size: 16),
        onPressed: () {
          // TODO: Navigate to assessment detail
        },
      ),
    );
  }

  Widget _buildCareerMatchesTab(TopStudent student) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student header
          _buildStudentHeader(student),
          const SizedBox(height: 24),

          Text(
            'Top Career Matches',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Based on assessments and feature scores',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Career matches list
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildCareerMatchCard(
                'Software Engineer',
                'Technology',
                92,
                'Strong match based on analytical and problem-solving skills',
              ),
              const SizedBox(height: 12),
              _buildCareerMatchCard(
                'UX Designer',
                'Design',
                88,
                'Great fit for creative and user-focused thinking',
              ),
              const SizedBox(height: 12),
              _buildCareerMatchCard(
                'Data Scientist',
                'Analytics',
                85,
                'Excellent analytical and mathematical abilities',
              ),
              const SizedBox(height: 12),
              _buildCareerMatchCard(
                'Product Manager',
                'Management',
                82,
                'Strong leadership and communication skills',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCareerMatchCard(
    String title,
    String category,
    int matchScore,
    String description,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$matchScore% Match',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
