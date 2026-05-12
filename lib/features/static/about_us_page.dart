import 'package:flutter/material.dart';
import 'package:civic_connect/core/navigation/drawer_widget.dart';

/// ---------------------------------------------------------------------------
/// ABOUT & TRANSPARENCY PAGE
/// ---------------------------------------------------------------------------
/// Educational page explaining:
/// - Why this app exists
/// - What's broken in traditional complaint systems
/// - How transparency improves accountability
/// - The role of citizens vs government
///
/// DESIGN PRINCIPLES:
/// - Neutral, factual tone
/// - Not anti-government, pro-transparency
/// - Clear, accessible language
/// - Structured sections with icons
/// - Emphasis on public visibility as a core feature
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// -------------------- APP BAR --------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'About & Transparency',
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ),
      ),

      /// -------------------- DRAWER --------------------
      drawer: const AppDrawer(currentRoute: 'about'),

      /// -------------------- BODY --------------------
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER SECTION
            _buildHeaderSection(context),

            /// CONTENT SECTIONS
            _buildSection(
              icon: Icons.lightbulb_outline,
              iconColor: Colors.orange,
              title: 'Why This App Exists',
              content:
              'Traditional complaint systems often operate in silos. Citizens report issues, but they rarely know:\n\n'
                  '• Whether their complaint was received\n'
                  '• If it\'s being worked on\n'
                  '• When it will be resolved\n'
                  '• If others face the same problem\n\n'
                  'This app changes that by making civic issues publicly visible, creating a transparent record that benefits everyone.',
            ),

            _buildDivider(),

            _buildSection(
              icon: Icons.warning_amber_outlined,
              iconColor: Colors.red,
              title: 'What\'s Broken in Current Systems',
              content:
              'Most civic complaint platforms have fundamental limitations:\n\n'
                  '• No public visibility: Issues are hidden from community view\n'
                  '• No tracking: Citizens can\'t monitor progress\n'
                  '• Duplicate efforts: Multiple people report the same issue\n'
                  '• No accountability: Delays go unnoticed\n'
                  '• Limited engagement: Community can\'t participate or support\n\n'
                  'These gaps reduce effectiveness and erode trust in the system.',
            ),

            _buildDivider(),

            _buildSection(
              icon: Icons.visibility_outlined,
              iconColor: Colors.blue,
              title: 'How Transparency Changes Everything',
              content:
              'When civic issues are publicly visible, several things happen:\n\n'
                  '• Community awareness: Everyone can see what\'s happening\n'
                  '• Collaborative validation: Citizens can upvote urgent issues\n'
                  '• Data-driven decisions: Authorities can prioritize based on impact\n'
                  '• Natural accountability: Public visibility encourages action\n'
                  '• Reduced duplication: One report serves many people\n\n'
                  'Transparency isn\'t about blame—it\'s about creating a shared understanding of what needs attention.',
            ),

            _buildDivider(),

            _buildSection(
              icon: Icons.handshake_outlined,
              iconColor: Colors.green,
              title: 'Our Role vs Government Role',
              content:
              'This app is not a replacement for government services. It\'s a complementary tool:\n\n'
                  '📱 Citizens:\n'
                  '• Report issues with photos and location\n'
                  '• Track status of their reports\n'
                  '• Support community issues by voting\n'
                  '• Contribute to a public record\n\n'
                  '🏛️ Authorities:\n'
                  '• Receive organized, verified reports\n'
                  '• Prioritize based on community input\n'
                  '• Update status publicly\n'
                  '• Build trust through visible action\n\n'
                  'We facilitate communication and transparency. Action still comes from responsible authorities.',
            ),

            _buildDivider(),

            _buildSection(
              icon: Icons.gavel_outlined,
              iconColor: Colors.purple,
              title: 'Data & Privacy',
              content:
              'Issue reports are public by design, but we protect privacy:\n\n'
                  '• Public: Issue details, location, photos, status\n'
                  '• Private: Reporter identity (unless you choose to share)\n'
                  '• No selling of data: Your information stays within this platform\n'
                  '• Community-first: Data serves public interest, not profit\n\n'
                  'Transparency in civic issues, privacy for individuals.',
            ),

            _buildDivider(),

            _buildSection(
              icon: Icons.location_city_outlined,
              iconColor: Colors.teal,
              title: 'Starting with Vadodara',
              content:
              'Every movement starts somewhere. We chose Vadodara because:\n\n'
                  '• Manageable scope: A single city allows us to prove the model\n'
                  '• Engaged community: Citizens here care about civic issues\n'
                  '• Scalable learning: What works here can work elsewhere\n\n'
                  'If this succeeds, we\'ll expand to other cities—bringing transparency to civic management everywhere.',
            ),

            _buildDivider(),

            /// FOOTER SECTION
            _buildFooterSection(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// -------------------- HEADER SECTION --------------------
  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[700]!,
            Colors.blue[500]!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.track_changes,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Transparency in Civic Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Making civic issues visible, trackable, and actionable',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.95),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// -------------------- CONTENT SECTION BUILDER --------------------
  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Section content
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// -------------------- DIVIDER --------------------
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        color: Colors.grey[200],
        thickness: 1,
      ),
    );
  }

  /// -------------------- FOOTER SECTION --------------------
  Widget _buildFooterSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Built for the Community',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This is an MVP (Minimum Viable Product) built as part of an effort to reimagine civic engagement. We\'re starting small, learning fast, and improving continuously.\n\n'
                'Your feedback matters. Your reports matter. Together, we can build a more transparent and responsive system.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue[900],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.code, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'Made with Flutter • Version 1.0.0',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}