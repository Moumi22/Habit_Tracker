import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/quote_provider.dart';
import '../../models/quote_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);

    if (authProvider.userData != null) {
      final userId = authProvider.userData!.id;

      // Load habits (this is a stream, so we don't await it)
      habitProvider.loadHabits(userId);

      // Load quotes and daily quote
      await Future.wait([
        quoteProvider.loadRandomQuotes(count: 5),
        quoteProvider.loadDailyQuote(userId),
      ]);
    }
  }

  Future<void> _onRefresh() async {
    await _loadData();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final habitProvider = Provider.of<HabitProvider>(context);
    final quoteProvider = Provider.of<QuoteProvider>(context);

    // Show loading if auth is still initializing
    if (authProvider.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Loading...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
                Color(0xFF06B6D4),
                Color(0xFF10B981),
              ],
            ),
          ),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(context),
              const SizedBox(height: 24),

              // Stats Section
              _buildStatsSection(context),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActionsSection(context),
              const SizedBox(height: 24),

              // Today's Habits
              _buildTodaysHabitsSection(context),
              const SizedBox(height: 24),

              // Daily Quote
              _buildDailyQuoteSection(context),
              const SizedBox(height: 24),

              // Recent Quotes
              _buildRecentQuotesSection(context),
              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/create-habit');
        },
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Habit', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userData;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
            Color(0xFF06B6D4),
            Color(0xFF10B981),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back${user?.displayName != null && user!.displayName.isNotEmpty ? ', ${user.displayName}' : ''}!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getGreetingMessage(),
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final overallStats = habitProvider.getOverallStats();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Completed',
            '${overallStats['completedToday'] ?? 0}/${overallStats['totalHabits'] ?? 0}',
            Icons.check_circle,
            const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Success Rate',
            '${(overallStats['completionRate'] ?? 0).toStringAsFixed(0)}%',
            Icons.trending_up,
            const Color(0xFF06B6D4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Streak',
            '${overallStats['totalStreak'] ?? 0}',
            Icons.local_fire_department,
            const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Add Habit',
                Icons.add,
                const Color(0xFF6366F1),
                () {
                  Navigator.pushNamed(context, '/create-habit');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                'View Progress',
                Icons.bar_chart,
                const Color(0xFF10B981),
                () {
                  // Navigate to progress tab
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                'Get Quotes',
                Icons.format_quote,
                const Color(0xFF8B5CF6),
                () {
                  // Navigate to quotes tab
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysHabitsSection(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final todayHabits = habitProvider.todayHabits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Habits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${todayHabits.length} habits',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (todayHabits.isEmpty)
          _buildEmptyHabitsCard(context)
        else
          ...todayHabits
              .take(3)
              .map(
                (habit) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: _buildHabitCard(context, habit),
                ),
              ),
        if (todayHabits.length > 3)
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: _buildViewMoreButton(context, todayHabits.length - 3),
          ),
      ],
    );
  }

  Widget _buildHabitCard(BuildContext context, dynamic habit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  habit.isCompletedForDate(DateTime.now())
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFF64748B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              habit.isCompletedForDate(DateTime.now())
                  ? Icons.check
                  : Icons.radio_button_unchecked,
              color:
                  habit.isCompletedForDate(DateTime.now())
                      ? const Color(0xFF10B981)
                      : const Color(0xFF64748B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  habit.category.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  habit.isCompletedForDate(DateTime.now())
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFF64748B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              habit.isCompletedForDate(DateTime.now())
                  ? 'Completed'
                  : 'Pending',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    habit.isCompletedForDate(DateTime.now())
                        ? const Color(0xFF10B981)
                        : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHabitsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.add_task, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No habits for today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first habit to start building better routines!',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildViewMoreButton(BuildContext context, int remainingCount) {
    return GestureDetector(
      onTap: () {
        // Navigate to habits screen
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View $remainingCount more habits',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF6366F1)),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyQuoteSection(BuildContext context) {
    final quoteProvider = Provider.of<QuoteProvider>(context);
    final dailyQuote = quoteProvider.dailyQuote;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Inspiration',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        if (dailyQuote != null)
          _buildQuoteCard(context, dailyQuote)
        else
          _buildLoadingQuoteCard(context),
      ],
    );
  }

  Widget _buildQuoteCard(BuildContext context, QuoteModel quote) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote,
                color: const Color(0xFF8B5CF6),
                size: 24,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  // Toggle favorite
                },
                icon: Icon(
                  quote.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: quote.isFavorite ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quote.text,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1E293B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '— ${quote.author}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingQuoteCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildRecentQuotesSection(BuildContext context) {
    final quoteProvider = Provider.of<QuoteProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Inspiration',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        if (quoteProvider.quotes.isNotEmpty)
          ...quoteProvider.quotes
              .take(2)
              .map(
                (quote) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: _buildCompactQuoteCard(context, quote),
                ),
              )
        else
          _buildLoadingQuotesCard(context),
      ],
    );
  }

  Widget _buildCompactQuoteCard(BuildContext context, QuoteModel quote) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quote.text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '— ${quote.author}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingQuotesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning! Ready to start your day?';
    } else if (hour < 17) {
      return 'Good afternoon! How\'s your day going?';
    } else {
      return 'Good evening! Time to reflect on today.';
    }
  }
}
