import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/mood_screen.dart';
import 'screens/resources_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    // If Firebase isn't configured for this platform (e.g. Windows),
    // prevent a hard crash and log the error for diagnosis.
    debugPrint('Firebase initialization error: $e\n$st');
  }
  runApp(const Qalby2HeartApp());
}

class AuthGate extends StatelessWidget {
  /// When true (test-only) forces the offline fallback instead of checking
  /// `Firebase.apps`.
  final bool forceOffline;

  const AuthGate({super.key, this.forceOffline = false});

  @override
  Widget build(BuildContext context) {
    // If Firebase isn't initialized (for example on unsupported platforms),
    // avoid calling FirebaseAuth and show a simple offline/fallback UI instead
    // of letting an exception crash the app.
    if (forceOffline || Firebase.apps.isEmpty) {
      // When Firebase isn't configured, show the main UI in offline mode
      // so the app doesn't exit and tests can run without Firebase.
      return const MainScreen(offline: true);
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return const MainScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}

class Qalby2HeartApp extends StatelessWidget {
  const Qalby2HeartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qalby2Heart',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF2E7D32),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  /// Indicates the app is running without Firebase configured.
  final bool offline;

  const MainScreen({super.key, this.offline = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AIChatScreen(),
    const MoodScreen(),
    const ResourcesScreen(),
    const JournalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qalby2Heart'),
        // Show a small banner under the AppBar when running in offline mode
        bottom: widget.offline
            ? const PreferredSize(
                preferredSize: Size.fromHeight(28.0),
                child: SizedBox(
                  height: 28.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.amber),
                    child: Center(
                      child: Text(
                        'Offline: Firebase not configured',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            tooltip: 'Sign out',
          )
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'AI Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Mood',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Resources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Journal',
          ),
        ],
      ),
    );
  }
}
