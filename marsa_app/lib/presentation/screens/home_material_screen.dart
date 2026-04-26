import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/logic/blocs/word/word_bloc.dart';
import 'package:marsa_app/logic/blocs/word/word_event.dart';
import 'package:marsa_app/logic/blocs/word/word_state.dart';
import 'package:marsa_app/presentation/widgets/integrated_search_widget.dart';

class HomeMaterialScreen extends StatefulWidget {
  const HomeMaterialScreen({super.key});

  @override
  State<HomeMaterialScreen> createState() => _HomeMaterialScreenState();
}

class _HomeMaterialScreenState extends State<HomeMaterialScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();

    // Load words to get statistics
    context.read<WordBloc>().add(const LoadAllWords());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar (left) and Settings (right)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Avatar on the left
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.orange,
                        child: const Text(
                          'A',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Settings icon on the right
                      IconButton(
                        icon: const Icon(Icons.settings),
                        iconSize: 28,
                        onPressed: () {
                          DefaultTabController.of(context).animateTo(3);
                        },
                      ),
                    ],
                  ),
                ),

                // Search Bar
                const IntegratedSearchWidget(),
                const SizedBox(height: 16),

                // 1. Welcome Block
                _buildWelcomeCard(),
                const SizedBox(height: 16),

                // 2. Stats Grid (2x2)
                _buildStatsGrid(),
                const SizedBox(height: 24),

                // 3. Quick Access
                _buildQuickAccessSection(),
                const SizedBox(height: 24),

                // 4. AI Recommendations
                _buildAIRecommendationsSection(),
                const SizedBox(height: 24),

                // 5. Daily Goal
                _buildDailyGoalCard(),
                const SizedBox(height: 24),

                // 6. Footer Card
                _buildFooterCard(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return FadeTransition(
      opacity: _animationController,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF59D), // Yellow 200
                Color(0xFFF48FB1), // Pink 200
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WELCOME BACK!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Duong Nguyen Van',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return BlocBuilder<WordBloc, WordState>(
      builder: (context, state) {
        final wordCount = state is WordLoaded ? state.words.length : 0;

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            // Ô 1: DAY STREAK
            _buildStatCard(
              icon: Icons.local_fire_department,
              label: 'DAY STREAK',
              value: '0',
              subtitle: 'days in a row',
              color: Colors.orange[300]!,
              iconColor: Colors.deepOrange,
            ),
            // Ô 2: XP TODAY
            _buildStatCard(
              icon: Icons.bolt,
              label: 'XP TODAY',
              value: '0',
              subtitle: 'XP earned',
              color: Colors.cyan[300]!,
              iconColor: Colors.blue,
            ),
            // Ô 3: WORDS
            _buildStatCard(
              icon: Icons.book,
              label: 'WORDS',
              value: '$wordCount',
              subtitle: 'learned',
              color: Colors.blue[300]!,
              iconColor: Colors.indigo,
            ),
            // Ô 4: LEVEL
            _buildStatCard(
              icon: Icons.stars,
              label: 'LEVEL',
              value: '1',
              subtitle: '0 XP total',
              color: Colors.green[300]!,
              iconColor: Colors.green[700]!,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    required Color iconColor,
  }) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            ),
          ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 24, color: iconColor),
                  const SizedBox(width: 8),
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'QUICK ACCESS',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Card 1: DICTIONARY
        _buildQuickActionCard(
          title: 'DICTIONARY',
          subtitle: 'Search & add new words',
          icon: Icons.book,
          color: Colors.blue[400]!,
          onTap: () {
            DefaultTabController.of(context).animateTo(1);
          },
        ),
        const SizedBox(height: 12),

        // Card 2: FLASHCARDS
        _buildQuickActionCard(
          title: 'FLASHCARDS',
          subtitle: 'Review 0 cards',
          icon: Icons.layers,
          color: Colors.pink[400]!,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Flashcards coming soon!')),
            );
          },
        ),
        const SizedBox(height: 12),

        // Card 3: PRACTICE
        _buildQuickActionCard(
          title: 'PRACTICE',
          subtitle: 'Games & exercises',
          icon: Icons.gamepad,
          color: Colors.green[400]!,
          onTap: () {
            DefaultTabController.of(context).animateTo(2);
          },
        ),
        const SizedBox(height: 12),

        // Card 4: PRONUNCIATION
        _buildQuickActionCard(
          title: 'PRONUNCIATION',
          subtitle: 'AI speech practice',
          icon: Icons.mic,
          color: Colors.purple[400]!,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pronunciation coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Transform.rotate(
                  angle: -0.05,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 28, color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIRecommendationsSection() {
    return BlocBuilder<WordBloc, WordState>(
      builder: (context, state) {
        final favoriteCount = state is WordLoaded
            ? state.words.where((w) => w.isFavorite).length
            : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'AI RECOMMENDATIONS',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Card 1: YOUR FAVORITES
            _buildRecommendationCard(
              icon: Icons.star,
              title: 'YOUR FAVORITES',
              subtitle: '$favoriteCount words saved for quick access',
              color: Colors.amber[300]!,
              onTap: () {
                context.read<WordBloc>().add(
                  const LoadAllWords(isFavorite: true),
                );
                DefaultTabController.of(context).animateTo(1);
              },
            ),
            const SizedBox(height: 12),

            // Card 2: BUILD YOUR VOCABULARY
            _buildRecommendationCard(
              icon: Icons.library_books,
              title: 'BUILD YOUR VOCABULARY',
              subtitle: 'Add more words to unlock advanced features',
              color: Colors.green[300]!,
              onTap: () {
                DefaultTabController.of(context).animateTo(1);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendationItem({
    required String emoji,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, size: 28, color: Colors.black87),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyGoalCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DAILY GOAL',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'XP GOAL: 50',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '0/50',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.0,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '50 XP left to reach your daily goal!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[100]!, Colors.purple[100]!],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'LEARN • PRACTICE • MASTER',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'English ↔ Vietnamese Dictionary',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSummary() {
    return BlocBuilder<WordBloc, WordState>(
      builder: (context, state) {
        final wordCount = state is WordLoaded ? state.words.length : 0;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.yellow[200],
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR PROGRESS',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildProgressItem(
                        label: 'Words Learned',
                        value: '$wordCount',
                      ),
                    ),
                    Expanded(
                      child: _buildProgressItem(
                        label: 'Reviews Done',
                        value: '0',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildProgressItem(
                        label: 'Longest Streak',
                        value: '0 🔥',
                      ),
                    ),
                    Expanded(
                      child: _buildProgressItem(
                        label: 'Practice Sessions',
                        value: '0',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
