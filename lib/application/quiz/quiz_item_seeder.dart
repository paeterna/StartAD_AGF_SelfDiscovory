import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/quiz_instrument.dart';

/// Service to load quiz instruments from JSON assets and seed them into Supabase
class QuizItemSeeder {
  final SupabaseClient _supabase;

  const QuizItemSeeder(this._supabase);

  /// Load a quiz instrument from JSON asset
  Future<QuizInstrument> loadInstrument({
    required String instrument,
    required String language,
  }) async {
    final path = 'assets/assessments/${instrument}_$language.json';
    final jsonString = await rootBundle.loadString(path);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return QuizInstrument.fromJson(json);
  }

  /// Check if quiz items already exist in database
  Future<bool> instrumentExists({
    required String instrument,
    required String language,
  }) async {
    final result = await _supabase
        .from('quiz_items')
        .select('id')
        .eq('instrument', instrument)
        .eq('language', language)
        .limit(1);

    return result.isNotEmpty;
  }

  /// Seed quiz items from JSON asset into database
  Future<void> seedInstrument({
    required String instrument,
    required String language,
    bool force = false,
  }) async {
    // Check if already seeded
    if (!force &&
        await instrumentExists(instrument: instrument, language: language)) {
      return; // Already seeded, skip
    }

    // Load instrument from JSON
    final quizInstrument = await loadInstrument(
      instrument: instrument,
      language: language,
    );

    // Delete existing items if force=true
    if (force) {
      await _supabase
          .from('quiz_items')
          .delete()
          .eq('instrument', instrument)
          .eq('language', language);
    }

    // Insert items
    final rows = quizInstrument.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return {
        'instrument': quizInstrument.instrument,
        'version': quizInstrument.version,
        'language': quizInstrument.language,
        'sort_order': index + 1,
        'question_text': item.text,
        'feature_key': item.featureKey,
        'direction': item.direction,
        'weight': item.weight,
      };
    }).toList();

    await _supabase.from('quiz_items').insert(rows);
  }

  /// Seed all available instruments (RIASEC Mini + IPIP-50 in EN and AR)
  Future<void> seedAll({bool force = false}) async {
    final instruments = [
      {'instrument': 'riasec_mini', 'language': 'en'},
      {'instrument': 'riasec_mini', 'language': 'ar'},
      {'instrument': 'ipip50', 'language': 'en'},
      {'instrument': 'ipip50', 'language': 'ar'},
    ];

    for (final config in instruments) {
      await seedInstrument(
        instrument: config['instrument']!,
        language: config['language']!,
        force: force,
      );
    }
  }

  /// Get quiz metadata (title, description, instructions) for display
  Future<QuizInstrument> getInstrumentMetadata({
    required String instrument,
    required String language,
  }) async {
    return loadInstrument(instrument: instrument, language: language);
  }

  /// Fetch quiz items from database for assessment
  Future<List<Map<String, dynamic>>> fetchQuizItems({
    required String instrument,
    required String language,
  }) async {
    final result = await _supabase
        .from('quiz_items')
        .select()
        .eq('instrument', instrument)
        .eq('language', language)
        .order('sort_order');

    return List<Map<String, dynamic>>.from(result);
  }
}
