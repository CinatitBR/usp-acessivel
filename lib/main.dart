import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Colors
import 'package:usp_acessivel/core/theme/app_colors.dart';

import 'package:usp_acessivel/features/map/repositories/building_repository.dart';

// Pages
import 'package:usp_acessivel/features/map/pages/map_page.dart';
import 'package:usp_acessivel/features/institutes/pages/institutes_page.dart';

void main() async {
  // Needed in order to call getBuildingEntries() before runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables depending on debug/release mode.
  if (kReleaseMode) {
    await dotenv.load(fileName: "env.production");
  } else {
    await dotenv.load(fileName: "env.development");
  }

  // Parse the GeoJSON file of buildings in the background, and cache in memory
  BuildingRepository.instance.getBuildingEntries();

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
        navigationBarTheme: NavigationBarThemeData(
          // 1. Configure the item label text styles
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: .w600,
              );
            }
            return textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral[500],
            );
          }),

          // 2. Configure the icon themes (Size and Color)
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(size: 28, color: AppColors.primary);
            }
            return IconThemeData(size: 28, color: AppColors.neutral[500]);
          }),

          // 3. Optional: Customize the animated selection pill container background
          // Change to Colors.transparent if you want to remove the pill effect completely
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
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

  final List<Widget> _pages = [MapPage(), InstitutesPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: AppColors.neutral[50],
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(label: 'Explorar', icon: Icon(Icons.explore)),
          NavigationDestination(label: 'Institutos', icon: Icon(Icons.school)),
        ],
      ),
    );
  }
}
