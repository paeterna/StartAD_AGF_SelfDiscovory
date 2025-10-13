import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/quiz_instrument.dart';
import 'quiz_item_seeder.dart';

/// Provider for QuizItemSeeder service
final Provider<QuizItemSeeder> quizItemSeederProvider = Provider<QuizItemSeeder>((ref) {
  return QuizItemSeeder(Supabase.instance.client);
});

/// Provider to fetch quiz items from database
final quizItemsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, QuizItemsParams>(
  (ref, params) async {
    final seeder = ref.watch(quizItemSeederProvider);
    return seeder.fetchQuizItems(
      instrument: params.instrument,
      language: params.language,
    );
  },
);

/// Provider to get quiz instrument metadata
final quizMetadataProvider =
    FutureProvider.family<QuizInstrument, QuizItemsParams>(
  (ref, params) async {
    final seeder = ref.watch(quizItemSeederProvider);
    return seeder.getInstrumentMetadata(
      instrument: params.instrument,
      language: params.language,
    );
  },
);

/// Parameters for quiz providers
@immutable
class QuizItemsParams {
  final String instrument;
  final String language;

  const QuizItemsParams({
    required this.instrument,
    required this.language,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizItemsParams &&
          runtimeType == other.runtimeType &&
          instrument == other.instrument &&
          language == other.language;

  @override
  int get hashCode => instrument.hashCode ^ language.hashCode;
}
