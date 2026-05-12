import 'package:flutter/material.dart';
import 'package:civic_connect/features/static/about_us_page.dart';
import 'package:civic_connect/features/issues/my_reports_page.dart';

/// ---------------------------------------------------------------------------
/// APP DRAWER - MAIN NAVIGATION
/// ---------------------------------------------------------------------------
/// Central navigation drawer for the entire app.
///
/// DESIGN PHILOSOPHY:
/// - Material 3 design language
/// - Clear visual hierarchy
/// - Active route highlighting
/// - Auto-close after navigation
/// - Scalable for future menu items
///
/// FUTURE ENHANCEMENTS:
/// - Add user profile section at top
/// - Add settings page
/// - Add analytics/stats page
/// - Add logout functionality
/// - Theme toggle (dark mode)
class AppDrawer extends StatelessWidget {
  /// Current active route - used to highlight the selected menu item
  /// Pass this from each page to show which page is currently active
  final String currentRoute;

  const AppDrawer({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          /// -------------------- DRAWER HEADER --------------------
          /// Contains app branding and user info placeholder
          ///
          /// TODO: Add user information when Firebase Auth is integrated
          /// - User profile picture
          /// - User name
          /// - User email
          /// - Join date or total reports count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 24,
              left: 20,
              right: 20,
            ),
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
                /// App logo/icon placeholder
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.track_changes,
                    size: 32,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 16),

                /// App name
                const Text(
                  'Civic Bandhu',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),

                /// City scope
                Text(
                  'Vadodara Edition',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),

                /// User info placeholder
                /// TODO: Replace with actual user data from Firebase Auth
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Guest User',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// -------------------- NAVIGATION MENU ITEMS --------------------
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                /// HOME
                _buildDrawerItem(
                  context: context,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  title: 'Home',
                  route: 'home',
                  onTap: () {
                    // Close drawer
                    Navigator.pop(context);
                    // If not already on home, navigate to home
                    if (currentRoute != 'home') {
                      // Pop all routes and go back to home
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                ),

                /// MY REPORTS
                _buildDrawerItem(
                  context: context,
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment,
                  title: 'My Reports',
                  route: 'my_reports',
                  onTap: () {
                    // Close drawer
                    Navigator.pop(context);
                    // Navigate to My Reports only if not already there
                    if (currentRoute != 'my_reports') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyReportsPage(),
                        ),
                      );
                    }
                  },
                ),

                /// DIVIDER
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Divider(
                    color: Colors.grey[300],
                    thickness: 1,
                  ),
                ),

                /// ABOUT / TRANSPARENCY
                _buildDrawerItem(
                  context: context,
                  icon: Icons.info_outline,
                  activeIcon: Icons.info,
                  title: 'About & Transparency',
                  route: 'about',
                  onTap: () {
                    // Close drawer
                    Navigator.pop(context);
                    // Navigate to About page
                    if (currentRoute != 'about') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    }
                  },
                ),

                /// PLACEHOLDER FOR FUTURE ITEMS
                /// Uncomment and implement when ready:

                // _buildDrawerItem(
                //   context: context,
                //   icon: Icons.settings_outlined,
                //   activeIcon: Icons.settings,
                //   title: 'Settings',
                //   route: 'settings',
                //   onTap: () {
                //     Navigator.pop(context);
                //     // Navigate to settings
                //   },
                // ),
              ],
            ),
          ),

          /// -------------------- DRAWER FOOTER --------------------
          /// App version and logout option
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                /// LOGOUT BUTTON (placeholder)
                /// TODO: Implement Firebase Auth sign out
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement logout
                      // await FirebaseAuth.instance.signOut();
                      // Navigate to login screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logout feature coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                /// App version
                Text(
                  'Version 1.0.0 (MVP)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// -------------------- DRAWER ITEM BUILDER --------------------
  /// Reusable widget for each drawer menu item
  /// Handles active state, icons, and navigation
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String route,
    required VoidCallback onTap,
  }) {
    final bool isActive = currentRoute == route;

    return ListTile(
      leading: Icon(
        isActive ? activeIcon : icon,
        color: isActive ? Colors.blue[700] : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          color: isActive ? Colors.blue[700] : Colors.grey[800],
        ),
      ),
      selected: isActive,
      selectedTileColor: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 4,
      ),
      onTap: onTap,
    );
  }
}

/// ---------------------------------------------------------------------------
/// USAGE INSTRUCTIONS
/// ---------------------------------------------------------------------------
///
/// To use this drawer in any page:
///
/// 1. Add drawer to Scaffold:
///    Scaffold(
///      drawer: AppDrawer(currentRoute: 'home'), // or 'my_reports', 'about'
///      appBar: AppBar(...),
///      body: ...
///    )
///
/// 2. Make sure hamburger icon is in AppBar:
///    AppBar(
///      leading: IconButton(
///        icon: const Icon(Icons.menu),
///        onPressed: () {
///          Scaffold.of(context).openDrawer();
///        },
///      ),
///    )
///
///    OR use Builder:
///    leading: Builder(
///      builder: (context) => IconButton(
///        icon: const Icon(Icons.menu),
///        onPressed: () => Scaffold.of(context).openDrawer(),
///      ),
///    )
///
/// 3. Pass the correct currentRoute string to highlight active page
///