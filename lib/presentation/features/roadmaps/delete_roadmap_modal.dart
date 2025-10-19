import 'package:flutter/material.dart';
import '../../../domain/entities/ai_career_roadmap.dart';

/// Modal for managing roadmap deletion when limit is reached
///
/// Shows when user tries to generate a 4th roadmap.
/// Displays existing roadmaps and allows user to select one to delete.
class DeleteRoadmapModal extends StatefulWidget {
  const DeleteRoadmapModal({
    super.key,
    required this.existingRoadmaps,
    required this.newCareerTitle,
  });

  final List<AICareerRoadmapSummary> existingRoadmaps;
  final String newCareerTitle;

  @override
  State<DeleteRoadmapModal> createState() => _DeleteRoadmapModalState();
}

class _DeleteRoadmapModalState extends State<DeleteRoadmapModal> {
  String? _selectedRoadmapId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: theme.colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Roadmap Limit Reached',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Explanation
          Text(
            'You can only have 3 roadmaps at a time to keep your focus sharp.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'To generate a roadmap for "${widget.newCareerTitle}", please choose one of your existing roadmaps to delete:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Existing roadmaps list
          Text(
            'Your Current Roadmaps',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...widget.existingRoadmaps.map((roadmap) {
            final isSelected = _selectedRoadmapId == roadmap.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedRoadmapId = roadmap.id;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.error
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.error.withValues(alpha: 0.2)
                              : theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            roadmap.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roadmap.careerTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? theme.colorScheme.onErrorContainer
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              roadmap.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.onErrorContainer
                                          .withValues(alpha: 0.8)
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(roadmap.generatedAt),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.onErrorContainer
                                          .withValues(alpha: 0.7)
                                    : theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Selection indicator
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.error,
                        )
                      else
                        Icon(
                          Icons.radio_button_unchecked,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Warning message
          if (_selectedRoadmapId != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. The selected roadmap will be permanently deleted.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _selectedRoadmapId == null
                      ? null
                      : () {
                          Navigator.pop(context, _selectedRoadmapId);
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  ),
                  child: const Text('Delete & Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Generated today';
    } else if (difference.inDays == 1) {
      return 'Generated yesterday';
    } else if (difference.inDays < 7) {
      return 'Generated ${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Generated $weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return 'Generated $months ${months == 1 ? 'month' : 'months'} ago';
    }
  }
}

/// Helper function to show the delete roadmap modal
Future<String?> showDeleteRoadmapModal({
  required BuildContext context,
  required List<AICareerRoadmapSummary> existingRoadmaps,
  required String newCareerTitle,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: DeleteRoadmapModal(
        existingRoadmaps: existingRoadmaps,
        newCareerTitle: newCareerTitle,
      ),
    ),
  );
}
