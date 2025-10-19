import 'enhanced_career_roadmap.dart';

/// Mobile App Developer career roadmap
class MobileAppDeveloperRoadmap {
  static EnhancedCareerRoadmap getRoadmap() {
    return EnhancedCareerRoadmap(
      careerTitle: 'Mobile App Developer',
      description: 'Build apps for iOS and Android that millions use daily',
      estimatedDuration: '6-10 years to senior level',
      salaryRange: 'AED 9,000 - 50,000/month',
      phases: [
        // PHASE 1: SCHOOL
        RoadmapPhase(
          id: 'school',
          title: 'High School (Grades 9-12)',
          subtitle: 'Start coding',
          icon: '🎓',
          duration: '4 years',
          type: PhaseType.school,
          steps: [
            RoadmapStep(
              title: 'Programming Basics',
              description: 'Start coding',
              details: [
                'Learn programming fundamentals',
                'Build simple apps',
                'Understand UI/UX basics',
                'Study successful apps',
              ],
              resources: [
                'Swift Playgrounds - iOS',
                'Android Studio tutorials',
                'Flutter - Cross-platform',
              ],
              tip: '💡 You can build your first app in a weekend!',
            ),
            RoadmapStep(
              title: 'Mobile Design Principles',
              description: 'Understand mobile UX',
              details: [
                'Study mobile interface patterns',
                'Learn touch interaction design',
                'Understand different screen sizes',
                'Practice mobile-first thinking',
              ],
              resources: [
                'Human Interface Guidelines - Apple',
                'Material Design - Google',
                'Mobile design patterns',
              ],
              tip: '💡 Great apps are intuitive - study how users think!',
            ),
          ],
        ),

        // PHASE 2: UNIVERSITY
        RoadmapPhase(
          id: 'university',
          title: 'University (Bachelor\'s Degree)',
          subtitle: 'CS Degree',
          icon: '🎯',
          duration: '4 years',
          type: PhaseType.university,
          steps: [
            RoadmapStep(
              title: 'Computer Science Degree',
              description: 'University education',
              details: [
                '🏛️ Khalifa University - CS',
                '🏛️ AUS - Computer Science',
                '🏛️ UAEU - Software Engineering',
                '🏛️ Focus on mobile development courses',
              ],
              resources: [
                'Khalifa CS',
                'AUS CS',
                'UAEU SE',
              ],
              tip: '💡 Build apps during university - publish to App Store!',
            ),
            RoadmapStep(
              title: 'Mobile Development Courses',
              description: 'Specialized mobile courses',
              details: [
                '📱 Mobile Application Development',
                '📱 Human-Computer Interaction',
                '📱 Software Engineering for Mobile',
                '📱 Database Systems for Apps',
                '📱 Cloud Computing Integration',
                '📱 Mobile Security Principles',
              ],
              tip: '💡 Take electives in mobile development whenever possible!',
            ),
            RoadmapStep(
              title: 'Build Mobile Apps',
              description: 'Create your app portfolio',
              details: [
                'Develop 3-5 complete mobile apps',
                'Publish apps to app stores',
                'Get user feedback and iterate',
                'Include different app types (utility, game, social)',
                'Document your development process',
              ],
              resources: [
                'App Store Connect - iOS publishing',
                'Google Play Console - Android',
                'Firebase - Backend services',
              ],
              tip: '💡 Published apps show you can complete projects!',
            ),
          ],
        ),

        // PHASE 3: SKILLS
        RoadmapPhase(
          id: 'skills',
          title: 'Skills & Certifications',
          subtitle: 'Master platforms',
          icon: '🛠️',
          duration: 'Ongoing',
          type: PhaseType.skills,
          steps: [
            RoadmapStep(
              title: 'Mobile Development',
              description: 'Platform expertise',
              details: [
                '🍎 iOS - Swift, SwiftUI',
                '🤖 Android - Kotlin, Jetpack Compose',
                '🦋 Flutter - Cross-platform (Dart)',
                '⚛️ React Native - JavaScript',
              ],
              resources: [
                'Apple Developer docs',
                'Android Developers',
                'Flutter.dev tutorials',
              ],
              tip:
                  '💡 Flutter lets you build for iOS AND Android with one codebase!',
            ),
            RoadmapStep(
              title: 'Backend & Cloud Services',
              description: 'Connect your apps to the cloud',
              details: [
                'REST APIs - Data communication',
                'Firebase - Google\'s mobile platform',
                'AWS Mobile - Amazon cloud services',
                'Push Notifications - User engagement',
                'App Analytics - Track user behavior',
              ],
              resources: [
                'Firebase documentation',
                'AWS Amplify tutorials',
                'Postman - API testing',
              ],
              tip: '💡 Modern apps need cloud backends!',
            ),
            RoadmapStep(
              title: 'Mobile Development Certifications',
              description: 'Validate your expertise',
              details: [
                '🏅 Google Associate Android Developer',
                '🏅 Apple App Development with Swift',
                '🏅 Flutter Certified Developer',
                '🏅 AWS Mobile Specialty',
              ],
              resources: [
                'Google Developer Certification',
                'Apple Developer Program',
                'Flutter certification program',
              ],
              tip:
                  '💡 Certifications help but your published apps matter more!',
            ),
          ],
        ),

        // PHASE 4: CAREER
        RoadmapPhase(
          id: 'career',
          title: 'Career Progression',
          subtitle: 'Mobile dev career',
          icon: '🚀',
          duration: '8-12+ years',
          type: PhaseType.career,
          steps: [
            RoadmapStep(
              title: 'Junior Mobile Developer (Years 0-2)',
              description: 'Start building apps',
              details: [
                '💰 Salary: AED 9,000 - 16,000/month',
                '📋 Role: Develop app features',
                '🎯 Goals: Fix bugs and crashes',
                '📊 Tasks: Optimize performance',
                '🏢 Companies: Careem, Noon, Talabat',
              ],
              resources: [
                'App Store - Publish apps',
                'Google Play - Android apps',
              ],
              tip: '💡 Build your own apps on the side - passive income!',
            ),
            RoadmapStep(
              title: 'Mobile Developer (Years 2-5)',
              description: 'Become platform expert',
              details: [
                '💰 Salary: AED 16,000 - 25,000/month',
                '📋 Role: Lead app development',
                '🎯 Goals: Architect mobile solutions',
                '🏆 Achievements: Ship successful apps',
                '📈 Growth: Specialize in iOS or Android',
              ],
              tip: '💡 Master one platform deeply, then learn others!',
            ),
            RoadmapStep(
              title: 'Senior Mobile Developer (Years 5-8)',
              description: 'Lead mobile initiatives',
              details: [
                '💰 Salary: AED 25,000 - 35,000/month',
                '📋 Role: Define mobile architecture',
                '🎯 Goals: Mentor junior developers',
                '🏆 Achievements: Build scalable apps',
                '👥 Leadership: Guide mobile team',
              ],
              tip: '💡 Think about app architecture and scalability!',
            ),
            RoadmapStep(
              title: 'Mobile Team Lead / Principal Engineer (Years 8+)',
              description: 'Shape mobile strategy',
              details: [
                '💰 Salary: AED 35,000 - 50,000+/month',
                '📋 Role: Set mobile development standards',
                '🎯 Goals: Drive mobile innovation',
                '🏆 Achievements: Apps with millions of users',
                '👥 Leadership: Lead 5-15+ mobile developers',
              ],
              tip: '💡 Or create the next viral app - become an entrepreneur!',
            ),
          ],
        ),
      ],
    );
  }
}
