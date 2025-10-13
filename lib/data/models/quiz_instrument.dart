/// Model for quiz instrument metadata and items loaded from JSON assets
class QuizInstrument {
  final String instrument;
  final String version;
  final String language;
  final String title;
  final String description;
  final String instructions;
  final QuizScale scale;
  final List<QuizItem> items;

  const QuizInstrument({
    required this.instrument,
    required this.version,
    required this.language,
    required this.title,
    required this.description,
    required this.instructions,
    required this.scale,
    required this.items,
  });

  factory QuizInstrument.fromJson(Map<String, dynamic> json) {
    return QuizInstrument(
      instrument: json['instrument'] as String,
      version: json['version'] as String,
      language: json['language'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      instructions: json['instructions'] as String,
      scale: QuizScale.fromJson(json['scale'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((item) => QuizItem.fromJson(item as Map<String, dynamic>))
          .toList(),
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
      'scale': scale.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
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
