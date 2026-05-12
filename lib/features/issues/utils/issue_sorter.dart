import 'package:civic_connect/shared/utils/distance_calculator.dart';
import 'package:civic_connect/features/issues/data/mock_card_data.dart';


/// Calculate distance between two coordinates using Haversine formula
/// Returns distance in kilometers
///
/// FIREBASE NOTES:
/// - For production, use Firestore GeoPoint and GeoFlutterFire package
/// - This allows querying issues within radius efficiently
/// - Current approach calculates distance client-side (fine for MVP)

/// Sort issues by combination of:
/// 1. Distance from user (closer = better)
/// 2. Vote score (upvotes - downvotes)
///
/// ALGORITHM:
/// - Calculate relevance score for each issue
/// - Score = (upvotes - downvotes) / (distance + 1)
/// - Higher score = more relevant
/// https://github.com/crox-321/buddhiman-developers
///
///
///
/// Mock user location (will be replaced with actual GPS coordinates)
/// TODO: Replace with Geolocator package to get real user location
/// Example: Position position = await Geolocator.getCurrentPosition();
double userLatitude = 18.5204; // Default to Pune, Maharashtra
double userLongitude = 73.8567;

/// Sorted list of issues (will be updated when user clicks "Find Near Me")
List<Map<String, dynamic>> sortedIssues = [];
void sortIssuesByRelevance() {
    sortedIssues = List.from(issues);
    sortedIssues.sort((a, b) {
      // Calculate distance for both issues
      double distanceA = calculateDistance(
        userLatitude,
        userLongitude,
        a['latitude'],
        a['longitude'],
      );
      double distanceB = calculateDistance(
        userLatitude,
        userLongitude,
        b['latitude'],
        b['longitude'],
      );

      // Calculate vote score
      int voteScoreA = a['upvotes'] - a['downvotes'];
      int voteScoreB = b['upvotes'] - b['downvotes'];

      // Calculate relevance (higher is better)
      // Adding 1 to distance to avoid division by zero
      double relevanceA = voteScoreA / (distanceA + 1);
      double relevanceB = voteScoreB / (distanceB + 1);

      // Sort descending (higher relevance first)
      return relevanceB.compareTo(relevanceA);
    });
}