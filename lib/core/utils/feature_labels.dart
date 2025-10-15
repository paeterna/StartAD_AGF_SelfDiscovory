/// Utility functions for feature label formatting
library;

/// Map of feature keys to short display labels (without family prefixes)
const Map<String, String> _featureShortLabels = {
  // Interests (RIASEC)
  'interest_creative': 'Creative',
  'interest_social': 'Social',
  'interest_analytical': 'Analytical',
  'interest_practical': 'Practical',
  'interest_enterprising': 'Enterprising',
  'interest_conventional': 'Conventional',

  // Cognition
  'cognition_verbal': 'Verbal',
  'cognition_quantitative': 'Quantitative',
  'cognition_spatial': 'Spatial',
  'cognition_memory': 'Memory',
  'cognition_attention': 'Attention',
  'cognition_problem_solving': 'Problem Solving',

  // Traits
  'trait_grit': 'Grit',
  'trait_curiosity': 'Curiosity',
  'trait_collaboration': 'Collaboration',
  'trait_conscientiousness': 'Conscientiousness',
  'trait_openness': 'Openness',
  'trait_adaptability': 'Adaptability',
  'trait_communication': 'Communication',
  'trait_leadership': 'Leadership',
  'trait_creativity': 'Creativity',
  'trait_emotional_intelligence': 'Emotional Intelligence',
};

/// Get short label from feature key (strips family prefix)
/// Example: 'interest_creative' => 'Creative'
String getShortFeatureLabel(String featureKey) {
  // Try exact match first
  if (_featureShortLabels.containsKey(featureKey)) {
    return _featureShortLabels[featureKey]!;
  }

  // Fallback: strip prefix and format
  return _stripPrefixAndFormat(featureKey);
}

/// Strip family prefix (interest_, cognition_, trait_) and format
String _stripPrefixAndFormat(String featureKey) {
  final prefixes = ['interest_', 'cognition_', 'trait_'];

  for (final prefix in prefixes) {
    if (featureKey.startsWith(prefix)) {
      final withoutPrefix = featureKey.substring(prefix.length);
      return _formatLabel(withoutPrefix);
    }
  }

  // No prefix found, just format the key
  return _formatLabel(featureKey);
}

/// Format a snake_case string to Title Case
String _formatLabel(String text) {
  return text
      .split('_')
      .map(
        (word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
      )
      .join(' ');
}

/// Check if a label still has a family prefix
bool hasPrefix(String label) {
  final lowerLabel = label.toLowerCase();
  return lowerLabel.startsWith('interest_') ||
      lowerLabel.startsWith('cognition_') ||
      lowerLabel.startsWith('trait_');
}
