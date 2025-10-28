import 'package:flutter/material.dart';

/// A reusable navigation drawer widget for the application.
///
/// It provides navigation links to the main screens of the app and highlights
/// the currently active route.
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const Color orangeColor = Color(0xFFE65100); // Custom orange for Exit

    // Get the current route name to determine which item to highlight.
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return SizedBox(
      width: 302,
      child: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Custom Header
            _buildDrawerHeader(context),
            const Divider(color: Color(0xFF2A2A2A), height: 1),

            // Navigation Items
            ListTile(
              leading: const Icon(Icons.apps, color: Colors.white),
              title: const Text(
                'Device Page',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Device Page if it's a separate route.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Device Page coming soon!')),
                );
              },
            ),
            _buildNavTile(
              context: context,
              title: 'Job management',
              icon: Icons.folder_copy_outlined,
              routeName: '/job-management',
              currentRoute: currentRoute,
            ),
            _buildNavTile(
              context: context,
              title: 'Arc on Metric',
              icon: Icons.build_circle_outlined,
              routeName: '/arc-time-metric',
              currentRoute: currentRoute,
            ),
            _buildNavTile(
              context: context,
              title: 'Machine Setting',
              icon: Icons.settings,
              routeName: '/',
              currentRoute: currentRoute,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.power_settings_new, color: orangeColor),
              title: const Text('Exit Device'),
              textColor: orangeColor,
              onTap: () {
                // TODO: Implement exit/disconnect logic.
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a standardized navigation tile that highlights itself if it's the current route.
  Widget _buildNavTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String routeName,
    String? currentRoute,
  }) {
    final bool isSelected = (currentRoute == routeName);
    return Container(
      color: isSelected ? Colors.blue : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[400]),
        title: Text(title),
        textColor: Colors.white,
        onTap: () {
          Navigator.pop(context); // Close the drawer
          // Only navigate if we are not already on that page.
          if (!isSelected) {
            // Use pushReplacementNamed to avoid building up a stack of pages.
            Navigator.pushReplacementNamed(context, routeName);
          }
        },
      ),
    );
  }

  /// Builds the header section of the drawer.
  Widget _buildDrawerHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 40.0, 16.0, 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with Logo and Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'assets/arcpilot_icon.png',
                width: 50,
                height: 25,
                errorBuilder: (c, e, s) =>
                const Icon(Icons.precision_manufacturing, size: 30),
              ),
              const SizedBox(width: 1), // Added for spacing
              // FIX: Wrap the title in Flexible to prevent overflow.
              const Flexible(
                child: Text(
                  'ArcPilot™',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 10), // Added for spacing
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Machine Info Row
          Row(
            children: [
              Image.asset(
                'assets/cigweld_icon.png',
                width: 80,
                height: 40,
                errorBuilder: (c, e, s) =>
                const Icon(Icons.settings_input_component, size: 40),
              ),
              const SizedBox(width: 8),
              // FIX: Wrap the Column in Expanded so it takes the remaining space.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transmax XP6 200i',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis, // Handle long names
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Disconnect',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}