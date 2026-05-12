import 'package:cloud_firestore/cloud_firestore.dart';

/// ---------------------------------------------------------------------------
/// REINFORCED ISSUE MODEL
/// ---------------------------------------------------------------------------
class IssueModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final double latitude;
  final double longitude;
  final String address;
  final String status;
  final int upvotes;
  final int downvotes;
  final List<String> imageUrls;
  final DateTime createdAt;
  final String reportedBy;

  IssueModel({
    required this.id, required this.title, required this.description,
    required this.category, required this.latitude, required this.longitude,
    required this.address, required this.status, required this.upvotes,
    required this.downvotes, required this.imageUrls, required this.createdAt,
    required this.reportedBy,
  });

  /// Factory constructor with defensive parsing
  factory IssueModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return IssueModel(
      id: doc.id,
      title: data['title']?.toString() ?? 'Untitled Issue',
      description: data['description']?.toString() ?? 'No description.',
      category: data['category']?.toString() ?? 'General',
      // DEFENSE: Use helper to prevent double/int mismatch
      latitude: _toDouble(data['latitude']),
      longitude: _toDouble(data['longitude']),
      address: data['address']?.toString() ?? 'Unknown Location',
      status: data['status']?.toString() ?? 'Reported',
      // DEFENSE: Use helper to prevent string/int mismatch
      upvotes: _toInt(data['upvotes']),
      downvotes: _toInt(data['downvotes']),
      imageUrls: data['imageUrls'] is List ? List<String>.from(data['imageUrls']) : [],
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      reportedBy: data['reportedBy']?.toString() ?? 'Anonymous',
    );
  }

  /// Helper: Safely converts any value (String, int, etc.) to double
  static double _toDouble(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  /// Helper: Safely converts any value to int
  static int _toInt(dynamic val) {
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, 'title': title, 'description': description, 'category': category,
      'latitude': latitude, 'longitude': longitude, 'address': address,
      'status': status, 'upvotes': upvotes, 'downvotes': downvotes,
      'imageUrls': imageUrls, 'createdAt': Timestamp.fromDate(createdAt),
      'reportedBy': reportedBy,
    };
  }
}