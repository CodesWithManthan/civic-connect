import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:civic_connect/core/auth/google_auth_service.dart';
import 'package:civic_connect/features/issues/issue_detail_page.dart';
import 'package:civic_connect/shared/widgets/issue_card.dart';
import 'package:civic_connect/features/issues/report_issue_page.dart';
import 'package:civic_connect/shared/utils/distance_calculator.dart';
import 'package:civic_connect/features/issues/data/mock_card_data.dart'; // Still used for currentLatitude ?? 0/Longitude
import 'package:civic_connect/core/navigation/drawer_widget.dart';
import 'package:civic_connect/features/issues/models/issue_model.dart';
import 'package:civic_connect/features/issues/services/issue_service.dart';



/// ---------------------------------------------------------------------------
/// USER DASHBOARD / HOME FEED PAGE
/// ---------------------------------------------------------------------------
/// The primary screen where users view live civic issues reported in the community.
/// Now connected to Firebase Firestore for real-time updates.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Instance of the service to communicate with Firestore
  final IssueService _issueService = IssueService();

  bool isLocationSortingEnabled = false;
  double? currentLatitude;
  double? currentLongitude;
  String? currentAddress;

  /// Handles user sign out via GoogleAuthService
  void _handleSignOut(BuildContext context) async {
    try {
      await GoogleAuthService.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// Triggers a vote update in Firestore
  /// [issueId] is the Firestore document ID
  /// [isUpvote] determines if we increment upvotes or downvotes
  void _handleVote(String issueId, bool isUpvote) async {
    try {
      await _issueService.updateVotes(issueId, isUpvote);
      // No setState needed! StreamBuilder listens to Firestore changes automatically.
    } catch (e) {
      debugPrint("Vote failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: const AppDrawer(currentRoute: 'home'),

      // StreamBuilder listens to the Firestore stream defined in IssueService
      body: StreamBuilder<List<IssueModel>>(
        stream: _issueService.getIssuesStream(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(child: Text('Error loading issues: ${snapshot.error}'));
          }

          // 3. Data Extraction
          List<IssueModel> currentIssues = snapshot.data ?? [];

// ------------------------------------------------------
// SORT ISSUES BASED ON DISTANCE + VOTE SCORE
// ------------------------------------------------------
          if (isLocationSortingEnabled && currentLatitude != null && currentLongitude != null) {
            currentIssues.sort((a, b) {
              double distanceA = calculateDistance(
                currentLatitude!,
                currentLongitude!,
                a.latitude,
                a.longitude,
              );

              double distanceB = calculateDistance(
                currentLatitude!,
                currentLongitude!,
                b.latitude,
                b.longitude,
              );

              return distanceA.compareTo(distanceB);
            });
          }

          return Column(
            children: [
              /// TOP ACTION BUTTON - Find Issues Near Me
              _buildLocationSortButton(context),

              /// ISSUES FEED - Scrollable list of real Firestore issues
              Expanded(
                child: currentIssues.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: currentIssues.length,
                  itemBuilder: (context, index) {
                    final issue = currentIssues[index];



                    return IssueCard(
                      // .toMap() is used because IssueCard currently expects a Map
                      issue: issue.toMap()..['id'] = issue.id,
                      onTap: () => _navigateToDetailPage(context, issue),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: _buildReportButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// AppBar Widget Construction
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: const Text('Civic Bandhu', style: TextStyle(color: Colors.black87, fontSize: 18)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: PopupMenuButton<String>(
            icon: const CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 18,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            onSelected: (value) {
              if (value == 'signout') _handleSignOut(context);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black87, size: 20),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Location Sorting Button - Now fetches real GPS coordinates
  Widget _buildLocationSortButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            // 1. Check/Request Permissions
            LocationPermission permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission();
            }

            // 2. Get current position
            Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high
            );

            // 3. Update the state so distance_calculator.dart uses real numbers
            setState(() {
              currentLatitude  = position.latitude;
              currentLongitude  = position.longitude;
              isLocationSortingEnabled = true;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location Updated! Sorting by proximity.')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not get location: $e'), backgroundColor: Colors.red),
            );
          }
        },
        icon: const Icon(Icons.my_location),
        label: const Text('Find Issues Near Me'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  /// Navigation to Detail Page
  void _navigateToDetailPage(BuildContext context, IssueModel issue) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IssueDetailPage(
          issue: issue.toMap()..['id'] = issue.id,
          onVote: (isUpvote) => _handleVote(issue.id, isUpvote),
        ),
      ),
    );
  }

  /// UI for when no issues exist in the database
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No issues reported yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  /// Floating Action Button to report new issues
  Widget _buildReportButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        try {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.deniedForever) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Location permission permanently denied")),
            );
            return;
          }

          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportIssuePage(
                latitude: position.latitude,
                longitude: position.longitude,
                address: "Live Location",
              ),
            ),
          );

          if (result != null && result is Map<String, dynamic>) {
            print("RESULT MAP:");
            print(result);
            await _issueService.reportIssue(result);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Issue Reported'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Could not get location: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      label: const Text('Report Issue'),
      icon: const Icon(Icons.add),
      backgroundColor: Colors.lightBlueAccent,
    );
  }
}