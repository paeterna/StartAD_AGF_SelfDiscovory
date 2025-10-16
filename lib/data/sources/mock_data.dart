import '../../domain/entities/assessment.dart';
import '../../domain/entities/career.dart';
import '../../domain/entities/roadmap.dart';
import '../../domain/repositories/assessment_repository.dart';

/// Mock seed data for development
class MockData {
  MockData._();

  // Career seed data
  static final List<Career> careers = [
    const Career(
      id: 'career_1',
      title: 'Software Engineer',
      description:
          'Design, develop, and maintain software applications and systems.',
      tags: ['analytical', 'creative', 'technical', 'problem-solving'],
      cluster: 'Technology',
      matchScore: 0,
    ),
    const Career(
      id: 'career_2',
      title: 'Data Scientist',
      description:
          'Analyze complex data to help organizations make informed decisions.',
      tags: ['analytical', 'mathematical', 'technical', 'detail-oriented'],
      cluster: 'STEM',
      matchScore: 0,
    ),
    const Career(
      id: 'career_3',
      title: 'Graphic Designer',
      description:
          'Create visual concepts to communicate ideas that inspire and inform.',
      tags: ['creative', 'artistic', 'visual', 'innovative'],
      cluster: 'Arts & Humanities',
      matchScore: 0,
    ),
    const Career(
      id: 'career_4',
      title: 'Marketing Manager',
      description:
          'Plan and execute marketing strategies to promote products and services.',
      tags: ['social', 'creative', 'strategic', 'communicative'],
      cluster: 'Business & Finance',
      matchScore: 0,
    ),
    const Career(
      id: 'career_5',
      title: 'Registered Nurse',
      description:
          'Provide and coordinate patient care in healthcare settings.',
      tags: ['caring', 'detail-oriented', 'social', 'resilient'],
      cluster: 'Healthcare',
      matchScore: 0,
    ),
    const Career(
      id: 'career_6',
      title: 'Teacher',
      description:
          'Educate students and foster a love of learning in various subjects.',
      tags: ['social', 'patient', 'communicative', 'caring'],
      cluster: 'Education',
      matchScore: 0,
    ),
    const Career(
      id: 'career_7',
      title: 'Mechanical Engineer',
      description: 'Design and build mechanical systems and devices.',
      tags: ['analytical', 'technical', 'creative', 'problem-solving'],
      cluster: 'Engineering',
      matchScore: 0,
    ),
    const Career(
      id: 'career_8',
      title: 'Financial Analyst',
      description: 'Analyze financial data to guide business decisions.',
      tags: ['analytical', 'mathematical', 'detail-oriented', 'strategic'],
      cluster: 'Business & Finance',
      matchScore: 0,
    ),
    const Career(
      id: 'career_9',
      title: 'UX Designer',
      description: 'Design user-friendly and intuitive digital experiences.',
      tags: ['creative', 'empathetic', 'technical', 'analytical'],
      cluster: 'Technology',
      matchScore: 0,
    ),
    const Career(
      id: 'career_10',
      title: 'Social Worker',
      description: 'Help individuals and communities overcome challenges.',
      tags: ['caring', 'social', 'empathetic', 'resilient'],
      cluster: 'Social Services',
      matchScore: 0,
    ),
  ];

  // Roadmap templates (steps for each career)
  static Map<String, List<RoadmapStep>> roadmapTemplates = {
    'career_1': [
      const RoadmapStep(
        id: 'step_1_1',
        careerId: 'career_1',
        title: 'Master Programming Fundamentals',
        description:
            'Learn programming basics with Python or JavaScript. Complete online courses and practice coding daily.',
        order: 1,
        category: RoadmapStepCategory.subject,
        estimatedDuration: 12,
      ),
      const RoadmapStep(
        id: 'step_1_2',
        careerId: 'career_1',
        title: 'Build Personal Projects',
        description:
            'Create 3-5 personal projects showcasing different skills (web apps, mobile apps, games).',
        order: 2,
        category: RoadmapStepCategory.project,
        estimatedDuration: 24,
      ),
      const RoadmapStep(
        id: 'step_1_3',
        careerId: 'career_1',
        title: 'Learn Data Structures & Algorithms',
        description:
            'Study common data structures and algorithms. Practice on LeetCode or HackerRank.',
        order: 3,
        category: RoadmapStepCategory.skill,
        estimatedDuration: 16,
      ),
      const RoadmapStep(
        id: 'step_1_4',
        careerId: 'career_1',
        title: 'Contribute to Open Source',
        description:
            'Find open source projects on GitHub and make contributions. Build your portfolio.',
        order: 4,
        category: RoadmapStepCategory.experience,
        estimatedDuration: 12,
      ),
      const RoadmapStep(
        id: 'step_1_5',
        careerId: 'career_1',
        title: 'Complete Internship',
        description:
            'Apply for software engineering internships. Gain real-world experience.',
        order: 5,
        category: RoadmapStepCategory.experience,
        estimatedDuration: 12,
      ),
    ],
    'career_2': [
      const RoadmapStep(
        id: 'step_2_1',
        careerId: 'career_2',
        title: 'Learn Statistics & Mathematics',
        description:
            'Master statistics, probability, and linear algebra fundamentals.',
        order: 1,
        category: RoadmapStepCategory.subject,
        estimatedDuration: 16,
      ),
      const RoadmapStep(
        id: 'step_2_2',
        careerId: 'career_2',
        title: 'Master Python & Data Libraries',
        description:
            'Learn Python, pandas, NumPy, and scikit-learn for data analysis.',
        order: 2,
        category: RoadmapStepCategory.skill,
        estimatedDuration: 12,
      ),
      const RoadmapStep(
        id: 'step_2_3',
        careerId: 'career_2',
        title: 'Complete Data Science Projects',
        description:
            'Work on Kaggle competitions and create data analysis projects.',
        order: 3,
        category: RoadmapStepCategory.project,
        estimatedDuration: 20,
      ),
      const RoadmapStep(
        id: 'step_2_4',
        careerId: 'career_2',
        title: 'Learn Machine Learning',
        description: 'Study ML algorithms, deep learning, and neural networks.',
        order: 4,
        category: RoadmapStepCategory.skill,
        estimatedDuration: 16,
      ),
      const RoadmapStep(
        id: 'step_2_5',
        careerId: 'career_2',
        title: 'Get Certified',
        description:
            'Obtain certifications like Google Data Analytics or IBM Data Science.',
        order: 5,
        category: RoadmapStepCategory.certification,
        estimatedDuration: 8,
      ),
    ],
    'career_3': [
      const RoadmapStep(
        id: 'step_3_1',
        careerId: 'career_3',
        title: 'Master Design Fundamentals',
        description:
            'Learn color theory, typography, layout, and composition principles.',
        order: 1,
        category: RoadmapStepCategory.subject,
        estimatedDuration: 12,
      ),
      const RoadmapStep(
        id: 'step_3_2',
        careerId: 'career_3',
        title: 'Learn Design Software',
        description:
            'Become proficient in Adobe Photoshop, Illustrator, and Figma.',
        order: 2,
        category: RoadmapStepCategory.skill,
        estimatedDuration: 16,
      ),
      const RoadmapStep(
        id: 'step_3_3',
        careerId: 'career_3',
        title: 'Build Design Portfolio',
        description:
            'Create 10-15 diverse design projects showcasing your skills.',
        order: 3,
        category: RoadmapStepCategory.project,
        estimatedDuration: 24,
      ),
      const RoadmapStep(
        id: 'step_3_4',
        careerId: 'career_3',
        title: 'Freelance Projects',
        description: 'Take on freelance design work to gain client experience.',
        order: 4,
        category: RoadmapStepCategory.experience,
        estimatedDuration: 16,
      ),
      const RoadmapStep(
        id: 'step_3_5',
        careerId: 'career_3',
        title: 'Join Design Community',
        description:
            'Participate in design communities, attend workshops, network with professionals.',
        order: 5,
        category: RoadmapStepCategory.activity,
        estimatedDuration: 8,
      ),
    ],
  };

  // Assessment templates (quizzes and games)
  static final List<AssessmentTemplate> assessmentTemplates = [
    AssessmentTemplate(
      id: 'quiz_personality',
      title: 'Personality Discovery Quiz',
      description: 'Discover your core personality traits and strengths.',
      type: AssessmentType.quiz,
      estimatedMinutes: 5,
      questions: [
        const AssessmentQuestion(
          id: 'q1',
          text: 'When faced with a problem, I prefer to:',
          trait: 'analytical',
          options: [
            AssessmentOption(
              id: 'q1_a',
              text: 'Analyze it logically and systematically',
              score: 10,
            ),
            AssessmentOption(
              id: 'q1_b',
              text: 'Think creatively about unique solutions',
              score: 5,
            ),
            AssessmentOption(
              id: 'q1_c',
              text: 'Discuss it with others to get input',
              score: 3,
            ),
          ],
        ),
        const AssessmentQuestion(
          id: 'q2',
          text: 'I feel most energized when:',
          trait: 'social',
          options: [
            AssessmentOption(
              id: 'q2_a',
              text: 'Working independently on challenging tasks',
              score: 3,
            ),
            AssessmentOption(
              id: 'q2_b',
              text: 'Collaborating with a team',
              score: 10,
            ),
            AssessmentOption(
              id: 'q2_c',
              text: 'Leading and organizing group activities',
              score: 8,
            ),
          ],
        ),
        const AssessmentQuestion(
          id: 'q3',
          text: 'When starting a new project, I:',
          trait: 'creative',
          options: [
            AssessmentOption(
              id: 'q3_a',
              text: 'Follow established methods and best practices',
              score: 3,
            ),
            AssessmentOption(
              id: 'q3_b',
              text: 'Experiment with innovative approaches',
              score: 10,
            ),
            AssessmentOption(
              id: 'q3_c',
              text: 'Combine proven methods with new ideas',
              score: 7,
            ),
          ],
        ),
        const AssessmentQuestion(
          id: 'q4',
          text: 'I am most interested in:',
          trait: 'curiosity',
          options: [
            AssessmentOption(
              id: 'q4_a',
              text: 'Learning new skills and exploring topics',
              score: 10,
            ),
            AssessmentOption(
              id: 'q4_b',
              text: 'Mastering what I already know',
              score: 5,
            ),
            AssessmentOption(
              id: 'q4_c',
              text: 'Applying knowledge to practical problems',
              score: 7,
            ),
          ],
        ),
        const AssessmentQuestion(
          id: 'q5',
          text: 'When working on tasks, I:',
          trait: 'detail-oriented',
          options: [
            AssessmentOption(
              id: 'q5_a',
              text: 'Focus on the big picture and overall goals',
              score: 3,
            ),
            AssessmentOption(
              id: 'q5_b',
              text: 'Pay close attention to every detail',
              score: 10,
            ),
            AssessmentOption(
              id: 'q5_c',
              text: 'Balance between details and overview',
              score: 6,
            ),
          ],
        ),
      ],
    ),
    AssessmentTemplate(
      id: 'quiz_interests',
      title: 'Interest Explorer',
      description: 'Identify your key interests and passions.',
      type: AssessmentType.quiz,
      estimatedMinutes: 4,
      questions: [
        const AssessmentQuestion(
          id: 'i1',
          text: 'In my free time, I enjoy:',
          trait: 'artistic',
          options: [
            AssessmentOption(
              id: 'i1_a',
              text: 'Creating art, music, or writing',
              score: 10,
            ),
            AssessmentOption(
              id: 'i1_b',
              text: 'Building or fixing things',
              score: 5,
            ),
            AssessmentOption(
              id: 'i1_c',
              text: 'Reading or researching topics',
              score: 7,
            ),
          ],
        ),
        const AssessmentQuestion(
          id: 'i2',
          text: 'I find it rewarding to:',
          trait: 'caring',
          options: [
            AssessmentOption(
              id: 'i2_a',
              text: 'Help others overcome challenges',
              score: 10,
            ),
            AssessmentOption(
              id: 'i2_b',
              text: 'Solve complex technical problems',
              score: 5,
            ),
            AssessmentOption(
              id: 'i2_c',
              text: 'Create something innovative',
              score: 6,
            ),
          ],
        ),
        const AssessmentQuestion(
          id: 'i3',
          text: 'I am drawn to careers that involve:',
          trait: 'technical',
          options: [
            AssessmentOption(
              id: 'i3_a',
              text: 'Working with technology and systems',
              score: 10,
            ),
            AssessmentOption(
              id: 'i3_b',
              text: 'Interacting with people',
              score: 3,
            ),
            AssessmentOption(
              id: 'i3_c',
              text: 'Creative expression and design',
              score: 5,
            ),
          ],
        ),
      ],
    ),
    AssessmentTemplate(
      id: 'game_pattern',
      title: 'Pattern Recognition Game',
      description: 'Test your analytical and problem-solving skills.',
      type: AssessmentType.game,
      estimatedMinutes: 3,
      questions: [
        const AssessmentQuestion(
          id: 'g1',
          text: 'What comes next in this sequence: 2, 4, 8, 16, ?',
          trait: 'analytical',
          options: [
            AssessmentOption(id: 'g1_a', text: '24', score: 0),
            AssessmentOption(id: 'g1_b', text: '32', score: 10),
            AssessmentOption(id: 'g1_c', text: '20', score: 0),
          ],
        ),
      ],
    ),
  ];
}
