import 'dart:io';
import 'package:flutter/material.dart';

class IssueCard extends StatelessWidget {
  final Map<String, dynamic> issue;
  final VoidCallback onTap;

  const IssueCard({
    super.key,
    required this.issue,
    required this.onTap,
  });

  /// Get color based on issue status
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

  /// Get icon based on category
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
      default:
        return Icons.report_problem_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ADD THIS PRINT LINE HERE:
    print("DEBUG: Issue ID: ${issue['id']} | Image URL: ${issue['imageUrls']}");
    // Defense: Fallbacks for missing Firestore fields
    final Color statusColor = _getStatusColor(issue['status'] ?? 'Reported');
    final IconData categoryIcon = _getCategoryIcon(issue['category'] ?? 'General');

    return GestureDetector(
      onTap: onTap,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE THUMBNAIL (Fixed logic)
            if (issue['imageUrls'] != null && (issue['imageUrls'] as List).isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: issue['imageUrls'][0].startsWith('http')
                    ? Image.network(
                  issue['imageUrls'][0],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Fix: handle broken URLs without crashing
                  errorBuilder: (context, error, stackTrace) => _imageErrorWidget(),
                )
                    : Image.file(
                  File(issue['imageUrls'][0]),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _imageErrorWidget(),
                ),
              )
            else
            // Fix: Show something if imageUrls is null/empty
              _imageErrorWidget(),

            /// CARD CONTENT (Everything else is your original UI)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(categoryIcon, size: 14, color: Colors.grey[700]),
                            const SizedBox(width: 4),
                            Text(
                              issue['category'] ?? 'General',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    issue['title'] ?? 'No Title',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.place_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          issue['address'] ?? 'Unknown Location',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          issue['status'] ?? 'Reported',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_upward, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${issue['upvotes'] ?? 0}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.arrow_downward, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${issue['downvotes'] ?? 0}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder widget for missing or broken images
  Widget _imageErrorWidget() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
      ),
    );
  }
}