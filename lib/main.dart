import 'package:flutter/material.dart';

// Colors
import 'app_colors.dart';

// Pages
import 'map_page.dart';
import 'institutes_page.dart';
import 'create_visual_route_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    const textTheme = TextTheme(
      displaySmall: TextStyle(
        // === Display ===
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: TextStyle(
        // === Heading ===
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        // === Title ===
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        // === Subtitle ===
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        // === Body ===
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        // === Body small ===
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelMedium: TextStyle(
        // === Label ===
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        // === Description ===
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );

    return MaterialApp(
      title: 'USP Acessível',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Manrope',
        textTheme: textTheme,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Color(0xFF737373),
          selectedLabelStyle: textTheme.labelMedium,
          unselectedLabelStyle: textTheme.labelMedium,
          selectedIconTheme: IconThemeData(size: 28),
          unselectedIconTheme: IconThemeData(size: 28),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// 1. Changed to StatefulWidget to track tab index locally without changing global routes
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 2. Ordered list of pages matching the bottom taskbar indexes
  final List<Widget> _pages = [
    MapPage(),
    InstitutesPage(),
    CreateVisualRoutePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 3. IndexedStack keeps all tab states alive in memory
      // without destroying/rebuilding them when you switch tabs
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // 4. Update the index locally instead of using Navigator.pushNamed
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(label: 'Explorar', icon: Icon(Icons.explore)),
          BottomNavigationBarItem(
            label: 'Institutos',
            icon: Icon(Icons.school),
          ),
          BottomNavigationBarItem(
            label: 'Rota visual',
            icon: Icon(Icons.remove_red_eye),
          ),
        ],
      ),
    );
  }
}
