import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/ai_insight/ai_insight_providers.dart';
import '../../../domain/entities/enhanced_career_roadmap.dart';
import '../../widgets/interactive_career_roadmap.dart';

/// Enhanced roadmap page showing detailed career paths
class EnhancedRoadmapPage extends ConsumerStatefulWidget {
  const EnhancedRoadmapPage({super.key});

  @override
  ConsumerState<EnhancedRoadmapPage> createState() => _EnhancedRoadmapPageState();
}

class _EnhancedRoadmapPageState extends ConsumerState<EnhancedRoadmapPage> {
  String? selectedCareer;

  @override
  Widget build(BuildContext context) {
    final latestInsight = ref.watch(latestAIInsightProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Roadmap'),
        elevation: 0,
      ),
      body: latestInsight.when(
        data: (insight) {
          if (insight == null || insight.careerRecommendations.isEmpty) {
            return _buildNoInsightsView(context);
          }

          // If no career selected, show the first one
          if (selectedCareer == null && insight.careerRecommendations.isNotEmpty) {
            selectedCareer = insight.careerRecommendations.first.title;
          }

          return Column(
            children: [
              // Career selector
              _buildCareerSelector(context, insight.careerRecommendations.map((c) => c.title).toList()),
              
              // Roadmap content
              Expanded(
                child: selectedCareer != null
                    ? _buildRoadmapContent(selectedCareer!)
                    : const Center(child: Text('Select a career to see the roadmap')),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildNoInsightsView(context),
      ),
    );
  }

  Widget _buildCareerSelector(BuildContext context, List<String> careers) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: careers.length,
        itemBuilder: (context, index) {
          final career = careers[index];
          final isSelected = career == selectedCareer;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCareer = career;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  career,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoadmapContent(String careerTitle) {
    final roadmap = CareerRoadmapData.getRoadmapForCareer(careerTitle);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: InteractiveCareerRoadmap(roadmap: roadmap),
    );
  }

  Widget _buildNoInsightsView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Career Insights Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Complete quizzes and games to get personalized career recommendations and roadmaps!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to discover page
                Navigator.of(context).pushReplacementNamed('/discover');
              },
              icon: const Icon(Icons.explore),
              label: const Text('Start Exploring'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

