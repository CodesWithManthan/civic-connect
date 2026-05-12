import 'package:flutter/material.dart';
import 'package:civic_connect/core/auth/wrapper.dart';
import 'package:civic_connect/core/navigation/drawer_widget.dart';

/// ---------------------------------------------------------------------------
/// MY REPORTS PAGE
/// ---------------------------------------------------------------------------
/// Displays all issues reported by the current user.
/// Allows users to track status of their submissions.
///
/// FIREBASE IMPLEMENTATION PLAN:
/// 1. Get current user ID from Firebase Auth:
///    final userId = FirebaseAuth.instance.currentUser?.uid;
///
/// 2. Query Firestore for user's issues:
///    final snapshot = await FirebaseFirestore.instance
///      .collection('issues')
///      .where('reportedBy', isEqualTo: userId)
///      .orderBy('createdAt', descending: true)
///      .get();
///
/// 3. Use StreamBuilder for real-time updates:
///    StreamBuilder<QuerySnapshot>(
///      stream: FirebaseFirestore.instance
///        .collection('issues')
///        .where('reportedBy', isEqualTo: userId)
///        .orderBy('createdAt', descending: true)
///        .snapshots(),
///      builder: (context, snapshot) { ... }
///    )
///
/// 4. Add pull-to-refresh functionality
/// 5. Add filtering by status (All, Reported, In Progress, Resolved)
class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  /// Mock user ID (will be replaced with Firebase Auth user ID)
  final String currentUserId = 'user_123';

  /// Mock data - Issues reported by current user
  /// In production, this will be fetched from Firestore
  /// Filter: reportedBy == currentUserId
  final List<Map<String, dynamic>> myReports = [
    {
      'id': 'issue_001',
      'title': 'Large pothole near main road',
      'description': 'Deep pothole causing traffic jams during rush hour.',
      'category': 'Road',
      'status': 'In Progress',
      'imageUrls': [
        'https://blogs-images.forbes.com/dam/imageserve/5ad4bb72a7ea432fbc1f0853/0x0.png?cropX1=-1&cropY1=-1&cropX2=-1&cropY2=-1&quality=75&fit=&background=000000&uri=laurenfix/files/2018/04/Pothole-damage.png'
        ],
      'createdAt': '2026-01-20T10:30:00Z',
      'reportedBy': 'user_123',
      'upvotes': 42,
      'downvotes': 3,
    },
    {
      'id': 'issue_004',
      'title': 'Water pipeline leak wasting resources',
      'description': 'Major water leak from underground pipeline.',
      'category': 'Water',
      'status': 'Reported',
      'imageUrls': [
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT1Xl-h3tGP0beA0xlGRFEMfFTRm1mZ6AO9hg&s"
      ],
      'createdAt': '2026-01-19T16:45:00Z',
      'reportedBy': 'user_123',
      'upvotes': 67,
      'downvotes': 2,
    },
    {
      'id': 'issue_007',
      'title': 'Broken streetlight at intersection',
      'description': 'Streetlight not working for 2 weeks.',
      'category': 'Electricity',
      'status': 'Resolved',
      'imageUrls': [
        "https://www.kcmo.gov/home/showpublishedimage/5632/637498620644970000"
      ],
      'createdAt': '2026-01-15T09:20:00Z',
      'reportedBy': 'user_123',
      'upvotes': 15,
      'downvotes': 0,
    },
  ];

  /// Get color for status badge
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Reported':
        return Colors.blue;
      case 'In Progress':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Get icon for category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Road':
        return Icons.warning_amber_rounded;
      case 'Garbage':
        return Icons.delete_outline;
      case 'Water':
        return Icons.water_drop_outlined;
      case 'Electricity':
        return Icons.lightbulb_outline;
      case 'Drainage':
        return Icons.waves_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }

  /// Format date for display
  String _formatDate(String isoDate) {
    try {
      final DateTime date = DateTime.parse(isoDate);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

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
          'My Reports',
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ),
      ),

      /// -------------------- DRAWER --------------------
      drawer: const AppDrawer(currentRoute: 'my_reports'),

      /// -------------------- BODY --------------------
      body: myReports.isEmpty
          ? _buildEmptyState()
          : Column(
        children: [
          /// Stats summary bar
          _buildStatsSummary(),

          /// Reports list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // TODO: Implement refresh from Firebase
                await Future.delayed(const Duration(seconds: 1));
                setState(() {});
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: myReports.length,
                itemBuilder: (context, index) {
                  final report = myReports[index];
                  return _buildReportCard(report);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// -------------------- STATS SUMMARY --------------------
  /// Shows quick overview of user's reports
  Widget _buildStatsSummary() {
    // Calculate stats
    final int total = myReports.length;
    final int reported =
        myReports.where((r) => r['status'] == 'Reported').length;
    final int inProgress =
        myReports.where((r) => r['status'] == 'In Progress').length;
    final int resolved =
        myReports.where((r) => r['status'] == 'Resolved').length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', total, Colors.blue[700]!),
          _buildStatItem('Pending', reported, Colors.blue[600]!),
          _buildStatItem('In Progress', inProgress, Colors.orange[600]!),
          _buildStatItem('Resolved', resolved, Colors.green[600]!),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// -------------------- REPORT CARD --------------------
  /// Individual card for each report
  Widget _buildReportCard(Map<String, dynamic> report) {
    final Color statusColor = _getStatusColor(report['status']);
    final IconData categoryIcon = _getCategoryIcon(report['category']);
    final String formattedDate = _formatDate(report['createdAt']);

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to issue detail page
        // Pass the issue ID to fetch full details from Firebase
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening details for: ${report['title']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE THUMBNAIL
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: report['imageUrls'] != null &&
                  (report['imageUrls'] as List).isNotEmpty
                  ? Image.network(
                report['imageUrls'][0],
                width: 100,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 120,
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image,
                        size: 32, color: Colors.grey[400]),
                  );
                },
              )
                  : Container(
                width: 100,
                height: 120,
                color: Colors.grey[200],
                child: Icon(Icons.image_not_supported,
                    size: 32, color: Colors.grey[400]),
              ),
            ),

            /// CONTENT
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// STATUS BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        report['status'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// TITLE
                    Text(
                      report['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    /// CATEGORY
                    Row(
                      children: [
                        Icon(categoryIcon, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          report['category'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// DATE
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// VOTES
                    Row(
                      children: [
                        Icon(Icons.arrow_upward,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 2),
                        Text(
                          '${report['upvotes']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.arrow_downward,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 2),
                        Text(
                          '${report['downvotes']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            /// ARROW INDICATOR
            Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// -------------------- EMPTY STATE --------------------
  /// Shown when user has no reports yet
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 64,
                color: Colors.blue[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Reports Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t reported any issues yet.\nStart making a difference in your community!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate back to home where user can report
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Report an Issue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}