// import 'package:civic_connect/features/issues/pages/report_issue_page.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:civic_connect/core/navigation/drawer_widget.dart';
// import 'package:civic_connect/features/issues/models/issue_model.dart';
// import 'package:civic_connect/features/issues/services/issue_service.dart';
// import 'package:civic_connect/features/issues/pages//issue_detail_page.dart';
// import 'package:civic_connect/features/issues/widgets/my_report_card.dart';
// import 'package:geolocator/geolocator.dart';
//
// /// ---------------------------------------------------------------------------
// /// MY REPORTS PAGE
// /// ---------------------------------------------------------------------------
// /// Displays all issues reported by the currently signed-in user.
// /// Uses StreamBuilder + IssueService for real-time Firestore updates.
// /// ---------------------------------------------------------------------------
// class MyReportsPage extends StatefulWidget {
//   const MyReportsPage({super.key});
//
//   @override
//   State<MyReportsPage> createState() => _MyReportsPageState();
// }
//
// class _MyReportsPageState extends State<MyReportsPage> {
//   /// Logic handler for Firestore CRUD operations and data streams
//   final IssueService _issueService = IssueService();
//
//   /// Current authenticated user's UID from Firebase Auth
//   /// Used as a unique key to filter issues in the Firestore collection
//   String get _currentUserId =>
//       FirebaseAuth.instance.currentUser?.uid ?? '';
//
//   /// Navigate to detail page — same pattern as HomePage
//   /// Converts IssueModel to Map to maintain compatibility with Detail Page arguments
//   void _navigateToDetail(IssueModel issue) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => IssueDetailPage(
//           issue: issue.toMap()..['id'] = issue.id,
//           onVote: (_) {}, // voting handled inside IssueDetailPage via Firestore directly
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//
//       /// -------------------- APP BAR --------------------
//       /// Standard navigation bar with Menu access for the AppDrawer
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: const Icon(Icons.menu, color: Colors.black87),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         title: const Text(
//           'My Reports',
//           style: TextStyle(
//             color: Colors.black87,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//
//       /// -------------------- DRAWER --------------------
//       /// Side navigation menu configured for the 'my_reports' route
//       drawer: const AppDrawer(currentRoute: 'my_reports'),
//
//       /// -------------------- BODY --------------------
//       /// Logic: Check if user is logged in -> Stream data from Firestore -> Build UI
//       body: _currentUserId.isEmpty
//           ? _buildNotSignedIn()
//           : StreamBuilder<List<IssueModel>>(
//         /// Database Query: Listen only to issues where reporterId == current user
//         stream: _issueService.getIssuesByUserStream(_currentUserId),
//         builder: (context, snapshot) {
//
//           /// 1. Loading State: Displayed while the stream establishes connection
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           /// 2. Error State: Handles Firebase permission issues or network failures
//           if (snapshot.hasError) {
//             return _buildErrorState(snapshot.error.toString());
//           }
//
//           /// Extracting the list of issues from the snapshot data
//           final List<IssueModel> myIssues = snapshot.data ?? [];
//
//           /// 3. Empty State: Triggered if the user has 0 reported documents in Firestore
//           if (myIssues.isEmpty) return _buildEmptyState();
//
//           /// 4. Data State: Display stats summary and the scrollable list
//           return Column(
//             children: [
//               /// Top UI component showing numerical breakdown of report statuses
//               _buildStatsSummary(myIssues),
//
//               Expanded(
//                 child: RefreshIndicator(
//                   onRefresh: () async {
//                     // Note: StreamBuilder auto-refreshes on DB changes;
//                     // this delay provides visual feedback to the user.
//                     await Future.delayed(const Duration(milliseconds: 500));
//                   },
//                   child: ListView.builder(
//                     padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
//                     itemCount: myIssues.length,
//                     itemBuilder: (context, index) {
//                       return MyReportCard(
//                         issue: myIssues[index],
//                         onTap: () => _navigateToDetail(myIssues[index]),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   /// -------------------- STATS SUMMARY --------------------
//   /// Local Logic: Filters the retrieved list to count different issue statuses.
//   /// This prevents multiple extra calls to Firestore for counts.
//   Widget _buildStatsSummary(List<IssueModel> issues) {
//     final int total = issues.length;
//     final int reported = issues.where((i) => i.status == 'Reported').length;
//     final int inProgress = issues.where((i) => i.status == 'In Progress').length;
//     final int resolved = issues.where((i) => i.status == 'Resolved').length;
//
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.blue.shade50, Colors.blue.shade100],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.blue.shade200),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildStatItem('Total', total, Colors.blue.shade700),
//           _buildDivider(),
//           _buildStatItem('Pending', reported, Colors.blue.shade500),
//           _buildDivider(),
//           _buildStatItem('In Progress', inProgress, Colors.orange.shade600),
//           _buildDivider(),
//           _buildStatItem('Resolved', resolved, Colors.green.shade600),
//         ],
//       ),
//     );
//   }
//
//   /// Vertical visual separator for the Stats Row
//   Widget _buildDivider() => Container(
//     height: 32,
//     width: 1,
//     color: Colors.blue.shade200,
//   );
//
//   /// Individual Stat UI block (Count + Label)
//   Widget _buildStatItem(String label, int count, Color color) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           '$count',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 11,
//             color: Colors.grey[700],
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// -------------------- EMPTY STATE --------------------
//   /// Informational UI when the user has not created any entries.
//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.blue[50],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.assignment_outlined,
//                 size: 64,
//                 color: Colors.blue[300],
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'No Reports Yet',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[800],
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               "You haven't reported any issues yet.\nStart making a difference in your community!",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton.icon(
//               onPressed: () async {
//                 try {
//                   // 1. Check/Request Permissions
//                   LocationPermission permission = await Geolocator.checkPermission();
//                   if (permission == LocationPermission.denied) {
//                     permission = await Geolocator.requestPermission();
//                   }
//
//                   if (permission == LocationPermission.deniedForever) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Location permission permanently denied")),
//                     );
//                     return;
//                   }
//
//                   // 2. Show a loading indicator if you want, or just fetch position
//                   Position position = await Geolocator.getCurrentPosition(
//                     desiredAccuracy: LocationAccuracy.high,
//                   );
//
//                   // 3. Navigate and wait for result
//                   final result = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ReportIssuePage(
//                         latitude: position.latitude,
//                         longitude: position.longitude,
//                         address: "Live Location",
//                       ),
//                     ),
//                   );
//
//                   // 4. Handle the Firestore upload if data comes back
//                   if (result != null && result is Map<String, dynamic>) {
//                     await _issueService.reportIssue(result);
//                     // No need to manually refresh!
//                     // Your StreamBuilder in MyReportsPage will see the new doc and show it.
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Issue Reported Successfully!'),
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                   }
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text("Could not get location: $e"),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               },
//               icon: const Icon(Icons.add),
//               label: const Text('Report an Issue'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// -------------------- ERROR STATE --------------------
//   /// UI fallback for when the Firestore stream fails.
//   Widget _buildErrorState(String error) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.cloud_off, size: 56, color: Colors.red[300]),
//             const SizedBox(height: 16),
//             Text(
//               'Failed to load reports',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[800],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               error,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// -------------------- NOT SIGNED IN --------------------
//   /// UI fallback for when FirebaseAuth returns null for current user.
//   Widget _buildNotSignedIn() {
//     return Center(
//       child: Text(
//         'Please sign in to view your reports.',
//         style: TextStyle(fontSize: 15, color: Colors.grey[600]),
//       ),
//     );
//   }
// }

import 'package:civic_connect/features/issues/pages/report_issue_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:civic_connect/core/navigation/drawer_widget.dart';
import 'package:civic_connect/features/issues/models/issue_model.dart';
import 'package:civic_connect/features/issues/services/issue_service.dart';
import 'package:civic_connect/features/issues/pages/issue_detail_page.dart';
import 'package:civic_connect/features/issues/widgets/my_report_card.dart';
import 'package:geolocator/geolocator.dart';
import 'package:civic_connect/features/issues/utils/issue_transformer.dart';

// ---------------------------------------------------------------------------
// FILTER TAB MODEL
// ---------------------------------------------------------------------------
// Encapsulates tab label, matching status value, and display color.
// ---------------------------------------------------------------------------
class _FilterTab {
  final String label;
  final String? status; // null = show all
  final Color color;
  final IconData icon;

  const _FilterTab({required this.label, required this.status, required this.color, required this.icon});
}

// ---------------------------------------------------------------------------
// MY REPORTS PAGE
// ---------------------------------------------------------------------------
// Displays all issues reported by the currently signed-in user.
// Features pill-tab filtering: All / Reported / In Progress / Resolved
// Tab switching uses a lightweight one-way fade — no AnimatedSwitcher,
// no widget destruction, no double-blink.
// ---------------------------------------------------------------------------
class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> with SingleTickerProviderStateMixin {
  final IssueService _issueService = IssueService();

  // Filter definitions — order maps to tab indices
  static const List<_FilterTab> _tabs = [
    _FilterTab(label: 'All', status: null, color: Color(0xFF1565C0), icon: Icons.grid_view_rounded),
    _FilterTab(label: 'Reported', status: 'Reported', color: Color(0xFF1976D2), icon: Icons.flag_rounded),
    _FilterTab(label: 'In Progress', status: 'In Progress', color: Color(0xFFE65100), icon: Icons.autorenew_rounded),
    _FilterTab(label: 'Resolved', status: 'Resolved', color: Color(0xFF2E7D32), icon: Icons.check_circle_rounded),
  ];

  int _selectedTabIndex = 0;

  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';



  // Tab tap: fade out → update index → fade in. One smooth pass.
  void _selectTab(int index) {
    if (index == _selectedTabIndex) return;
    setState(() => _selectedTabIndex = index);
  }

  void _navigateToDetail(IssueModel issue) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IssueDetailPage(issue: issue.toMap()..['id'] = issue.id, onVote: (_) {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // -------------------- APP BAR --------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF1A1A2E)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'My Reports',
          style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEF0F3)),
        ),
      ),

      drawer: const AppDrawer(currentRoute: 'my_reports'),

      // -------------------- BODY --------------------
      // -------------------- BODY --------------------
      body: _currentUserId.isEmpty
          ? _buildNotSignedIn()
          : StreamBuilder<List<IssueModel>>(
        stream: _issueService.getIssuesByUserStream(_currentUserId),
        builder: (context, snapshot) {
          final allIssues = snapshot.data ?? [];
          final Map<int, List<IssueModel>> tabData =
          IssueTransformer.transformToTabs(allIssues);
          final List<IssueModel> filtered =
              tabData[_selectedTabIndex] ?? [];

          if (snapshot.connectionState == ConnectionState.waiting &&
              allIssues.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF1565C0), strokeWidth: 2.5),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          return Column(
            children: [
              _buildStickyHeader(allIssues),
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                  color: const Color(0xFF1565C0),
                  onRefresh: () async {
                    await Future.delayed(
                        const Duration(milliseconds: 400));
                  },
                  child: ListView.builder(
                    key: PageStorageKey<int>(_selectedTabIndex),
                    cacheExtent: 1000,
                    padding:
                    const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return RepaintBoundary(
                        child: MyReportCard(
                          key: ValueKey(filtered[index].id),
                          issue: filtered[index],
                          onTap: () =>
                              _navigateToDetail(filtered[index]),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // -------------------- STICKY HEADER --------------------
  // Contains both the stats row and the animated filter tabs.
  // Stays pinned while the list below scrolls independently.
  Widget _buildStickyHeader(List<IssueModel> issues) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildStatsSummary(issues),
          _buildTabBar(issues),
          Container(height: 1, color: const Color(0xFFEEF0F3)),
        ],
      ),
    );
  }

  // -------------------- STATS SUMMARY --------------------
  Widget _buildStatsSummary(List<IssueModel> issues) {
    final int total = issues.length;
    final int reported = issues.where((i) => i.status == 'Reported').length;
    final int inProgress = issues.where((i) => i.status == 'In Progress').length;
    final int resolved = issues.where((i) => i.status == 'Resolved').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8F0FE), Color(0xFFDCEAFD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBDD0F8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total', total, const Color(0xFF1565C0)),
            _buildStatDivider(),
            _buildStatItem('Pending', reported, const Color(0xFF1976D2)),
            _buildStatDivider(),
            _buildStatItem('In Progress', inProgress, const Color(0xFFE65100)),
            _buildStatDivider(),
            _buildStatItem('Resolved', resolved, const Color(0xFF2E7D32)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() => Container(height: 30, width: 1, color: const Color(0xFFBDD0F8));

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.5),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(fontSize: 10.5, color: Colors.grey[600], fontWeight: FontWeight.w500, letterSpacing: 0.2),
        ),
      ],
    );
  }

  // -------------------- ANIMATED TAB BAR --------------------
  // Custom pill-style tabs with animated indicator and badge counts.
  Widget _buildTabBar(List<IssueModel> issues) {
    // Counts per tab for badges
    final counts = [
      issues.length,
      issues.where((i) => i.status == 'Reported').length,
      issues.where((i) => i.status == 'In Progress').length,
      issues.where((i) => i.status == 'Resolved').length,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            final isSelected = _selectedTabIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => _selectTab(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? tab.color : const Color(0xFF8A94A6),
                          ),
                        ),
                        if (counts[index] > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: isSelected ? tab.color.withOpacity(0.12) : const Color(0xFFDDE1E8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${counts[index]}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? tab.color : const Color(0xFF8A94A6),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // -------------------- EMPTY STATE --------------------
  Widget _buildEmptyState() {
    final tab = _tabs[_selectedTabIndex];
    final bool isAllTab = tab.status == null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: tab.color.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(isAllTab ? Icons.assignment_outlined : tab.icon, size: 56, color: tab.color.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              isAllTab ? 'No Reports Yet' : 'No ${tab.label} Issues',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E), letterSpacing: -0.3),
            ),
            const SizedBox(height: 10),
            Text(
              isAllTab
                  ? "You haven't reported any issues yet.\nStart making a difference in your community!"
                  : "You have no issues with '${tab.label}' status right now.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: Colors.grey[500], height: 1.6),
            ),
            if (isAllTab) ...[const SizedBox(height: 32), _buildReportButton()],
          ],
        ),
      ),
    );
  }

  Widget _buildReportButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.deniedForever) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location permission permanently denied")));
            return;
          }
          Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportIssuePage(latitude: position.latitude, longitude: position.longitude, address: "Live Location"),
            ),
          );
          if (result != null && result is Map<String, dynamic>) {
            await _issueService.reportIssue(result);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Issue Reported Successfully!'), backgroundColor: Color(0xFF2E7D32)));
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not get location: $e"), backgroundColor: Colors.red));
        }
      },
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Report an Issue'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.2),
      ),
    );
  }

  // -------------------- ERROR STATE --------------------
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
              child: Icon(Icons.cloud_off_rounded, size: 48, color: Colors.red[300]),
            ),
            const SizedBox(height: 20),
            const Text(
              'Failed to load reports',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- NOT SIGNED IN --------------------
  Widget _buildNotSignedIn() {
    return Center(
      child: Text('Please sign in to view your reports.', style: TextStyle(fontSize: 15, color: Colors.grey[600])),
    );
  }
}
