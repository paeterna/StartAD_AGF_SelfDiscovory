import 'enhanced_career_roadmap.dart';

/// Game Developer career roadmap
class GameDeveloperRoadmap {
  static EnhancedCareerRoadmap getRoadmap() {
    return EnhancedCareerRoadmap(
      careerTitle: 'Game Developer',
      description: 'Design and build video games for mobile, PC, and consoles',
      estimatedDuration: '8-12 years to senior level',
      salaryRange: 'AED 8,000 - 45,000/month',
      phases: [
        // PHASE 1: SCHOOL
        RoadmapPhase(
          id: 'school',
          title: 'High School (Grades 9-12)',
          subtitle: 'Build foundation',
          icon: '🎓',
          duration: '4 years',
          type: PhaseType.school,
          steps: [
            RoadmapStep(
              title: 'Math & Programming',
              description: 'Build foundation',
              details: [
                'Master math and physics',
                'Learn programming (C#, C++)',
                'Study game design principles',
                'Build simple games',
              ],
              resources: [
                'Unity Learn - Free tutorials',
                'Unreal Engine docs',
                'Scratch - Start simple',
              ],
              tip: '💡 Make games while learning - it\'s the best way!',
            ),
            RoadmapStep(
              title: 'Game Design Basics',
              description: 'Understand what makes games fun',
              details: [
                'Study your favorite games',
                'Learn game mechanics',
                'Understand player psychology',
                'Create game concepts',
              ],
              resources: [
                'Game Design Document templates',
                'Extra Credits - YouTube channel',
                'Board games for inspiration',
              ],
              tip: '💡 Great games are built on great design, not just code!',
            ),
          ],
        ),
        
        // PHASE 2: UNIVERSITY
        RoadmapPhase(
          id: 'university',
          title: 'University (Bachelor\'s Degree)',
          subtitle: 'CS/Game Dev Degree',
          icon: '🎯',
          duration: '4 years',
          type: PhaseType.university,
          steps: [
            RoadmapStep(
              title: 'Game Development Degree',
              description: 'Specialized education',
              details: [
                '🏛️ SAE Dubai - Game Development',
                '🏛️ AUS - Computer Science',
                '🏛️ UAEU - CS with game focus',
                '🏛️ Or self-taught with portfolio',
              ],
              resources: [
                'SAE Dubai Games',
                'AUS CS',
                'Self-taught path',
              ],
              tip: '💡 Portfolio of games > degree in game industry!',
            ),
            RoadmapStep(
              title: 'Core Game Development',
              description: 'Essential game dev skills',
              details: [
                '🎮 Game Programming - Core gameplay',
                '🎮 3D Graphics - Rendering and shaders',
                '🎮 Game Physics - Realistic movement',
                '🎮 AI Programming - Smart NPCs',
                '🎮 UI/UX Design - Player interfaces',
                '🎮 Audio Integration - Sound and music',
              ],
              tip: '💡 Focus on one area first, then branch out!',
            ),
            RoadmapStep(
              title: 'Build Your Portfolio',
              description: 'Create impressive games',
              details: [
                'Complete 3-5 polished games',
                'Show different genres and skills',
                'Document your development process',
                'Publish games online',
                'Get feedback from players',
              ],
              resources: [
                'itch.io - Publish indie games',
                'Steam - PC game platform',
                'Google Play - Mobile games',
              ],
              tip: '💡 Finished games are better than perfect prototypes!',
            ),
          ],
        ),
        
        // PHASE 3: SKILLS
        RoadmapPhase(
          id: 'skills',
          title: 'Skills & Certifications',
          subtitle: 'Master game engines',
          icon: '🛠️',
          duration: 'Ongoing',
          type: PhaseType.skills,
          steps: [
            RoadmapStep(
              title: 'Game Engines & Tools',
              description: 'Learn the tools',
              details: [
                '🎯 Unity - Most popular (C#)',
                '🎯 Unreal Engine - AAA games (C++)',
                '🎯 Blender - 3D modeling (free)',
                '🎯 Git - Version control',
              ],
              resources: [
                'Unity Learn - Free',
                'Unreal Online Learning',
                'Blender tutorials',
              ],
              tip: '💡 Start with Unity - easier to learn, huge community!',
            ),
            RoadmapStep(
              title: 'Specialized Skills',
              description: 'Choose your focus',
              details: [
                'Gameplay Programming - Core mechanics',
                'Graphics Programming - Shaders and effects',
                'Engine Programming - Low-level systems',
                'Mobile Game Development - iOS/Android',
                'VR/AR Development - Immersive experiences',
              ],
              tip: '💡 Specialize in one area to stand out!',
            ),
            RoadmapStep(
              title: 'Game Development Certifications',
              description: 'Validate your skills',
              details: [
                '🏅 Unity Certified Programmer',
                '🏅 Unity Certified Artist',
                '🏅 Unreal Engine Certifications',
                '🏅 Platform-specific certs (iOS, Android)',
              ],
              resources: [
                'Unity Certifications',
                'Unreal Engine Learning',
                'Apple Developer Program',
              ],
              tip: '💡 Certifications help but portfolio is king!',
            ),
          ],
        ),
        
        // PHASE 4: CAREER
        RoadmapPhase(
          id: 'career',
          title: 'Career Progression',
          subtitle: 'Game dev career',
          icon: '🚀',
          duration: '10-15+ years',
          type: PhaseType.career,
          steps: [
            RoadmapStep(
              title: 'Junior Game Developer (Years 0-2)',
              description: 'Start making games',
              details: [
                '💰 Salary: AED 8,000 - 14,000/month',
                '📋 Role: Implement game features',
                '🎯 Goals: Fix bugs and optimize',
                '📊 Tasks: Work with designers and artists',
                '🏢 Companies: Ubisoft Abu Dhabi, local studios',
              ],
              resources: [
                'Ubisoft Abu Dhabi',
                'Falafel Games',
                'Indie studios',
              ],
              tip: '💡 Ubisoft has a studio in Abu Dhabi - great opportunity!',
            ),
            RoadmapStep(
              title: 'Game Developer (Years 2-5)',
              description: 'Build expertise',
              details: [
                '💰 Salary: AED 14,000 - 22,000/month',
                '📋 Role: Own game systems',
                '🎯 Goals: Lead feature development',
                '🏆 Achievements: Ship successful games',
                '📈 Growth: Specialize in preferred area',
              ],
              tip: '💡 Great games take time - be patient and persistent!',
            ),
            RoadmapStep(
              title: 'Senior Game Developer (Years 5-8)',
              description: 'Lead game development',
              details: [
                '💰 Salary: AED 22,000 - 32,000/month',
                '📋 Role: Architect game systems',
                '🎯 Goals: Mentor junior developers',
                '🏆 Achievements: Create innovative gameplay',
                '👥 Leadership: Guide development team',
              ],
              tip: '💡 Focus on creating memorable player experiences!',
            ),
            RoadmapStep(
              title: 'Lead Developer / Game Director (Years 8+)',
              description: 'Shape game vision',
              details: [
                '💰 Salary: AED 32,000 - 45,000+/month',
                '📋 Role: Define game vision',
                '🎯 Goals: Lead entire game projects',
                '🏆 Achievements: Create award-winning games',
                '👥 Leadership: Manage 10-30+ developers',
              ],
              tip: '💡 Or start your own indie studio - be your own boss!',
            ),
          ],
        ),
      ],
    );
  }
}
