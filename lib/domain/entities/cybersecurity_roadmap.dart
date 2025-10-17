import 'package:flutter/foundation.dart';
import 'enhanced_career_roadmap.dart';

/// Cybersecurity Specialist career roadmap
class CybersecurityRoadmap {
  static EnhancedCareerRoadmap getRoadmap() {
    return EnhancedCareerRoadmap(
      careerTitle: 'Cybersecurity Specialist',
      description: 'Protect systems, networks, and data from cyber threats',
      estimatedDuration: '8-12 years to senior level',
      salaryRange: 'AED 12,000 - 70,000/month',
      phases: [
        // PHASE 1: SCHOOL
        RoadmapPhase(
          id: 'school',
          title: 'High School (Grades 9-12)',
          subtitle: 'Build technical foundation',
          icon: '🎓',
          duration: '4 years',
          type: PhaseType.school,
          steps: [
            RoadmapStep(
              title: 'Computer Science & Math',
              description: 'Build technical foundation',
              details: [
                'Master computer science basics',
                'Learn networking fundamentals',
                'Understand cryptography basics',
                'Study ethical hacking concepts',
              ],
              resources: [
                'TryHackMe - Free cybersecurity',
                'HackTheBox - Practice labs',
                'Cybrary - Free courses',
              ],
              tip: '💡 Cybersecurity is one of the highest-paid tech careers in UAE!',
            ),
            RoadmapStep(
              title: 'Programming & Networking',
              description: 'Learn technical skills early',
              details: [
                'Learn Python for security scripts',
                'Understand network protocols',
                'Practice Linux command line',
                'Study how hackers work',
              ],
              resources: [
                'Linux Academy - Command line',
                'Python for Cybersecurity',
                'Wireshark tutorials',
              ],
              tip: '💡 Understand both attack and defense!',
            ),
          ],
        ),
        
        // PHASE 2: UNIVERSITY
        RoadmapPhase(
          id: 'university',
          title: 'University (Bachelor\'s Degree)',
          subtitle: 'CS/Cybersecurity Degree',
          icon: '🎯',
          duration: '4 years',
          type: PhaseType.university,
          steps: [
            RoadmapStep(
              title: 'Cybersecurity Degree',
              description: 'Specialized education',
              details: [
                '🏛️ Khalifa University - Cybersecurity program',
                '🏛️ UAEU - Information Security',
                '🏛️ AUS - CS with security focus',
                '🏛️ RIT Dubai - Cybersecurity',
              ],
              resources: [
                'Khalifa Cybersecurity',
                'UAEU Security',
                'RIT Dubai',
              ],
              tip: '💡 UAE government heavily invests in cybersecurity - great opportunities!',
            ),
            RoadmapStep(
              title: 'Core Security Courses',
              description: 'Essential cybersecurity subjects',
              details: [
                '🔒 Network Security - Protect networks',
                '🔒 Cryptography - Secure communications',
                '🔒 Ethical Hacking - Penetration testing',
                '🔒 Digital Forensics - Investigate breaches',
                '🔒 Risk Management - Assess threats',
                '🔒 Incident Response - Handle attacks',
              ],
              tip: '💡 Hands-on labs are crucial - practice in safe environments!',
            ),
            RoadmapStep(
              title: 'Practical Experience',
              description: 'Build security skills',
              details: [
                'Set up home lab environment',
                'Practice on vulnerable VMs',
                'Participate in CTF competitions',
                'Intern at security companies',
                'Build security tools/scripts',
              ],
              resources: [
                'VirtualBox - Free virtualization',
                'Kali Linux - Security OS',
                'DVWA - Practice hacking',
              ],
              tip: '💡 Practice ethical hacking legally and safely!',
            ),
          ],
        ),
        
        // PHASE 3: SKILLS
        RoadmapPhase(
          id: 'skills',
          title: 'Skills & Certifications',
          subtitle: 'Get certified',
          icon: '🛠️',
          duration: 'Ongoing',
          type: PhaseType.skills,
          steps: [
            RoadmapStep(
              title: 'Security Certifications',
              description: 'Industry certifications',
              details: [
                '🏅 CompTIA Security+ (AED 1,500)',
                '🏅 CEH - Certified Ethical Hacker (AED 3,000)',
                '🏅 CISSP - Advanced (AED 2,500)',
                '🏅 Cloud security - AWS/Azure',
              ],
              resources: [
                'CompTIA - Entry level',
                'EC-Council - CEH',
                'ISC2 - CISSP',
              ],
              tip: '💡 Certifications are crucial in cybersecurity!',
            ),
            RoadmapStep(
              title: 'Technical Skills',
              description: 'Master security tools',
              details: [
                'Penetration Testing - Find vulnerabilities',
                'Network Monitoring - Detect attacks',
                'Incident Response - Handle breaches',
                'Security Architecture - Design secure systems',
                'Compliance - Meet regulations',
              ],
              resources: [
                'Metasploit - Penetration testing',
                'Nmap - Network scanning',
                'Splunk - Log analysis',
              ],
              tip: '💡 Stay updated - new threats emerge daily!',
            ),
            RoadmapStep(
              title: 'Specialized Areas',
              description: 'Choose your specialty',
              details: [
                'Cloud Security - AWS, Azure, GCP',
                'Mobile Security - App security',
                'IoT Security - Device security',
                'AI Security - ML model protection',
                'Blockchain Security - Crypto security',
              ],
              tip: '💡 Specialize in emerging areas for better opportunities!',
            ),
          ],
        ),
        
        // PHASE 4: CAREER
        RoadmapPhase(
          id: 'career',
          title: 'Career Progression',
          subtitle: 'Security career',
          icon: '🚀',
          duration: '10-15+ years',
          type: PhaseType.career,
          steps: [
            RoadmapStep(
              title: 'Junior Security Analyst (Years 0-2)',
              description: 'Start protecting',
              details: [
                '💰 Salary: AED 12,000 - 20,000/month',
                '📋 Role: Monitor security systems',
                '🎯 Goals: Respond to incidents',
                '📊 Tasks: Conduct vulnerability scans',
                '🏢 Companies: Banks, government, Etisalat',
              ],
              resources: [
                'LinkedIn - Network',
                'ISACA UAE chapter',
              ],
              tip: '💡 Government and banks pay top salaries for security!',
            ),
            RoadmapStep(
              title: 'Security Specialist (Years 2-5)',
              description: 'Develop expertise',
              details: [
                '💰 Salary: AED 20,000 - 35,000/month',
                '📋 Role: Lead security projects',
                '🎯 Goals: Design security solutions',
                '🏆 Achievements: Prevent major breaches',
                '📈 Growth: Specialize in specific areas',
              ],
              tip: '💡 Become the expert in one security domain!',
            ),
            RoadmapStep(
              title: 'Senior Security Engineer (Years 5-8)',
              description: 'Lead security initiatives',
              details: [
                '💰 Salary: AED 35,000 - 50,000/month',
                '📋 Role: Architect security systems',
                '🎯 Goals: Set security standards',
                '🏆 Achievements: Build security team',
                '👥 Leadership: Guide junior analysts',
              ],
              tip: '💡 Think strategically about organizational security!',
            ),
            RoadmapStep(
              title: 'CISO / Security Director (Years 8+)',
              description: 'Lead security organization',
              details: [
                '💰 Salary: AED 50,000 - 70,000+/month',
                '📋 Role: Define security strategy',
                '🎯 Goals: Protect entire organization',
                '🏆 Achievements: Zero major breaches',
                '👥 Leadership: Manage 10-50+ security professionals',
              ],
              tip: '💡 You\'re now a business executive who specializes in security!',
            ),
          ],
        ),
      ],
    );
  }
}
