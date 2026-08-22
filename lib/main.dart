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
      title: 'Persistent Taskbar Demo',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Manrope',
        // Define the default colors for all BottomNavigationBars
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF1B4ACD),
          unselectedItemColor: Color(0xFF737373),
          selectedLabelStyle: TextStyle(fontSize: 17),
          unselectedLabelStyle: TextStyle(fontSize: 17),
          selectedIconTheme: IconThemeData(size: 28),
          unselectedIconTheme: IconThemeData(size: 28),
        ),
      ),
      initialRoute: '/',
      // Use onGenerateRoute to pass the current route string into MainScreen
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => MainScreen(currentRoute: settings.name ?? '/'),
        );
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  final String currentRoute;

  const MainScreen({super.key, required this.currentRoute});

  // 1. Define your map of routes to screen content
  static const Map<String, Widget> _routePages = {
    '/': MapPage(),
    '/institutes': InstitutesPage(),
    '/visual-route': RoutePage(),
  };

  // 2. Define a list of your routes matching the taskbar item order
  static const List<String> _navOrder = ['/', '/institutes', '/visual-route'];

  @override
  Widget build(BuildContext context) {
    // Determine active index based on current route path
    int currentIndex = _navOrder.indexOf(currentRoute);
    if (currentIndex == -1) currentIndex = 0; // Fallback to home

    return Scaffold(
      // Display the content matching the current active route path
      body: _routePages[currentRoute] ?? _routePages['/'],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          // Trigger a route change when an item is tapped
          String targetRoute = _navOrder[index];
          if (currentRoute != targetRoute) {
            Navigator.pushNamed(context, targetRoute);
          }
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
