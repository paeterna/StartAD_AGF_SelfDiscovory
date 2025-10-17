import 'package:flutter/foundation.dart';

/// UAE-specific career roadmap entity
@immutable
class CareerRoadmap {
  const CareerRoadmap({
    required this.careerTitle,
    required this.schoolSubjects,
    required this.schoolAdvice,
    required this.universityPrograms,
    required this.skillsCertifications,
    required this.careerProgression,
  });

  final String careerTitle;
  final List<String> schoolSubjects;
  final String schoolAdvice;
  final List<UniversityProgram> universityPrograms;
  final List<SkillCertification> skillsCertifications;
  final List<CareerProgressionStep> careerProgression;

  factory CareerRoadmap.fromJson(String careerTitle, Map<String, dynamic> json) {
    return CareerRoadmap(
      careerTitle: careerTitle,
      schoolSubjects: (json['school_subjects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      schoolAdvice: json['school_advice'] as String,
      universityPrograms: (json['university_programs'] as List<dynamic>)
          .map((e) => UniversityProgram.fromJson(e as Map<String, dynamic>))
          .toList(),
      skillsCertifications: (json['skills_certifications'] as List<dynamic>)
          .map((e) => SkillCertification.fromJson(e as Map<String, dynamic>))
          .toList(),
      careerProgression: (json['career_progression'] as List<dynamic>)
          .map((e) => CareerProgressionStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'school_subjects': schoolSubjects,
      'school_advice': schoolAdvice,
      'university_programs': universityPrograms.map((e) => e.toJson()).toList(),
      'skills_certifications': skillsCertifications.map((e) => e.toJson()).toList(),
      'career_progression': careerProgression.map((e) => e.toJson()).toList(),
    };
  }
}

/// University program recommendation
@immutable
class UniversityProgram {
  const UniversityProgram({
    required this.degree,
    required this.universities,
    required this.duration,
  });

  final String degree;
  final List<String> universities;
  final String duration;

  factory UniversityProgram.fromJson(Map<String, dynamic> json) {
    return UniversityProgram(
      degree: json['degree'] as String,
      universities: (json['universities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      duration: json['duration'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'degree': degree,
      'universities': universities,
      'duration': duration,
    };
  }
}

/// Skill or certification recommendation
@immutable
class SkillCertification {
  const SkillCertification({
    required this.name,
    required this.provider,
    required this.importance,
    required this.uaeRelevance,
  });

  final String name;
  final String provider;
  final String importance; // high, medium
  final String uaeRelevance;

  factory SkillCertification.fromJson(Map<String, dynamic> json) {
    return SkillCertification(
      name: json['name'] as String,
      provider: json['provider'] as String,
      importance: json['importance'] as String,
      uaeRelevance: json['uae_relevance'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'provider': provider,
      'importance': importance,
      'uae_relevance': uaeRelevance,
    };
  }
}

/// Career progression step
@immutable
class CareerProgressionStep {
  const CareerProgressionStep({
    required this.level,
    required this.title,
    required this.years,
    required this.responsibilities,
    required this.salaryRangeAed,
  });

  final String level; // Entry, Mid, Senior
  final String title;
  final String years;
  final String responsibilities;
  final String salaryRangeAed;

  factory CareerProgressionStep.fromJson(Map<String, dynamic> json) {
    return CareerProgressionStep(
      level: json['level'] as String,
      title: json['title'] as String,
      years: json['years'] as String,
      responsibilities: json['responsibilities'] as String,
      salaryRangeAed: json['salary_range_aed'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'title': title,
      'years': years,
      'responsibilities': responsibilities,
      'salary_range_aed': salaryRangeAed,
    };
  }
}

