// =====================================================
// Single Canonical Feature Space (22D)
// =====================================================
//
// This registry defines the ONLY feature keys allowed in the system.
// All assessments (quizzes + games) must map their items to these 22 canonical features.
//
// DO NOT add new feature keys. Instead, map quiz/game items to these canonical keys
// using the itemContributionMap in your assessment metadata.

// =====================================================
// Canonical Features (ordered by DB features.id)
// =====================================================

/// Canonical feature definition
class CanonicalFeature {
  final String key;
  final String family;
  final String labelEn;
  final String labelAr;

  const CanonicalFeature({
    required this.key,
    required this.family,
    required this.labelEn,
    required this.labelAr,
  });
}

/// The 22 canonical features in order by DB features.id
/// This order MUST match the order in the database migration 00003
const List<CanonicalFeature> kCanonicalFeatures = [
  // Interests (6 features - Holland RIASEC model mapped)
  CanonicalFeature(
    key: 'interest_creative',
    family: 'interests',
    labelEn: 'Creative & Artistic',
    labelAr: 'إبداعي وفني',
  ),
  CanonicalFeature(
    key: 'interest_social',
    family: 'interests',
    labelEn: 'Social & Helping',
    labelAr: 'اجتماعي ومساعدة',
  ),
  CanonicalFeature(
    key: 'interest_analytical',
    family: 'interests',
    labelEn: 'Analytical & Investigative',
    labelAr: 'تحليلي واستقصائي',
  ),
  CanonicalFeature(
    key: 'interest_practical',
    family: 'interests',
    labelEn: 'Practical & Hands-on',
    labelAr: 'عملي وتطبيقي',
  ),
  CanonicalFeature(
    key: 'interest_enterprising',
    family: 'interests',
    labelEn: 'Enterprising & Leadership',
    labelAr: 'مبادر وقيادي',
  ),
  CanonicalFeature(
    key: 'interest_conventional',
    family: 'interests',
    labelEn: 'Conventional & Organizational',
    labelAr: 'تقليدي وتنظيمي',
  ),

  // Cognition (6 features)
  CanonicalFeature(
    key: 'cognition_verbal',
    family: 'cognition',
    labelEn: 'Verbal Reasoning',
    labelAr: 'التفكير اللفظي',
  ),
  CanonicalFeature(
    key: 'cognition_quantitative',
    family: 'cognition',
    labelEn: 'Quantitative Reasoning',
    labelAr: 'التفكير الكمي',
  ),
  CanonicalFeature(
    key: 'cognition_spatial',
    family: 'cognition',
    labelEn: 'Spatial Reasoning',
    labelAr: 'التفكير المكاني',
  ),
  CanonicalFeature(
    key: 'cognition_memory',
    family: 'cognition',
    labelEn: 'Memory & Recall',
    labelAr: 'الذاكرة والاسترجاع',
  ),
  CanonicalFeature(
    key: 'cognition_attention',
    family: 'cognition',
    labelEn: 'Attention & Focus',
    labelAr: 'الانتباه والتركيز',
  ),
  CanonicalFeature(
    key: 'cognition_problem_solving',
    family: 'cognition',
    labelEn: 'Problem Solving',
    labelAr: 'حل المشكلات',
  ),

  // Traits (10 features)
  CanonicalFeature(
    key: 'trait_grit',
    family: 'traits',
    labelEn: 'Grit & Persistence',
    labelAr: 'المثابرة والإصرار',
  ),
  CanonicalFeature(
    key: 'trait_curiosity',
    family: 'traits',
    labelEn: 'Curiosity',
    labelAr: 'حب الاستطلاع',
  ),
  CanonicalFeature(
    key: 'trait_collaboration',
    family: 'traits',
    labelEn: 'Collaboration',
    labelAr: 'التعاون',
  ),
  CanonicalFeature(
    key: 'trait_conscientiousness',
    family: 'traits',
    labelEn: 'Conscientiousness',
    labelAr: 'الضمير الحي',
  ),
  CanonicalFeature(
    key: 'trait_openness',
    family: 'traits',
    labelEn: 'Openness',
    labelAr: 'الانفتاح',
  ),
  CanonicalFeature(
    key: 'trait_adaptability',
    family: 'traits',
    labelEn: 'Adaptability',
    labelAr: 'القدرة على التكيف',
  ),
  CanonicalFeature(
    key: 'trait_communication',
    family: 'traits',
    labelEn: 'Communication',
    labelAr: 'التواصل',
  ),
  CanonicalFeature(
    key: 'trait_leadership',
    family: 'traits',
    labelEn: 'Leadership',
    labelAr: 'القيادة',
  ),
  CanonicalFeature(
    key: 'trait_creativity',
    family: 'traits',
    labelEn: 'Creativity',
    labelAr: 'الإبداع',
  ),
  CanonicalFeature(
    key: 'trait_emotional_intelligence',
    family: 'traits',
    labelEn: 'Emotional Intelligence',
    labelAr: 'الذكاء العاطفي',
  ),
];

// =====================================================
// Helper Maps and Functions
// =====================================================

/// Map of canonical keys to features for quick lookup
final Map<String, CanonicalFeature> kFeaturesByKey = {
  for (final f in kCanonicalFeatures) f.key: f,
};

/// Map of canonical keys to their index (for vector ordering)
final Map<String, int> kFeatureIndex = {
  for (int i = 0; i < kCanonicalFeatures.length; i++)
    kCanonicalFeatures[i].key: i,
};

/// Validates that a key is canonical
bool isCanonicalKey(String key) {
  return kFeaturesByKey.containsKey(key);
}

/// Throws if any key is not canonical
void assertCanonicalKeys(Iterable<String> keys) {
  for (final k in keys) {
    if (!isCanonicalKey(k)) {
      throw StateError(
        'Non-canonical feature key encountered: "$k". '
        'Only the 22 canonical features are allowed. '
        'See lib/core/scoring/features_registry.dart',
      );
    }
  }
}

/// Get features by family
List<CanonicalFeature> getFeaturesByFamily(String family) {
  return kCanonicalFeatures.where((f) => f.family == family).toList();
}

// =====================================================
// Feature Contribution Mapping
// =====================================================

/// Represents how a quiz/game item contributes to canonical features
class FeatureContribution {
  /// The canonical feature key
  final String key;

  /// The weight/direction of contribution
  /// - Positive values (e.g., 1.0) = positive contribution
  /// - Negative values (e.g., -1.0) = negative/reverse contribution
  final double weight;

  const FeatureContribution({
    required this.key,
    required this.weight,
  });

  FeatureContribution copyWith({String? key, double? weight}) {
    return FeatureContribution(
      key: key ?? this.key,
      weight: weight ?? this.weight,
    );
  }
}

// =====================================================
// RIASEC → Canonical Mapping
// =====================================================

/// Maps RIASEC bare terms to canonical interest features
/// Use this when processing RIASEC-based quizzes
const Map<String, String> kRiasecToCanonical = {
  'realistic': 'interest_practical', // R → Practical/Hands-on
  'investigative': 'interest_analytical', // I → Analytical/Investigative
  'artistic': 'interest_creative', // A → Creative/Artistic
  'social': 'interest_social', // S → Social/Helping
  'enterprising': 'interest_enterprising', // E → Enterprising/Leadership
  'conventional': 'interest_conventional', // C → Conventional/Organizational
};

/// Convert a RIASEC key to canonical (handles bare or prefixed forms)
String riasecToCanonical(String riasecKey) {
  // Remove riasec_ prefix if present
  final bareKey = riasecKey.replaceFirst('riasec_', '');

  final canonical = kRiasecToCanonical[bareKey];
  if (canonical == null) {
    throw StateError(
      'Unknown RIASEC key: "$riasecKey". '
      'Valid RIASEC keys: ${kRiasecToCanonical.keys.join(", ")}',
    );
  }

  return canonical;
}

/// Check if a key is a RIASEC key (bare or prefixed)
bool isRiasecKey(String key) {
  final bareKey = key.replaceFirst('riasec_', '');
  return kRiasecToCanonical.containsKey(bareKey);
}

// =====================================================
// Big Five (IPIP-50) → Canonical Mapping
// =====================================================

/// Maps Big Five personality dimensions to canonical trait features
/// Big Five traits are mapped to the most closely related canonical traits
const Map<String, String> kBigFiveToCanonical = {
  // Extraversion → Communication & Leadership
  'extraversion': 'trait_communication',

  // Agreeableness → Collaboration & Emotional Intelligence
  'agreeableness': 'trait_collaboration',

  // Conscientiousness → Conscientiousness (direct mapping)
  'conscientiousness': 'trait_conscientiousness',

  // Emotional Stability (Neuroticism reversed) → Emotional Intelligence & Adaptability
  'emotional_stability': 'trait_emotional_intelligence',
  'neuroticism': 'trait_emotional_intelligence', // Reverse scored
  // Openness → Openness, Curiosity, & Creativity
  'openness': 'trait_openness',
};

/// Convert a Big Five key to canonical trait feature
String bigFiveToCanonical(String bigFiveKey) {
  final lowerKey = bigFiveKey.toLowerCase().trim();

  final canonical = kBigFiveToCanonical[lowerKey];
  if (canonical == null) {
    throw StateError(
      'Unknown Big Five key: "$bigFiveKey". '
      'Valid Big Five keys: ${kBigFiveToCanonical.keys.join(", ")}',
    );
  }

  return canonical;
}

/// Check if a key is a Big Five key
bool isBigFiveKey(String key) {
  final lowerKey = key.toLowerCase().trim();
  return kBigFiveToCanonical.containsKey(lowerKey);
}
