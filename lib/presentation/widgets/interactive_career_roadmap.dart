import 'package:flutter/material.dart';
import '../../domain/entities/enhanced_career_roadmap.dart';

/// Interactive career roadmap with expandable phases and steps
class InteractiveCareerRoadmap extends StatefulWidget {
  final EnhancedCareerRoadmap roadmap;

  const InteractiveCareerRoadmap({
    super.key,
    required this.roadmap,
  });

  @override
  State<InteractiveCareerRoadmap> createState() => _InteractiveCareerRoadmapState();
}

class _InteractiveCareerRoadmapState extends State<InteractiveCareerRoadmap> with TickerProviderStateMixin {
  String? expandedPhaseId;
  String? expandedStepId;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),
          const SizedBox(height: 32),
          
          // Roadmap Timeline
          _buildTimeline(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.roadmap.careerTitle,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.roadmap.description,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.schedule,
                label: widget.roadmap.estimatedDuration,
              ),
              const SizedBox(width: 16),
              _buildInfoChip(
                icon: Icons.attach_money,
                label: widget.roadmap.salaryRange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Column(
      children: widget.roadmap.phases.asMap().entries.map((entry) {
        final index = entry.key;
        final phase = entry.value;
        final isLast = index == widget.roadmap.phases.length - 1;
        
        return _buildPhaseCard(context, phase, isLast);
      }).toList(),
    );
  }

  Widget _buildPhaseCard(BuildContext context, RoadmapPhase phase, bool isLast) {
    final isExpanded = expandedPhaseId == phase.id;
    final color = _getPhaseColor(phase.type);

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              expandedPhaseId = isExpanded ? null : phase.id;
              expandedStepId = null; // Collapse steps when phase changes
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isExpanded ? color.withOpacity(0.1) : Colors.white,
              border: Border.all(
                color: isExpanded ? color : Colors.grey.shade300,
                width: isExpanded ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isExpanded
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          phase.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phase.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isExpanded ? color : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phase.subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Duration badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        phase.duration,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Expand icon
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: color,
                    ),
                  ],
                ),
                
                // Expanded content
                if (isExpanded) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildStepsList(context, phase, color),
                ],
              ],
            ),
          ),
        ),
        
        // Connector line
        if (!isLast)
          Container(
            margin: const EdgeInsets.only(left: 48),
            width: 3,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.5),
                  _getPhaseColor(widget.roadmap.phases[widget.roadmap.phases.indexOf(phase) + 1].type).withOpacity(0.5),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStepsList(BuildContext context, RoadmapPhase phase, Color color) {
    return Column(
      children: phase.steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final stepId = '${phase.id}_$index';
        final isStepExpanded = expandedStepId == stepId;
        
        return _buildStepCard(context, step, stepId, isStepExpanded, color, index + 1);
      }).toList(),
    );
  }

  Widget _buildStepCard(
    BuildContext context,
    RoadmapStep step,
    String stepId,
    bool isExpanded,
    Color color,
    int stepNumber,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isExpanded ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? color : Colors.grey.shade200,
          width: isExpanded ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            expandedStepId = isExpanded ? null : stepId;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Step number
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$stepNumber',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                step.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isExpanded ? color : Colors.black87,
                                ),
                              ),
                            ),
                            if (step.isOptional)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Optional',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Expand icon
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: color,
                    size: 20,
                  ),
                ],
              ),
              
              // Expanded details
              if (isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                
                // Details
                ...step.details.map((detail) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              detail,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                
                // Resources
                if (step.resources.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.link, size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Resources',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...step.resources.map((resource) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• $resource',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
                
                // Tip
                if (step.tip != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step.tip!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.amber.shade900,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getPhaseColor(PhaseType type) {
    switch (type) {
      case PhaseType.school:
        return Colors.blue;
      case PhaseType.university:
        return Colors.purple;
      case PhaseType.skills:
        return Colors.orange;
      case PhaseType.career:
        return Colors.green;
    }
  }
}

