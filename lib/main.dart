import 'package:flutter/material.dart';

// Pages
import 'route_page.dart';
import 'map_page.dart';
import 'institutes_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USP Acessível',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Manrope',
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF1B4ACD),
          unselectedItemColor: Color(0xFF737373),
          selectedLabelStyle: TextStyle(fontSize: 17),
          unselectedLabelStyle: TextStyle(fontSize: 17),
          selectedIconTheme: IconThemeData(size: 28),
          unselectedIconTheme: IconThemeData(size: 28),
        ),
      ),
      // Set MainScreen as your home. No complex onGenerateRoute needed for basic tabs!
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
  final List<Widget> _pages = const [MapPage(), InstitutesPage(), RoutePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 3. IndexedStack keeps all tab states alive in memory
      // without destroying/rebuilding them when you switch tabs
      body: IndexedStack(index: _currentIndex, children: _pages),
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
            label: 'Rotas visuais',
            icon: Icon(Icons.remove_red_eye),
          ),
        ],
      ),
    );
  }
}
