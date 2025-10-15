/// Model for quiz instrument metadata and items loaded from JSON assets
class QuizInstrument {
  final String instrument;
  final String version;
  final String language;
  final String title;
  final String description;
  final String instructions;
  final QuizScale? scale; // Optional for forced choice quizzes
  final List<QuizItem> items;
  final String? responseType; // 'likert' or 'single_choice'

  const QuizInstrument({
    required this.instrument,
    required this.version,
    required this.language,
    required this.title,
    required this.description,
    required this.instructions,
    this.scale,
    required this.items,
    this.responseType,
  });

  factory QuizInstrument.fromJson(Map<String, dynamic> json) {
    final responseType = json['response_type'] as String?;

    return QuizInstrument(
      instrument: json['instrument'] as String,
      version: json['version'] as String,
      language: json['language'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      instructions: json['instructions'] as String,
      scale: json['scale'] != null
          ? QuizScale.fromJson(json['scale'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List<dynamic>).map((item) {
        // Check if this is a forced choice item or likert item
        if (responseType == 'single_choice' && item['options'] != null) {
          return ForcedChoiceItem.fromJson(item as Map<String, dynamic>);
        } else {
          return QuizItem.fromJson(item as Map<String, dynamic>);
        }
      }).toList(),
      responseType: responseType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instrument': instrument,
      'version': version,
      'language': language,
      'title': title,
      'description': description,
      'instructions': instructions,
      if (scale != null) 'scale': scale!.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      if (responseType != null) 'response_type': responseType,
    };
  }
}

/// Quiz scale definition (e.g., Likert 5-point)
class QuizScale {
  final String type;
  final Map<String, String> labels;

  const QuizScale({
    required this.type,
    required this.labels,
  });

  factory QuizScale.fromJson(Map<String, dynamic> json) {
    return QuizScale(
      type: json['type'] as String,
      labels: Map<String, String>.from(json['labels'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'labels': labels,
    };
  }
}

/// Individual quiz item/question
class QuizItem {
  final String id;
  final String text;
  final String featureKey;
  final int direction;
  final double weight;

  const QuizItem({
    required this.id,
    required this.text,
    required this.featureKey,
    required this.direction,
    required this.weight,
  });

  factory QuizItem.fromJson(Map<String, dynamic> json) {
    return QuizItem(
      id: json['id'] as String,
      text: json['text'] as String,
      featureKey: json['feature_key'] as String,
      direction: json['direction'] as int,
      weight: (json['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'feature_key': featureKey,
      'direction': direction,
      'weight': weight,
    };
  }
}

/// Forced choice quiz item (for onboarding-style quizzes)
class ForcedChoiceItem extends QuizItem {
  final String prompt;
  final List<ForcedChoiceOption> options;

  const ForcedChoiceItem({
    required super.id,
    required this.prompt,
    required this.options,
  }) : super(
         text: '',
         featureKey: '',
         direction: 1,
         weight: 1.0,
       );

  factory ForcedChoiceItem.fromJson(Map<String, dynamic> json) {
    return ForcedChoiceItem(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      options: (json['options'] as List<dynamic>)
          .map(
            (opt) => ForcedChoiceOption.fromJson(opt as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'options': options.map((opt) => opt.toJson()).toList(),
    };
  }
}

/// Option for forced choice item
class ForcedChoiceOption {
  final String id;
  final String text;
  final String featureKey;
  final double weight;

  const ForcedChoiceOption({
    required this.id,
    required this.text,
    required this.featureKey,
    required this.weight,
  });

  factory ForcedChoiceOption.fromJson(Map<String, dynamic> json) {
    return ForcedChoiceOption(
      id: json['id'] as String,
      text: json['text'] as String,
      featureKey: json['feature_key'] as String,
      weight: (json['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'feature_key': featureKey,
      'weight': weight,
    };
  }
}
