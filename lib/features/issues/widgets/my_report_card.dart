import 'package:flutter/material.dart';
import 'package:civic_connect/features/issues/models/issue_model.dart';

/// ---------------------------------------------------------------------------
/// MY REPORT CARD
/// ---------------------------------------------------------------------------
/// Individual card widget used in MyReportsPage.
/// Kept modular so MyReportsPage stays clean.
/// Displays thumbnail, status badge, title, category, date, and votes.
/// ---------------------------------------------------------------------------
class MyReportCard extends StatelessWidget {
  final IssueModel issue;
  final VoidCallback onTap;

  const MyReportCard({
    super.key,
    required this.issue,
    required this.onTap,
  });

  /// Maps the Firestore status string to a specific theme color.
  /// Used for both the badge background and text color.
  Color _statusColor(String status) {
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

  /// Returns a domain-specific icon based on the issue category.
  /// Enhances scannability for users glancing through their reports.
  IconData _categoryIcon(String category) {
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

  /// Logic: Converts a DateTime into a human-readable "time ago" string.
  /// Falls back to standard DD/MM/YYYY format for older reports.
  String _formatDate(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(issue.status);
    final String formattedDate = _formatDate(issue.createdAt);
    final bool hasImage = issue.imageUrls.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---- THUMBNAIL ----
            /// Logic: Loads the first image from the imageUrls list if available.
            /// Includes a fallback errorBuilder to prevent UI crashes on broken links.
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: hasImage
                  ? Image.network(
                issue.imageUrls.first,
                width: 100,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderImage(),
              )
                  : _placeholderImage(),
            ),

            /// ---- CONTENT ----
            /// Flexible layout containing title, metadata (category/date), and vote counts.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Status badge
                    /// Visually represents the current lifecycle of the issue in Firestore.
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        issue.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// Title
                    /// Truncated to 2 lines to maintain uniform card height across the list.
                    Text(
                      issue.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    /// Category
                    /// Combines the category-specific icon with the text label.
                    Row(
                      children: [
                        Icon(
                          _categoryIcon(issue.category),
                          size: 13,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          issue.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    /// Date
                    /// Shows how long ago the user reported this issue.
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 13, color: Colors.grey[400]),
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

                    /// Votes row
                    /// Real-time social proof: Displays upvotes/downvotes from other citizens.
                    Row(
                      children: [
                        Icon(Icons.thumb_up_alt_outlined,
                            size: 13, color: Colors.green[600]),
                        const SizedBox(width: 3),
                        Text(
                          '${issue.upvotes}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.thumb_down_alt_outlined,
                            size: 13, color: Colors.red[400]),
                        const SizedBox(width: 3),
                        Text(
                          '${issue.downvotes}',
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

            /// ---- ARROW ----
            /// Visual cue indicating that the card is interactable/clickable.
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Icon(Icons.chevron_right, color: Colors.grey[350]),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper Widget: Consistent placeholder for missing or failing network images.
  Widget _placeholderImage() {
    return Container(
      width: 100,
      height: 120,
      color: Colors.grey[100],
      child: Icon(Icons.image_not_supported,
          size: 28, color: Colors.grey[300]),
    );
  }
}