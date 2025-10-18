import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../domain/repositories/ai_roadmap_repository.dart';
import '../analytics/analytics_service.dart';
import '../../presentation/features/roadmaps/delete_roadmap_modal.dart';

/// Service for managing roadmap generation flow
class RoadmapService {
  RoadmapService({
    required AIRoadmapRepository roadmapRepository,
    required AnalyticsService analyticsService,
  })  : _roadmapRepository = roadmapRepository,
        _analyticsService = analyticsService;

  final AIRoadmapRepository _roadmapRepository;
  final AnalyticsService _analyticsService;

  /// Generate a roadmap with full flow: check limits, handle deletion, generate, navigate
  Future<bool> generateRoadmapWithFlow({
    required BuildContext context,
    required String userId,
    required String careerId,
    required String careerTitle,
    required int matchScore,
    String? locale,
  }) async {
    // Log generate button click
    await _analyticsService.logCareerGenerateClicked(
      userId: userId,
      careerId: careerId,
      careerTitle: careerTitle,
      matchScore: matchScore,
    );

    // Check if roadmap already exists
    final exists = await _roadmapRepository.hasRoadmapForCareer(
      userId: userId,
      careerId: careerId,
    );

    if (exists) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You already have a roadmap for $careerTitle'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () async {
                // Get the roadmap and navigate
                final roadmap = await _roadmapRepository.getRoadmapForCareer(
                  userId: userId,
                  careerId: careerId,
                );
                if (roadmap != null && context.mounted) {
                  context.push('${AppRoutes.roadmapDetail}/${roadmap.id}');
                }
              },
            ),
          ),
        );
      }
      return false;
    }

    // Show loading dialog
    if (context.mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating your personalized roadmap...'),
                  SizedBox(height: 8),
                  Text(
                    'This may take a few moments',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    try {
      // Attempt to generate
      final roadmapId = await _roadmapRepository.generateRoadmap(
        careerId: careerId,
        locale: locale,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Log success
      await _analyticsService.logRoadmapGenerated(
        userId: userId,
        roadmapId: roadmapId,
        careerId: careerId,
        careerTitle: careerTitle,
      );

      // Navigate to roadmap detail
      if (context.mounted) {
        context.push('${AppRoutes.roadmapDetail}/$roadmapId');
      }

      return true;
    } on RoadmapLimitExceededException catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Get existing roadmaps
      final existingRoadmaps = await _roadmapRepository
          .watchUserRoadmaps(userId)
          .first;

      if (!context.mounted) return false;

      // Show delete modal
      final selectedRoadmapId = await showDeleteRoadmapModal(
        context: context,
        existingRoadmaps: existingRoadmaps,
        newCareerTitle: careerTitle,
      );

      if (selectedRoadmapId == null) {
        // User canceled
        return false;
      }

      // Delete selected roadmap
      await _roadmapRepository.deleteRoadmap(selectedRoadmapId);

      // Log deletion
      final deletedRoadmap = existingRoadmaps.firstWhere(
        (r) => r.id == selectedRoadmapId,
      );
      await _analyticsService.logRoadmapDeleted(
        userId: userId,
        roadmapId: selectedRoadmapId,
        careerTitle: deletedRoadmap.careerTitle,
        reason: 'limit_reached',
      );

      if (!context.mounted) return false;

      // Retry generation
      return generateRoadmapWithFlow(
        context: context,
        userId: userId,
        careerId: careerId,
        careerTitle: careerTitle,
        matchScore: matchScore,
        locale: locale,
      );
    } on RoadmapAlreadyExistsException {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // This shouldn't happen since we checked, but handle it
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Roadmap for $careerTitle already exists'),
          ),
        );
      }

      return false;
    } on AIGenerationFailedException catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Log failure
      await _analyticsService.logRoadmapGenerationFailed(
        userId: userId,
        careerId: careerId,
        careerTitle: careerTitle,
        errorCode: 'ai_generation_failed',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate roadmap: ${e.message}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                generateRoadmapWithFlow(
                  context: context,
                  userId: userId,
                  careerId: careerId,
                  careerTitle: careerTitle,
                  matchScore: matchScore,
                  locale: locale,
                );
              },
            ),
          ),
        );
      }

      return false;
    } on Exception catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Log generic failure
      await _analyticsService.logRoadmapGenerationFailed(
        userId: userId,
        careerId: careerId,
        careerTitle: careerTitle,
        errorCode: 'unknown_error',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    }
  }

  /// Delete a roadmap with confirmation
  Future<bool> deleteRoadmapWithConfirmation({
    required BuildContext context,
    required String userId,
    required String roadmapId,
    required String careerTitle,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Roadmap?'),
        content: Text(
          'Are you sure you want to delete your roadmap for $careerTitle? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    try {
      await _roadmapRepository.deleteRoadmap(roadmapId);

      // Log deletion
      await _analyticsService.logRoadmapDeleted(
        userId: userId,
        roadmapId: roadmapId,
        careerTitle: careerTitle,
        reason: 'user_initiated',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Roadmap for $careerTitle deleted'),
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      }

      return true;
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete roadmap: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }
}
