import 'package:flutter/foundation.dart';
import 'enhanced_career_roadmap.dart';

/// Digital Marketing career roadmap
class DigitalMarketerRoadmap {
  static EnhancedCareerRoadmap getRoadmap() {
    return EnhancedCareerRoadmap(
      careerTitle: 'Digital Marketer',
      description: 'Promote products and brands online through social media, ads, and content',
      estimatedDuration: '5-8 years to senior level',
      salaryRange: 'AED 6,000 - 35,000/month',
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
              title: 'Business & Communication',
              description: 'Build foundation',
              details: [
                'Focus on English and Arabic',
                'Study business basics',
                'Learn psychology (consumer behavior)',
                'Practice writing and presenting',
              ],
              resources: [
                'HubSpot Academy - Free marketing',
                'Google Digital Garage',
                'Coursera - Marketing basics',
              ],
              tip: '💡 Start your own Instagram or TikTok to learn marketing!',
            ),
            RoadmapStep(
              title: 'Creative Skills',
              description: 'Develop creativity',
              details: [
                'Learn basic graphic design',
                'Practice content writing',
                'Study successful campaigns',
                'Create social media content',
              ],
              resources: [
                'Canva - Free design tool',
                'Grammarly - Writing assistant',
                'Social media platforms',
              ],
              tip: '💡 Marketing is part art, part science!',
            ),
          ],
        ),
        
        // PHASE 2: UNIVERSITY
        RoadmapPhase(
          id: 'university',
          title: 'University (Bachelor\'s Degree)',
          subtitle: 'Business/Marketing Degree',
          icon: '🎯',
          duration: '4 years',
          type: PhaseType.university,
          steps: [
            RoadmapStep(
              title: 'Marketing Degree',
              description: 'Study at UAE universities',
              details: [
                '🏛️ AUS - Marketing program',
                '🏛️ Zayed University - Business',
                '🏛️ UAEU - Marketing',
                '🏛️ Canadian University Dubai - Marketing',
              ],
              resources: [
                'AUS Business School',
                'Zayed University Marketing',
                'UAEU Business',
              ],
              tip: '💡 Internships are crucial - work at agencies during summer!',
            ),
            RoadmapStep(
              title: 'Essential Marketing Courses',
              description: 'Core subjects to master',
              details: [
                '📚 Digital Marketing - Online strategies',
                '📚 Consumer Behavior - Psychology of buying',
                '📚 Brand Management - Building brands',
                '📚 Marketing Analytics - Measure success',
                '📚 Social Media Marketing - Platform strategies',
                '📚 Content Marketing - Storytelling',
              ],
              tip: '💡 Focus on digital marketing - it\'s the future!',
            ),
            RoadmapStep(
              title: 'Build Your Portfolio',
              description: 'Create marketing campaigns',
              details: [
                'Run campaigns for local businesses',
                'Create content calendars',
                'Manage social media accounts',
                'Design marketing materials',
                'Track and analyze results',
              ],
              resources: [
                'Google Analytics - Free',
                'Facebook Business Manager',
                'LinkedIn for business',
              ],
              tip: '💡 Real campaigns > theoretical knowledge!',
            ),
          ],
        ),
        
        // PHASE 3: SKILLS
        RoadmapPhase(
          id: 'skills',
          title: 'Skills & Certifications',
          subtitle: 'Master digital tools',
          icon: '🛠️',
          duration: 'Ongoing',
          type: PhaseType.skills,
          steps: [
            RoadmapStep(
              title: 'Digital Marketing Tools',
              description: 'Learn the platforms',
              details: [
                '📱 Google Ads - Paid advertising',
                '📘 Facebook/Instagram Ads',
                '🔍 SEO - Search optimization',
                '📧 Email marketing - Mailchimp',
                '📊 Analytics - Google Analytics',
              ],
              resources: [
                'Google Skillshop - Free certs',
                'HubSpot Academy - Free',
                'Meta Blueprint - Facebook ads',
              ],
              tip: '💡 Get Google Ads and Analytics certifications - they\'re free!',
            ),
            RoadmapStep(
              title: 'Content Creation Skills',
              description: 'Create engaging content',
              details: [
                'Copywriting - Persuasive writing',
                'Graphic Design - Visual content',
                'Video Editing - Video content',
                'Photography - Product and lifestyle',
                'Data Analysis - Measure performance',
              ],
              resources: [
                'Canva - Design tools',
                'Adobe Creative Suite',
                'CapCut - Video editing',
              ],
              tip: '💡 Content is king - learn to create it well!',
            ),
            RoadmapStep(
              title: 'Marketing Certifications',
              description: 'Professional credentials',
              details: [
                '🏅 Google Ads Certified',
                '🏅 Google Analytics Certified',
                '🏅 HubSpot Content Marketing',
                '🏅 Facebook Blueprint Certified',
                '🏅 Hootsuite Social Media',
              ],
              resources: [
                'Most certifications are free',
                'Take practice tests first',
                'Renew annually',
              ],
              tip: '💡 Certifications prove your expertise to employers!',
            ),
          ],
        ),
        
        // PHASE 4: CAREER
        RoadmapPhase(
          id: 'career',
          title: 'Career Progression',
          subtitle: 'Marketing career path',
          icon: '🚀',
          duration: '8-12+ years',
          type: PhaseType.career,
          steps: [
            RoadmapStep(
              title: 'Junior Marketer (Years 0-2)',
              description: 'Start your journey',
              details: [
                '💰 Salary: AED 6,000 - 10,000/month',
                '📋 Role: Manage social media accounts',
                '🎯 Goals: Run ad campaigns',
                '📊 Tasks: Analyze performance metrics',
                '🏢 Companies: Noon, Careem, Talabat',
              ],
              resources: [
                'LinkedIn - Network',
                'Bayt.com - Jobs',
              ],
              tip: '💡 Track everything - data proves your value!',
            ),
            RoadmapStep(
              title: 'Digital Marketing Specialist (Years 2-4)',
              description: 'Develop expertise',
              details: [
                '💰 Salary: AED 10,000 - 16,000/month',
                '📋 Role: Lead specific channels (SEO, PPC, Social)',
                '🎯 Goals: Optimize campaign performance',
                '🏆 Achievements: Increase ROI significantly',
                '📈 Growth: Specialize in preferred channels',
              ],
              tip: '💡 Become the go-to expert in one marketing channel!',
            ),
            RoadmapStep(
              title: 'Senior Marketing Manager (Years 4-7)',
              description: 'Lead marketing initiatives',
              details: [
                '💰 Salary: AED 16,000 - 25,000/month',
                '📋 Role: Develop marketing strategies',
                '🎯 Goals: Lead marketing team',
                '🏆 Achievements: Drive significant growth',
                '👥 Leadership: Manage 3-8 marketers',
              ],
              tip: '💡 Focus on strategy and team leadership!',
            ),
            RoadmapStep(
              title: 'Marketing Director / Head of Marketing (Years 7+)',
              description: 'Shape marketing vision',
              details: [
                '💰 Salary: AED 25,000 - 35,000+/month',
                '📋 Role: Define marketing strategy',
                '🎯 Goals: Drive company growth',
                '🏆 Achievements: Build marketing organization',
                '👥 Leadership: Lead 10-25+ marketers',
              ],
              tip: '💡 You\'re now a business leader driving revenue!',
            ),
          ],
        ),
      ],
    );
  }
}
