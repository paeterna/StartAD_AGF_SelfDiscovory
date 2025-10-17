import 'package:flutter/foundation.dart';

/// Enhanced career roadmap with detailed step-by-step guidance
@immutable
class EnhancedCareerRoadmap {
  final String careerTitle;
  final String description;
  final List<RoadmapPhase> phases;
  final String estimatedDuration;
  final String salaryRange;

  const EnhancedCareerRoadmap({
    required this.careerTitle,
    required this.description,
    required this.phases,
    required this.estimatedDuration,
    required this.salaryRange,
  });
}

/// A phase in the career roadmap (School, University, Skills, Career)
@immutable
class RoadmapPhase {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String duration;
  final List<RoadmapStep> steps;
  final PhaseType type;

  const RoadmapPhase({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.duration,
    required this.steps,
    required this.type,
  });
}

enum PhaseType {
  school,
  university,
  skills,
  career,
}

/// A step within a phase
@immutable
class RoadmapStep {
  final String title;
  final String description;
  final List<String> details;
  final List<String> resources;
  final String? tip;
  final bool isOptional;

  const RoadmapStep({
    required this.title,
    required this.description,
    required this.details,
    this.resources = const [],
    this.tip,
    this.isOptional = false,
  });
}

/// Sample roadmap data for different careers
class CareerRoadmapData {
  static EnhancedCareerRoadmap getSoftwareDeveloperRoadmap() {
    return EnhancedCareerRoadmap(
      careerTitle: 'Software Developer',
      description: 'Build amazing apps, websites, and systems that millions use daily',
      estimatedDuration: '7-10 years to senior level',
      salaryRange: 'AED 8,000 - 45,000/month',
      phases: [
        // PHASE 1: SCHOOL
        RoadmapPhase(
          id: 'school',
          title: 'High School (Grades 9-12)',
          subtitle: 'Build your foundation',
          icon: '🎓',
          duration: '4 years',
          type: PhaseType.school,
          steps: [
            RoadmapStep(
              title: 'Mathematics',
              description: 'Master the language of programming',
              details: [
                'Focus on Algebra and Calculus',
                'Learn problem-solving techniques',
                'Practice logical thinking',
                'Understand algorithms and patterns',
              ],
              resources: [
                'Khan Academy - Free math courses',
                'Brilliant.org - Interactive problem solving',
              ],
              tip: '💡 Math is everywhere in coding! Every algorithm you write uses math concepts.',
            ),
            RoadmapStep(
              title: 'Computer Science',
              description: 'Learn the basics of computing',
              details: [
                'Understand how computers work',
                'Learn basic programming concepts',
                'Study data structures',
                'Explore computer networks',
              ],
              resources: [
                'Code.org - Beginner programming',
                'Scratch - Visual programming',
              ],
              tip: '💡 Start coding early! Even simple projects teach you a lot.',
            ),
            RoadmapStep(
              title: 'Physics',
              description: 'Understand how things work',
              details: [
                'Learn about electricity and circuits',
                'Understand logic gates',
                'Study mechanics and systems',
              ],
              resources: [
                'PhET Simulations - Interactive physics',
              ],
              isOptional: true,
            ),
            RoadmapStep(
              title: 'English',
              description: 'Communication is key',
              details: [
                'Practice technical writing',
                'Learn to explain complex ideas simply',
                'Improve reading comprehension',
                'Build presentation skills',
              ],
              tip: '💡 Great developers are great communicators!',
            ),
          ],
        ),
        
        // PHASE 2: UNIVERSITY
        RoadmapPhase(
          id: 'university',
          title: 'University (Bachelor\'s Degree)',
          subtitle: 'Specialize and go deep',
          icon: '🎯',
          duration: '4 years',
          type: PhaseType.university,
          steps: [
            RoadmapStep(
              title: 'Computer Science Degree',
              description: 'Top UAE universities for CS',
              details: [
                '🏛️ Khalifa University - Top ranked',
                '🏛️ American University of Sharjah (AUS)',
                '🏛️ United Arab Emirates University (UAEU)',
                '🏛️ NYU Abu Dhabi - Highly selective',
                '🏛️ University of Dubai',
              ],
              resources: [
                'Admission requirements vary by university',
                'Most require 90%+ in high school',
                'Strong math and science grades essential',
              ],
              tip: '💡 Apply to multiple universities! Have backup options.',
            ),
            RoadmapStep(
              title: 'Core Courses to Excel In',
              description: 'Focus on these key subjects',
              details: [
                '📚 Data Structures & Algorithms - Foundation of coding',
                '📚 Object-Oriented Programming - How to structure code',
                '📚 Database Systems - How apps store data',
                '📚 Web Development - Build websites and apps',
                '📚 Software Engineering - Professional development',
                '📚 Operating Systems - How computers work',
                '📚 Computer Networks - How internet works',
              ],
              tip: '💡 Don\'t just pass - truly understand! These concepts last forever.',
            ),
            RoadmapStep(
              title: 'Internships',
              description: 'Get real-world experience',
              details: [
                'Apply for summer internships after Year 2',
                'Target: Tech companies in Dubai/Abu Dhabi',
                'Companies: Careem, Noon, Etisalat, du, Emirates NBD',
                'Build your portfolio with personal projects',
              ],
              resources: [
                'LinkedIn - Job search',
                'Bayt.com - UAE jobs',
                'GulfTalent - Professional roles',
              ],
              tip: '💡 Internships often lead to full-time jobs! Take them seriously.',
            ),
          ],
        ),
        
        // PHASE 3: SKILLS
        RoadmapPhase(
          id: 'skills',
          title: 'Skills & Certifications',
          subtitle: 'Stand out from the crowd',
          icon: '🛠️',
          duration: 'Ongoing',
          type: PhaseType.skills,
          steps: [
            RoadmapStep(
              title: 'Programming Languages',
              description: 'Master these essential languages',
              details: [
                '🐍 Python - Easiest to learn, very powerful',
                '☕ JavaScript - Essential for web development',
                '⚛️ React/Flutter - Modern app frameworks',
                '☕ Java - Enterprise applications',
                '📱 Swift/Kotlin - Mobile app development',
              ],
              resources: [
                'freeCodeCamp - Free coding bootcamp',
                'Udemy - Affordable courses',
                'Coursera - University-level courses',
              ],
              tip: '💡 Start with Python, then learn JavaScript. These two open many doors!',
            ),
            RoadmapStep(
              title: 'Professional Certifications',
              description: 'Boost your resume',
              details: [
                '🏅 AWS Certified Developer - Cloud computing',
                '🏅 Google Cloud Professional - Cloud platforms',
                '🏅 Microsoft Azure Fundamentals - Cloud services',
                '🏅 Meta Front-End Developer - Web development',
                '🏅 Oracle Java Certification - Java expertise',
              ],
              resources: [
                'Certifications cost AED 500-1,500',
                'Many have free training materials',
                'Employers value these highly',
              ],
              tip: '💡 Get AWS or Azure certified - cloud skills are in huge demand!',
            ),
            RoadmapStep(
              title: 'Soft Skills',
              description: 'The secret to career success',
              details: [
                '🤝 Teamwork - Work well with others',
                '💬 Communication - Explain technical concepts clearly',
                '⏰ Time Management - Meet deadlines',
                '🎯 Problem Solving - Think creatively',
                '📊 Presentation Skills - Present your work',
              ],
              tip: '💡 Technical skills get you hired, soft skills get you promoted!',
            ),
            RoadmapStep(
              title: 'Build Your Portfolio',
              description: 'Show, don\'t just tell',
              details: [
                '💻 Create 3-5 impressive projects',
                '🌐 Build a personal website',
                '📱 Develop a mobile app',
                '🎮 Create a game or tool',
                '📂 Host code on GitHub',
              ],
              resources: [
                'GitHub - Host your code',
                'Vercel/Netlify - Deploy websites free',
                'YouTube - Learn by watching tutorials',
              ],
              tip: '💡 Your portfolio is your proof! Make it impressive.',
            ),
          ],
        ),
        
        // PHASE 4: CAREER
        RoadmapPhase(
          id: 'career',
          title: 'Career Progression',
          subtitle: 'Climb the ladder',
          icon: '🚀',
          duration: '5-15+ years',
          type: PhaseType.career,
          steps: [
            RoadmapStep(
              title: 'Junior Developer (Years 0-2)',
              description: 'Your first job - learn everything!',
              details: [
                '💰 Salary: AED 8,000 - 15,000/month',
                '📋 Role: Write code, fix bugs, learn from seniors',
                '🎯 Goals: Master your tech stack, deliver quality code',
                '⏰ Typical hours: 9am-6pm, flexible in tech companies',
                '🏢 Companies: Startups, tech companies, banks',
              ],
              resources: [
                'Focus on learning, not just salary',
                'Ask questions - everyone expects this',
                'Find a good mentor',
              ],
              tip: '💡 Your first 2 years are for learning. Absorb everything like a sponge!',
            ),
            RoadmapStep(
              title: 'Mid-Level Developer (Years 2-5)',
              description: 'You\'re now experienced and trusted',
              details: [
                '💰 Salary: AED 15,000 - 25,000/month',
                '📋 Role: Lead small projects, mentor juniors, design systems',
                '🎯 Goals: Become an expert in your domain',
                '🏆 Achievements: Deliver major features independently',
                '📈 Growth: Start specializing (Frontend, Backend, Mobile, etc.)',
              ],
              tip: '💡 This is when you choose your specialization. Pick what you love!',
            ),
            RoadmapStep(
              title: 'Senior Developer (Years 5-8)',
              description: 'You\'re a technical leader',
              details: [
                '💰 Salary: AED 25,000 - 35,000/month',
                '📋 Role: Architect systems, lead teams, make technical decisions',
                '🎯 Goals: Influence product direction, mentor team',
                '🏆 Achievements: Design and build major systems',
                '👥 Leadership: Guide 3-5 developers',
              ],
              tip: '💡 Senior means you solve problems others can\'t. Keep learning!',
            ),
            RoadmapStep(
              title: 'Lead/Principal Developer (Years 8-12)',
              description: 'You\'re shaping the company\'s tech',
              details: [
                '💰 Salary: AED 35,000 - 45,000/month',
                '📋 Role: Define technical strategy, lead multiple teams',
                '🎯 Goals: Drive innovation, set technical standards',
                '🏆 Achievements: Build scalable systems used by millions',
                '👥 Leadership: Guide 10-20+ developers',
              ],
              tip: '💡 At this level, your decisions impact the entire company!',
            ),
            RoadmapStep(
              title: 'Engineering Manager / CTO (Years 12+)',
              description: 'You\'re leading the entire tech organization',
              details: [
                '💰 Salary: AED 45,000 - 100,000+/month',
                '📋 Role: Set company tech vision, hire and build teams',
                '🎯 Goals: Scale the organization, drive business growth',
                '🏆 Achievements: Build world-class engineering teams',
                '👥 Leadership: Manage managers, 50-500+ people',
              ],
              tip: '💡 The ultimate goal! But remember, you can also stay technical as a Principal Engineer.',
            ),
          ],
        ),
      ],
    );
  }

  static EnhancedCareerRoadmap getUXDesignerRoadmap() {
    return EnhancedCareerRoadmap(
      careerTitle: 'UX/UI Designer',
      description: 'Design beautiful, user-friendly experiences that people love',
      estimatedDuration: '6-9 years to senior level',
      salaryRange: 'AED 7,000 - 40,000/month',
      phases: [
        // PHASE 1: SCHOOL
        RoadmapPhase(
          id: 'school',
          title: 'High School (Grades 9-12)',
          subtitle: 'Discover your creative side',
          icon: '🎨',
          duration: '4 years',
          type: PhaseType.school,
          steps: [
            RoadmapStep(
              title: 'Art & Design',
              description: 'Build your creative foundation',
              details: [
                'Learn color theory and composition',
                'Practice drawing and sketching',
                'Understand visual hierarchy',
                'Study famous designs and art',
              ],
              resources: [
                'Behance - Design inspiration',
                'Dribbble - UI design showcase',
              ],
              tip: '💡 Keep a sketchbook! Draw every day, even simple things.',
            ),
            RoadmapStep(
              title: 'Computer Science (Basic)',
              description: 'Understand how technology works',
              details: [
                'Learn basic HTML/CSS',
                'Understand how websites work',
                'Basic programming concepts',
                'How apps are built',
              ],
              resources: [
                'Codecademy - Free HTML/CSS',
                'W3Schools - Web tutorials',
              ],
              tip: '💡 Designers who code are super valuable!',
            ),
            RoadmapStep(
              title: 'Psychology',
              description: 'Understand how people think',
              details: [
                'Study human behavior',
                'Learn about perception',
                'Understand decision-making',
                'Social psychology basics',
              ],
              tip: '💡 Great design is about understanding people!',
              isOptional: true,
            ),
            RoadmapStep(
              title: 'English & Communication',
              description: 'Express your ideas clearly',
              details: [
                'Practice presenting ideas',
                'Learn to write design briefs',
                'Develop storytelling skills',
                'Build persuasion skills',
              ],
              tip: '💡 Designers must explain WHY their designs work.',
            ),
          ],
        ),
        
        // PHASE 2: UNIVERSITY
        RoadmapPhase(
          id: 'university',
          title: 'University (Bachelor\'s Degree)',
          subtitle: 'Master the craft',
          icon: '🎯',
          duration: '4 years',
          type: PhaseType.university,
          steps: [
            RoadmapStep(
              title: 'Design Degree Options',
              description: 'Top UAE universities for design',
              details: [
                '🏛️ American University of Sharjah (AUS) - Graphic Design',
                '🏛️ Zayed University - Multimedia Design',
                '🏛️ Heriot-Watt University Dubai - Interactive Media',
                '🏛️ Middlesex University Dubai - Design',
                '🏛️ Dubai Institute of Design & Innovation (DIDI)',
              ],
              resources: [
                'Look for programs with UX/UI focus',
                'Check if they teach Figma, Adobe XD',
                'Internship opportunities matter!',
              ],
              tip: '💡 Portfolio matters more than grades in design!',
            ),
            RoadmapStep(
              title: 'Essential Design Courses',
              description: 'Master these subjects',
              details: [
                '🎨 User Interface Design - Visual design principles',
                '🎨 User Experience Design - How users interact',
                '🎨 Interaction Design - Animations and transitions',
                '🎨 Design Thinking - Problem-solving process',
                '🎨 Typography - The art of text',
                '🎨 Color Theory - Using colors effectively',
                '🎨 Prototyping - Making interactive mockups',
              ],
              tip: '💡 Practice every day! Design is a skill, not just talent.',
            ),
            RoadmapStep(
              title: 'Build Your Portfolio',
              description: 'Your portfolio IS your resume',
              details: [
                'Design 5-10 impressive projects',
                'Include: Mobile apps, websites, branding',
                'Show your process, not just final designs',
                'Get feedback from professionals',
                'Participate in design challenges',
              ],
              resources: [
                'Behance - Showcase your work',
                'Dribbble - Get discovered',
                'Daily UI Challenge - Practice daily',
              ],
              tip: '💡 Quality over quantity! 5 amazing projects beat 20 mediocre ones.',
            ),
            RoadmapStep(
              title: 'Internships & Freelance',
              description: 'Get real-world experience',
              details: [
                'Apply for design internships in Year 2-3',
                'Target: Startups, agencies, tech companies',
                'Companies: Careem, Noon, Fetchr, design agencies',
                'Try freelancing on Fiverr or Upwork',
              ],
              tip: '💡 Internships teach you what university can\'t!',
            ),
          ],
        ),
        
        // PHASE 3: SKILLS
        RoadmapPhase(
          id: 'skills',
          title: 'Skills & Tools',
          subtitle: 'Master the designer\'s toolkit',
          icon: '🛠️',
          duration: 'Ongoing',
          type: PhaseType.skills,
          steps: [
            RoadmapStep(
              title: 'Design Tools (Must Learn)',
              description: 'Industry-standard software',
              details: [
                '🎨 Figma - #1 UI design tool (FREE!)',
                '🎨 Adobe XD - UI/UX design',
                '🎨 Sketch - Mac-only design tool',
                '🎨 Adobe Photoshop - Image editing',
                '🎨 Adobe Illustrator - Vector graphics',
                '🎨 Framer - Advanced prototyping',
              ],
              resources: [
                'Figma is FREE - start here!',
                'YouTube tutorials for everything',
                'Udemy courses often on sale',
              ],
              tip: '💡 Learn Figma first - it\'s free and most companies use it!',
            ),
            RoadmapStep(
              title: 'Technical Skills',
              description: 'Stand out from other designers',
              details: [
                '💻 HTML/CSS - Basic front-end code',
                '💻 Responsive Design - Mobile-first thinking',
                '💻 Design Systems - Consistent components',
                '💻 Accessibility (a11y) - Design for everyone',
                '💻 Animation - Micro-interactions',
              ],
              tip: '💡 Designers who understand code are HIGHLY valued!',
            ),
            RoadmapStep(
              title: 'Professional Certifications',
              description: 'Boost your credibility',
              details: [
                '🏅 Google UX Design Certificate - Coursera',
                '🏅 Nielsen Norman Group UX Certification',
                '🏅 Interaction Design Foundation',
                '🏅 Adobe Certified Professional',
              ],
              resources: [
                'Google UX cert is beginner-friendly',
                'NN/g is the gold standard (expensive)',
                'IDF has affordable memberships',
              ],
              tip: '💡 Google UX Certificate is perfect for beginners!',
            ),
            RoadmapStep(
              title: 'Soft Skills',
              description: 'The secret to career success',
              details: [
                '🤝 Collaboration - Work with developers & PMs',
                '💬 Presentation - Sell your designs',
                '🎯 User Research - Talk to real users',
                '⏰ Time Management - Meet deadlines',
                '🧠 Empathy - Understand user needs',
              ],
              tip: '💡 Great designers are great listeners!',
            ),
          ],
        ),
        
        // PHASE 4: CAREER
        RoadmapPhase(
          id: 'career',
          title: 'Career Progression',
          subtitle: 'Grow your design career',
          icon: '🚀',
          duration: '5-12+ years',
          type: PhaseType.career,
          steps: [
            RoadmapStep(
              title: 'Junior UX/UI Designer (Years 0-2)',
              description: 'Start your design career',
              details: [
                '💰 Salary: AED 7,000 - 12,000/month',
                '📋 Role: Design screens, create mockups, assist seniors',
                '🎯 Goals: Build portfolio, learn from feedback',
                '⏰ Hours: 9am-6pm, flexible in startups',
                '🏢 Companies: Startups, agencies, tech companies',
              ],
              tip: '💡 Accept ALL feedback gracefully. It makes you better!',
            ),
            RoadmapStep(
              title: 'Mid-Level Designer (Years 2-5)',
              description: 'You\'re trusted to lead projects',
              details: [
                '💰 Salary: AED 12,000 - 20,000/month',
                '📋 Role: Own entire products, conduct user research',
                '🎯 Goals: Develop your unique design style',
                '🏆 Achievements: Ship products used by thousands',
                '📈 Growth: Specialize (Mobile, Web, Product, etc.)',
              ],
              tip: '💡 Start building your personal brand on Dribbble/Behance!',
            ),
            RoadmapStep(
              title: 'Senior Designer (Years 5-8)',
              description: 'You\'re a design leader',
              details: [
                '💰 Salary: AED 20,000 - 30,000/month',
                '📋 Role: Define design direction, mentor juniors',
                '🎯 Goals: Influence product strategy',
                '🏆 Achievements: Create design systems',
                '👥 Leadership: Guide 2-4 designers',
              ],
              tip: '💡 Senior means you make strategic decisions, not just pretty screens!',
            ),
            RoadmapStep(
              title: 'Lead Designer (Years 8-10)',
              description: 'You shape the design culture',
              details: [
                '💰 Salary: AED 30,000 - 40,000/month',
                '📋 Role: Lead design team, set standards',
                '🎯 Goals: Build world-class design team',
                '🏆 Achievements: Products win design awards',
                '👥 Leadership: Manage 5-10 designers',
              ],
              tip: '💡 At this level, you\'re hiring and building the team!',
            ),
            RoadmapStep(
              title: 'Design Director / Head of Design (Years 10+)',
              description: 'You\'re the design visionary',
              details: [
                '💰 Salary: AED 40,000 - 80,000+/month',
                '📋 Role: Define company design vision',
                '🎯 Goals: Make design a competitive advantage',
                '🏆 Achievements: Build award-winning products',
                '👥 Leadership: Lead 15-50+ designers',
              ],
              tip: '💡 The ultimate goal! Or become a freelance design consultant!',
            ),
          ],
        ),
      ],
    );
  }

  static EnhancedCareerRoadmap getRoadmapForCareer(String careerTitle) {
    // Map career titles to roadmap functions
    final roadmaps = {
      'Software Developer': getSoftwareDeveloperRoadmap(),
      'UX Designer': getUXDesignerRoadmap(),
      'UI Designer': getUXDesignerRoadmap(),
      'UX/UI Designer': getUXDesignerRoadmap(),
      // Add more mappings as needed
    };

    return roadmaps[careerTitle] ?? getSoftwareDeveloperRoadmap(); // Default fallback
  }

  // Add more career roadmaps here (Data Scientist, etc.)
}

