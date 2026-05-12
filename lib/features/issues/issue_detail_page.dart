import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:civic_connect/features/issues/models/issue_model.dart';

/// ---------------------------------------------------------------------------
/// LIVE ISSUE DETAIL PAGE
/// ---------------------------------------------------------------------------
/// Displays real-time information about a single civic issue.
/// Connected directly to Firestore for instant voting updates.
class IssueDetailPage extends StatefulWidget {
  final Map<String, dynamic> issue;
  final Function(bool) onVote;

  const IssueDetailPage({
    super.key,
    required this.issue,
    required this.onVote,
  });

  @override
  State<IssueDetailPage> createState() => _IssueDetailPageState();
}

class _IssueDetailPageState extends State<IssueDetailPage> {
  /// Helper to get status colors based on Firestore status string
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

  /// Error widget for missing or broken images
  Widget _imageErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Document ID needed to listen for live updates
    final String issueId = widget.issue['id'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        title: const Text('Issue Details', style: TextStyle(fontSize: 18)),
      ),

      /// STREAMBUILDER: Listens to this specific document for real-time changes
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('issues').doc(issueId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Issue data not found."));
          }

          // Convert the snapshot to our defensive Model
          final issue = IssueModel.fromFirestore(snapshot.data!);
          final Color statusColor = _getStatusColor(issue.status);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// -------------------- IMAGE CAROUSEL --------------------
                if (issue.imageUrls.isNotEmpty)
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      itemCount: issue.imageUrls.length,
                      itemBuilder: (context, index) {
                        final String path = issue.imageUrls[index];
                        return path.startsWith('http')
                            ? Image.network(
                          path,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _imageErrorWidget(),
                        )
                            : Image.file(File(path), fit: BoxFit.cover);
                      },
                    ),
                  )
                else
                  _imageErrorWidget(),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// STATUS BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          issue.status,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: statusColor),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// TITLE
                      Text(
                        issue.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),

                      const SizedBox(height: 12),

                      /// ICON INFO ROWS
                      _buildIconInfo(Icons.category_outlined, 'Category: ${issue.category}'),
                      const SizedBox(height: 8),
                      _buildIconInfo(Icons.location_on_outlined, issue.address),
                      const SizedBox(height: 8),
                      _buildIconInfo(Icons.access_time, 'Reported on ${issue.createdAt.toString().substring(0, 10)}'),

                      const SizedBox(height: 24),

                      /// DESCRIPTION
                      const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(
                        issue.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
                      ),

                      const SizedBox(height: 24),

                      /// VOTES DISPLAY (Now updates instantly)
                      Row(
                        children: [
                          _buildVoteBox('Upvotes', issue.upvotes, Colors.green),
                          const SizedBox(width: 16),
                          _buildVoteBox('Downvotes', issue.downvotes, Colors.red),
                        ],
                      ),

                      const SizedBox(height: 32),

                      /// TIMELINE SECTION
                      const Text('Timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      _buildTimelineItem('Issue Reported', 'Citizen reported this issue', issue.createdAt.toString().substring(0, 10), Colors.blue, isFirst: true),
                      if (issue.status != 'Reported')
                        _buildTimelineItem('Under Review', 'Authorities acknowledged the issue', 'In Progress', Colors.orange),
                      if (issue.status == 'Resolved')
                        _buildTimelineItem('Resolved', 'Issue successfully resolved', 'Completed', Colors.green, isLast: true),
                      if (issue.status != 'Resolved')
                        _buildTimelineItem('Awaiting Resolution', 'Authorities are working on this', 'Pending', Colors.grey, isLast: true),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

      /// -------------------- BOTTOM ACTION BUTTONS --------------------
      bottomNavigationBar: BottomAppBar(
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () => _handleVote(true),
              icon: const Icon(Icons.thumb_up, color: Colors.green),
              label: const Text("Upvote",
                  style: TextStyle(color: Colors.green)),
            ),
            TextButton.icon(
              onPressed: () => _handleVote(false),
              icon: const Icon(Icons.thumb_down, color: Colors.red),
              label: const Text("Downvote",
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  /// UI Helpers
  Widget _buildIconInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
      ],
    );
  }

  Widget _buildVoteBox(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(count.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, String description, String date, Color color, {bool isFirst = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(width: 2, height: 20, color: isFirst ? Colors.transparent : Colors.grey[300]),
            Container(
              width: 16, height: 16,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            ),
            Container(width: 2, height: 40, color: isLast ? Colors.transparent : Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Text(description, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            ],
          ),
        ),
      ],
    );
  }


  /// ---------------------------------------------------------------------------
  /// DIRECT FIRESTORE VOTE UPDATE
  /// ---------------------------------------------------------------------------
  /// This function updates the upvote or downvote count atomically.
  /// It uses FieldValue.increment to avoid race conditions.
  /// Since StreamBuilder is listening to this document,
  /// UI will update instantly after Firestore change.
  /// ---------------------------------------------------------------------------
  Future<void> _handleVote(bool isUpvote) async {
    try {
      final String issueId = widget.issue['id'];

      await FirebaseFirestore.instance
          .collection('issues')
          .doc(issueId)
          .update({
        isUpvote
            ? 'upvotes'
            : 'downvotes': FieldValue.increment(1),
      });

    } catch (e) {
      debugPrint("Vote failed: $e");
    }
  }
}