import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/activity/activity_providers.dart';
import '../../../application/activity/activity_service.dart';
import '../../../application/quiz/quiz_providers.dart';
import '../../../data/models/quiz_instrument.dart';

import '../../../generated/l10n/app_localizations.dart';
import '../../widgets/gradient_background.dart';

/// Page that displays quiz information and starts the assessment
class QuizPage extends ConsumerWidget {
  const QuizPage({
    super.key,
    required this.activityId,
  });

  final String activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activityAsync = ref.watch(activityProvider(activityId));

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.discoverQuizzesTab),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: activityAsync.when(
          data: (activity) {
            if (activity == null) {
              // Fallback: if activityId encodes an instrument (quiz_*) try loading the instrument
              final instrument = _getInstrumentFromActivityId(activityId);
              final language = Localizations.localeOf(context).languageCode;
              if (instrument != null) {
                final metadataAsync = ref.watch(
                  quizMetadataProvider(
                    QuizItemsParams(instrument: instrument, language: language),
                  ),
                );

                return metadataAsync.when(
                  data: (metadata) => _buildQuizContentFromMetadata(
                    context,
                    ref,
                    l10n,
                    instrument,
                    metadata,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => _buildNotFoundPage(context, l10n),
                );
              }

              return _buildNotFoundPage(context, l10n);
            }
            return _buildQuizContent(context, ref, l10n, activity);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              _buildErrorPage(context, l10n, error.toString()),
        ),
      ),
    );
  }

  // Build quiz content when we only have instrument metadata (no activity DB row)
  Widget _buildQuizContentFromMetadata(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String instrument,
    QuizInstrument metadata,
  ) {
    // Construct a lightweight view using instrument metadata
    final language = metadata.language;
    final title = metadata.title;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getQuizDescription(instrument, l10n),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 20,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.discoverDurationMinutes(
                          _getDefaultDuration(instrument),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Details and start button reuse same UI pieces
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.quizWhatYouWillLearn,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._getQuizLearningPoints(instrument, l10n).map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              point,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                context.push('/assessment/$instrument/$language');
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.discoverStartButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.quizInstructions,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getQuizInstructions(instrument, l10n),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Backwards-compatible helper that maps an activityId to an instrument
  String? _getInstrumentFromActivityId(String activityId) {
    return _inferInstrument(activityId: activityId, title: null);
  }

  /// Render the quiz page when we have a DB Activity object
  Widget _buildQuizContent(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Activity activity,
  ) {
    // Try to infer instrument from activity id or title
    final instrument = _inferInstrument(
      activityId: activity.id,
      title: activity.title,
    );
    final language = Localizations.localeOf(context).languageCode;

    if (instrument == null) {
      // If this activity isn't a supported instrument, show unsupported UI
      return _buildUnsupportedQuizPage(context, l10n, activity.title);
    }

    // Reuse the metadata-driven UI but using activity values where available
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getQuizDescription(instrument, l10n),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 20,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        activity.estimatedMinutes != null
                            ? l10n.discoverDurationMinutes(
                                activity.estimatedMinutes!,
                              )
                            : l10n.discoverDurationMinutes(
                                _getDefaultDuration(instrument),
                              ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.quizWhatYouWillLearn,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._getQuizLearningPoints(instrument, l10n).map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              point,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                context.push('/assessment/$instrument/$language');
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.discoverStartButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.quizInstructions,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getQuizInstructions(instrument, l10n),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundPage(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.discoverQuizNotFound,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.discoverQuizNotFoundDesc,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/discover'),
            child: Text(l10n.discoverBackToDiscovery),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPage(
    BuildContext context,
    AppLocalizations l10n,
    String error,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.discoverErrorLoadingQuiz,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/discover'),
            child: Text(l10n.discoverRetryButton),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedQuizPage(
    BuildContext context,
    AppLocalizations l10n,
    String title,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_outlined,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.discoverQuizNotSupported,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.discoverQuizNotSupportedDesc,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/discover'),
            child: Text(l10n.discoverBackToDiscovery),
          ),
        ],
      ),
    );
  }

  /// Map activity ID or title to quiz instrument
  String? _inferInstrument({String? activityId, String? title}) {
    // 1) If activityId uses 'quiz_' prefix, extract instrument
    if (activityId != null && activityId.startsWith('quiz_')) {
      final instrument = activityId.substring(5);
      if (['riasec_mini', 'ipip50'].contains(instrument)) return instrument;
    }

    // 2) Try to infer from title keywords
    final t = title?.toLowerCase() ?? '';
    if (t.contains('riasec') ||
        t.contains('career') ||
        t.contains('career interest')) {
      return 'riasec_mini';
    }
    if (t.contains('personality') ||
        t.contains('big five') ||
        t.contains('ipip')) {
      return 'ipip50';
    }

    // 3) No inference possible
    return null;
  }

  String _getQuizDescription(String instrument, AppLocalizations l10n) {
    switch (instrument) {
      case 'riasec_mini':
        return l10n.quizRiasecDescription;
      case 'ipip50':
        return l10n.quizIpip50Description;
      default:
        return l10n.quizGenericDescription;
    }
  }

  int _getDefaultDuration(String instrument) {
    switch (instrument) {
      case 'riasec_mini':
        return 5;
      case 'ipip50':
        return 10;
      default:
        return 5;
    }
  }

  List<String> _getQuizLearningPoints(
    String instrument,
    AppLocalizations l10n,
  ) {
    switch (instrument) {
      case 'riasec_mini':
        return [
          l10n.quizRiasecLearning1,
          l10n.quizRiasecLearning2,
          l10n.quizRiasecLearning3,
          l10n.quizRiasecLearning4,
        ];
      case 'ipip50':
        return [
          l10n.quizIpip50Learning1,
          l10n.quizIpip50Learning2,
          l10n.quizIpip50Learning3,
          l10n.quizIpip50Learning4,
        ];
      default:
        return [
          l10n.quizGenericLearning,
        ];
    }
  }

  String _getQuizInstructions(String instrument, AppLocalizations l10n) {
    switch (instrument) {
      case 'riasec_mini':
        return l10n.quizRiasecInstructions;
      case 'ipip50':
        return l10n.quizIpip50Instructions;
      default:
        return l10n.quizGenericInstructions;
    }
  }
}
