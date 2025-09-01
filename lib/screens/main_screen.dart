import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/quote_provider.dart';
import '../providers/theme_provider.dart';
import 'home/home_screen.dart';
import 'habits/habits_screen.dart';
import 'progress/progress_screen.dart';
import 'quotes/quotes_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HabitsScreen(),
    const ProgressScreen(),
    const QuotesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      final userId = authProvider.currentUser!.uid;
      
      // Load habits
      habitProvider.loadHabits(userId);
      
      // Load quotes
      quoteProvider.loadRandomQuotes(count: 5);
      quoteProvider.loadFavoriteQuotes(userId);
      quoteProvider.loadDailyQuote(userId);
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Check if user is authenticated
    if (!authProvider.isAuthenticated) {
      // Use a post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !authProvider.isAuthenticated) {
          print('User not authenticated in main screen, navigating to login');
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Loading...'),
              const SizedBox(height: 8),
              Text(
                'Checking authentication...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
        allowImplicitScrolling: false,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF6366F1),
            unselectedItemColor: const Color(0xFF94A3B8),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentIndex == 0 
                        ? const Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
                    size: 24,
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentIndex == 1 
                        ? const Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _currentIndex == 1 ? Icons.track_changes_rounded : Icons.track_changes_outlined,
                    size: 24,
                  ),
                ),
                label: 'Habits',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentIndex == 2 
                        ? const Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _currentIndex == 2 ? Icons.analytics_rounded : Icons.analytics_outlined,
                    size: 24,
                  ),
                ),
                label: 'Progress',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentIndex == 3 
                        ? const Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _currentIndex == 3 ? Icons.format_quote_rounded : Icons.format_quote_outlined,
                    size: 24,
                  ),
                ),
                label: 'Quotes',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentIndex == 4 
                        ? const Color(0xFF6366F1).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _currentIndex == 4 ? Icons.person_rounded : Icons.person_outline,
                    size: 24,
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
