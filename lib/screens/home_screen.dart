// Import Flutter's material design widgets
import 'package:flutter/material.dart';
// Import the main screen for navigation
import 'package:qalby2heart/main.dart';

// HomeScreen is a StatelessWidget that displays the home screen with app header and quick access cards
class HomeScreen extends StatelessWidget {
  // Constructor for HomeScreen with optional key
  const HomeScreen({super.key});

  // Override build to return the widget tree for the screen
  @override
  Widget build(BuildContext context) {
    // Return a Scaffold with body as a column
    return Scaffold(
      body: Column(
        children: [
          // Header section
          Container(
            // Full width
            width: double.infinity,
            // Padding for the header
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            // Decoration with green background and rounded bottom corners
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            // Child is a column with app title and subtitle
            child: const Column(
              children: [
                // App title text
                Text(
                  'Qalby2Heart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Spacing
                SizedBox(height: 4),
                // Subtitle text
                Text(
                  'Your Faith-Based Mental Wellness Companion',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Main Content section
          Expanded(
            // SingleChildScrollView for scrollable content
            child: SingleChildScrollView(
              // Padding around the content
              padding: const EdgeInsets.all(16),
              // Child is a column with various sections
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting section
                  Row(
                    children: [
                      // Greeting text
                      const Text(
                        'As-salamu alaykum',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Spacing
                      const SizedBox(width: 8),
                      // Cloud icon
                      Icon(
                        Icons.cloud,
                        color: Colors.orange[300],
                        size: 20,
                      ),
                    ],
                  ),
                  // Spacing
                  const SizedBox(height: 8),
                  // Sub-greeting text
                  const Text(
                    'May peace and blessings be upon you. How can we support your wellness journey today?',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 24),
                  // Quranic Verse Card section
                  Container(
                    // Full width
                    width: double.infinity,
                    // Padding inside the card
                    padding: const EdgeInsets.all(20),
                    // Decoration with gradient background and rounded corners
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00897B), Color(0xFF2E7D32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    // Child is a column with verse and reference
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row with icon and verse text
                        Row(
                          children: [
                            // Moon icon
                            Icon(
                              Icons.nightlight_round,
                              color: Colors.white,
                              size: 32,
                            ),
                            // Spacing
                            SizedBox(width: 12),
                            // Expanded text for the verse
                            Expanded(
                              child: Text(
                                '"Verily, in the remembrance of Allah do hearts find rest."',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Spacing
                        SizedBox(height: 12),
                        // Verse reference
                        Text(
                          '— Quran 13:28',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 32),
                  // Quick Access Section header
                  const Text(
                    'Quick Access',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 16),
                  // Quick Access Cards Grid section
                  GridView.count(
                    // 2 columns
                    crossAxisCount: 2,
                    // Shrink to fit content
                    shrinkWrap: true,
                    // Disable scrolling
                    physics: const NeverScrollableScrollPhysics(),
                    // Spacing between columns
                    crossAxisSpacing: 16,
                    // Spacing between rows
                    mainAxisSpacing: 16,
                    // Aspect ratio for cards
                    childAspectRatio: 1.1,
                    // Children are the quick access cards
                    children: [
                      // AI Chat card
                      _buildQuickAccessCard(
                        icon: Icons.chat_bubble,
                        iconColor: const Color(0xFF00897B),
                        borderColor: Colors.green[100]!,
                        title: 'Talk to AI Counselor',
                        description: 'Get faith-based guidance',
                        onTap: () {
                          MainScreen.switchTab(context, 1); // AI Chat tab
                        },
                      ),
                      // Mood tracking card
                      _buildQuickAccessCard(
                        icon: Icons.favorite,
                        iconColor: Colors.pink,
                        borderColor: Colors.pink[100]!,
                        title: 'Track Your Mood',
                        description: 'Monitor your well-being',
                        onTap: () {
                          MainScreen.switchTab(context, 2); // Mood tab
                        },
                      ),
                      // Resources card
                      _buildQuickAccessCard(
                        icon: Icons.menu_book,
                        iconColor: Colors.blue,
                        borderColor: Colors.blue[100]!,
                        title: 'Islamic Resources',
                        description: 'Quran, Hadith & guidance',
                        onTap: () {
                          MainScreen.switchTab(context, 3); // Resources tab
                        },
                      ),
                      // Journal card
                      _buildQuickAccessCard(
                        icon: Icons.edit,
                        iconColor: Colors.pinkAccent,
                        borderColor: Colors.pink[100]!,
                        title: 'Private Journal',
                        description: 'Express your thoughts',
                        onTap: () {
                          MainScreen.switchTab(context, 4); // Journal tab
                        },
                      ),
                    ],
                  ),
                  // Spacing
                  const SizedBox(height: 24),
                  // Privacy Notice section
                  Container(
                    // Full width
                    width: double.infinity,
                    // Padding inside the notice
                    padding: const EdgeInsets.all(16),
                    // Decoration with yellow background and border
                    decoration: BoxDecoration(
                      color: Colors.yellow[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.yellow[200]!),
                    ),
                    // Child is a row with lock icon and text
                    child: Row(
                      children: [
                        // Lock icon
                        Icon(
                          Icons.lock,
                          color: Colors.orange[700],
                          size: 24,
                        ),
                        // Spacing
                        const SizedBox(width: 12),
                        // Expanded text for the privacy message
                        const Expanded(
                          child: Text(
                            'Your privacy is sacred. All conversations and entries are confidential and stored securely.',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build a quick access card for navigation
  Widget _buildQuickAccessCard({
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    // InkWell for tap handling
    return InkWell(
      // On tap callback
      onTap: onTap,
      // Border radius for the ink effect
      borderRadius: BorderRadius.circular(16),
      // Child is a container with the card design
      child: Container(
        // Padding inside the card
        padding: const EdgeInsets.all(16),
        // Decoration with white background, border, and rounded corners
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        // Child is a column with icon, title, and description
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              icon,
              color: iconColor,
              size: 40,
            ),
            // Spacing
            const SizedBox(height: 12),
            // Title text
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            // Spacing
            const SizedBox(height: 4),
            // Description text
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
