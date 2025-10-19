import 'enhanced_career_roadmap.dart';

/// Data Scientist career roadmap
class DataScientistRoadmap {
  static EnhancedCareerRoadmap getRoadmap() {
    return EnhancedCareerRoadmap(
      careerTitle: 'Data Scientist',
      description:
          'Analyze data and build AI models to solve real-world problems',
      estimatedDuration: '8-12 years to senior level',
      salaryRange: 'AED 10,000 - 60,000/month',
      phases: [
        // PHASE 1: SCHOOL
        RoadmapPhase(
          id: 'school',
          title: 'High School (Grades 9-12)',
          subtitle: 'Master the fundamentals',
          icon: '🎓',
          duration: '4 years',
          type: PhaseType.school,
          steps: [
            RoadmapStep(
              title: 'Mathematics & Statistics',
              description: 'Master the fundamentals',
              details: [
                'Excel in calculus and linear algebra',
                'Learn statistics and probability',
                'Understand data analysis basics',
                'Practice with real datasets',
              ],
              resources: [
                'Khan Academy - Statistics',
                'StatQuest - YouTube channel',
                'Kaggle - Practice datasets',
              ],
              tip: '💡 Data science is 80% math and statistics, 20% coding!',
            ),
            RoadmapStep(
              title: 'Programming Basics',
              description: 'Start with Python',
              details: [
                'Learn Python programming',
                'Understand basic algorithms',
                'Practice problem-solving',
                'Build simple data projects',
              ],
              resources: [
                'Python.org - Official tutorials',
                'Codecademy - Python course',
                'DataCamp - Data science track',
              ],
              tip: '💡 Python is the most popular language for data science!',
            ),
          ],
        ),

        // PHASE 2: UNIVERSITY
        RoadmapPhase(
          id: 'university',
          title: 'University (Bachelor\'s Degree)',
          subtitle: 'Relevant Degree',
          icon: '🎯',
          duration: '4 years',
          type: PhaseType.university,
          steps: [
            RoadmapStep(
              title: 'Degree Options',
              description: 'Choose your path',
              details: [
                '🏛️ Computer Science with AI focus',
                '🏛️ Data Science (if available)',
                '🏛️ Mathematics or Statistics',
                '🏛️ Engineering with analytics minor',
              ],
              resources: [
                'Khalifa University - AI program',
                'UAEU - Data Science courses',
                'AUS - CS with AI track',
              ],
              tip:
                  '💡 Take as many statistics and machine learning courses as possible!',
            ),
            RoadmapStep(
              title: 'Core Data Science Courses',
              description: 'Essential subjects',
              details: [
                '📚 Statistics & Probability - Foundation of data science',
                '📚 Linear Algebra - Machine learning math',
                '📚 Database Systems - Data storage and retrieval',
                '📚 Machine Learning - AI algorithms',
                '📚 Data Visualization - Present insights',
                '📚 Big Data Technologies - Handle large datasets',
              ],
              tip:
                  '💡 Focus on understanding concepts, not just memorizing formulas!',
            ),
            RoadmapStep(
              title: 'Practical Projects',
              description: 'Build your portfolio',
              details: [
                'Analyze real datasets from Kaggle',
                'Participate in data science competitions',
                'Build predictive models',
                'Create data visualizations',
                'Publish findings on GitHub',
              ],
              resources: [
                'Kaggle - Competitions and datasets',
                'GitHub - Host your projects',
                'Jupyter Notebooks - Document work',
              ],
              tip: '💡 Employers want to see real projects, not just grades!',
            ),
          ],
        ),

        // PHASE 3: SKILLS
        RoadmapPhase(
          id: 'skills',
          title: 'Skills & Certifications',
          subtitle: 'Build technical expertise',
          icon: '🛠️',
          duration: 'Ongoing',
          type: PhaseType.skills,
          steps: [
            RoadmapStep(
              title: 'Programming & Tools',
              description: 'Master data science stack',
              details: [
                '🐍 Python - NumPy, Pandas, Scikit-learn',
                '📊 R - Statistical analysis',
                '🗃️ SQL - Database queries',
                '📈 Tableau/Power BI - Visualization',
                '☁️ Cloud Platforms - AWS, Azure, GCP',
              ],
              resources: [
                'DataCamp - AED 150/month',
                'Coursera - IBM Data Science',
                'Kaggle - Free competitions',
              ],
              tip: '💡 Practice on real datasets from Kaggle every week!',
            ),
            RoadmapStep(
              title: 'Machine Learning Specialization',
              description: 'Dive deep into AI',
              details: [
                'Supervised Learning - Regression, Classification',
                'Unsupervised Learning - Clustering, PCA',
                'Deep Learning - Neural Networks',
                'Natural Language Processing - Text analysis',
                'Computer Vision - Image analysis',
              ],
              resources: [
                'Andrew Ng - ML Course on Coursera',
                'Fast.ai - Practical deep learning',
                'Papers with Code - Latest research',
              ],
              tip: '💡 Start with basics, then specialize in one area!',
            ),
            RoadmapStep(
              title: 'Professional Certifications',
              description: 'Validate your skills',
              details: [
                '🏅 Google Data Analytics Certificate',
                '🏅 AWS Certified Machine Learning',
                '🏅 Microsoft Azure Data Scientist',
                '🏅 Tableau Desktop Specialist',
              ],
              resources: [
                'Certifications cost AED 500-2,000',
                'Many have free preparation materials',
                'Highly valued by employers',
              ],
              tip: '💡 Cloud certifications are in huge demand!',
            ),
          ],
        ),

        // PHASE 4: CAREER
        RoadmapPhase(
          id: 'career',
          title: 'Career Progression',
          subtitle: 'Data science career',
          icon: '🚀',
          duration: '10-15+ years',
          type: PhaseType.career,
          steps: [
            RoadmapStep(
              title: 'Junior Data Analyst (Years 0-2)',
              description: 'Start with data',
              details: [
                '💰 Salary: AED 10,000 - 18,000/month',
                '📋 Role: Clean and analyze data',
                '🎯 Goals: Create reports and dashboards',
                '📊 Tasks: Learn business context',
                '🏢 Companies: Emirates NBD, du, Careem',
              ],
              resources: [
                'LinkedIn - Network with data professionals',
                'Kaggle - Build portfolio',
              ],
              tip: '💡 Start as analyst, grow into scientist!',
            ),
            RoadmapStep(
              title: 'Data Scientist (Years 2-5)',
              description: 'Build ML models',
              details: [
                '💰 Salary: AED 18,000 - 30,000/month',
                '📋 Role: Build predictive models',
                '🎯 Goals: Solve business problems with AI',
                '🏆 Achievements: Deploy models to production',
                '📈 Growth: Specialize in specific domains',
              ],
              tip: '💡 Focus on business impact, not just technical skills!',
            ),
            RoadmapStep(
              title: 'Senior Data Scientist (Years 5-8)',
              description: 'Lead data initiatives',
              details: [
                '💰 Salary: AED 30,000 - 45,000/month',
                '📋 Role: Lead complex projects',
                '🎯 Goals: Mentor junior data scientists',
                '🏆 Achievements: Drive strategic decisions',
                '👥 Leadership: Guide data science team',
              ],
              tip: '💡 Combine technical depth with business acumen!',
            ),
            RoadmapStep(
              title: 'Principal Data Scientist / Head of Data (Years 8+)',
              description: 'Shape data strategy',
              details: [
                '💰 Salary: AED 45,000 - 60,000+/month',
                '📋 Role: Define data science strategy',
                '🎯 Goals: Build world-class data team',
                '🏆 Achievements: Transform business with AI',
                '👥 Leadership: Manage 10-30+ data professionals',
              ],
              tip:
                  '💡 At this level, you\'re a business leader who happens to know data!',
            ),
          ],
        ),
      ],
    );
  }
}
