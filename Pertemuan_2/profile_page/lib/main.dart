import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ================= APP =================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // ================= LIGHT THEME =================
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',

        scaffoldBackgroundColor: const Color(0xFFF6F4FF),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B61FF),
          brightness: Brightness.light,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      // ================= DARK THEME =================
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',

        scaffoldBackgroundColor: const Color(0xFF121212),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B61FF),
          brightness: Brightness.dark,
        ),

        cardColor: const Color(0xFF1E1E1E),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      home: ProfilePage(isDarkMode: isDarkMode, onThemeChanged: toggleTheme),
    );
  }
}

// ================= PROFILE PAGE =================
class ProfilePage extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const ProfilePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ================= APPBAR =================
      appBar: AppBar(
        title: const Text(
          'Personal Space',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),

      // ================= DRAWER =================
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,

          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7B61FF), Color(0xFFFFB3C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,

                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      'https://avatars.githubusercontent.com/u/9919?v=4',
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    'Anandita Putri',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Mobile App Enthusiast',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const ListTile(
              leading: Icon(Icons.home_rounded),
              title: Text('Home'),
            ),

            const ListTile(
              leading: Icon(Icons.person_rounded),
              title: Text('Profile'),
            ),

            // ================= DARK MODE =================
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_rounded),

              title: const Text('Dark Mode'),

              value: isDarkMode,

              onChanged: onThemeChanged,
            ),

            ListTile(
              leading: const Icon(Icons.settings_rounded),

              title: const Text('Settings'),

              onTap: () {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Settings'),

                    content: const Text(
                      'This feature is currently under development.',
                    ),

                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),

                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.widgets_rounded),

              title: const Text('Widget Showcase'),

              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GalleryHome()),
                );
              },
            ),

            const ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text('About'),
            ),
          ],
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            // ================= PROFILE HEADER =================
            Container(
              padding: const EdgeInsets.all(26),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),

                gradient: const LinearGradient(
                  colors: [Color(0xFF7B61FF), Color(0xFFFFB3C7)],

                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 25,
                    offset: Offset(0, 10),
                  ),
                ],
              ),

              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      border: Border.all(color: Colors.white, width: 3),
                    ),

                    child: const CircleAvatar(
                      radius: 54,
                      backgroundImage: NetworkImage(
                        'https://avatars.githubusercontent.com/u/9919?v=4',
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Anandita Putri Salsabila Athaya',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Informatics Engineering Student',

                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                    children: [
                      _ProfileStat(value: '12', label: 'Projects'),

                      _ProfileStat(value: '128', label: 'Friends'),

                      _ProfileStat(value: '1.2K', label: 'Followers'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const _SectionCard(
              icon: Icons.info_outline_rounded,
              title: 'About Me',

              content:
                  'Passionate about mobile development, UI/UX design, and creating beautiful digital experiences.',
            ),

            const _SectionCard(
              icon: Icons.school_rounded,
              title: 'Education',

              content:
                  'Pasundan University — 6th Semester\nStudent ID: 233040118',
            ),

            const _SectionCard(
              icon: Icons.favorite_rounded,
              title: 'Interests & Hobbies',

              content: 'Design • Coding • Photography • Music • Reading',
            ),

            const _SectionCard(
              icon: Icons.email_rounded,
              title: 'Contact',

              content: 'anandita@example.com\n+62 812-3456-7890',
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // ================= FAB =================
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7B61FF),

        foregroundColor: Colors.white,

        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile customization is not available yet.'),
            ),
          );
        },

        icon: const Icon(Icons.edit_rounded),

        label: const Text('Customize'),
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: NavigationBar(
        height: 74,

        selectedIndex: 1,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),

          NavigationDestination(
            icon: Icon(Icons.mail_outline_rounded),
            selectedIcon: Icon(Icons.mail),
            label: 'Inbox',
          ),

          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

// ================= PROFILE STAT =================
class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

// ================= SECTION CARD =================
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,

      margin: const EdgeInsets.only(bottom: 16),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: const Color(0xFFF0EBFF),

                borderRadius: BorderRadius.circular(16),
              ),

              child: Icon(icon, color: const Color(0xFF7B61FF), size: 24),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    content,

                    style: TextStyle(color: Colors.grey.shade700, height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= GALLERY HOME =================
class GalleryHome extends StatelessWidget {
  const GalleryHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Showcase')),

      body: const Center(child: Text('Widget Showcase Page')),
    );
  }
}
