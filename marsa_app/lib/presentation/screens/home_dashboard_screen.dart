import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/logic/blocs/word/word_bloc.dart';
import 'package:marsa_app/logic/blocs/word/word_event.dart';
import 'package:marsa_app/logic/blocs/word/word_state.dart';
import 'package:marsa_app/presentation/theme/neo_brutal_theme.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load words to get statistics
    context.read<WordBloc>().add(const LoadAllWords());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero / Welcome Section
                _buildHeroSection(),
                const SizedBox(height: 24),

                // Progress Stats
                _buildProgressStats(),
                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActions(),
                const SizedBox(height: 24),

                // AI Recommendations
                _buildAIRecommendations(),
                const SizedBox(height: 24),

                // Daily Goal
                _buildDailyGoal(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Transform.rotate(
      angle: 0.02,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: NeoBrutalTheme.hotPink,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(8, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WELCOME BACK!',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Learner',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStats() {
    return BlocBuilder<WordBloc, WordState>(
      builder: (context, state) {
        final wordCount = state is WordLoaded ? state.words.length : 0;
        final favoriteCount = state is WordLoaded 
            ? state.words.where((w) => w.isFavorite).length 
            : 0;

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              icon: Icons.local_fire_department,
              value: '0',
              label: 'DAY STREAK',
              color: Colors.white,
              iconColor: NeoBrutalTheme.hotPink,
            ),
            _buildStatCard(
              icon: Icons.bolt,
              value: '0',
              label: 'XP TODAY',
              color: NeoBrutalTheme.electricYellow,
              iconColor: Colors.black,
            ),
            _buildStatCard(
              icon: Icons.book,
              value: '$wordCount',
              label: 'WORDS',
              color: NeoBrutalTheme.cyanBlue,
              iconColor: Colors.black,
            ),
            _buildStatCard(
              icon: Icons.star,
              value: '$favoriteCount',
              label: 'FAVORITES',
              color: NeoBrutalTheme.neonGreen,
              iconColor: Colors.black,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.black, width: 4),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'QUICK ACCESS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildQuickActionCard(
              title: 'DICTIONARY',
              description: 'Search & add words',
              icon: Icons.book,
              color: NeoBrutalTheme.electricYellow,
              rotation: -0.01,
              onTap: () {
                // Navigate to Dictionary (already on tab 1)
                DefaultTabController.of(context).animateTo(1);
              },
            ),
            _buildQuickActionCard(
              title: 'PRACTICE',
              description: 'Games & exercises',
              icon: Icons.gamepad,
              color: NeoBrutalTheme.cyanBlue,
              rotation: 0.01,
              badge: null,
              onTap: () {
                // Navigate to Practice (tab 2)
                DefaultTabController.of(context).animateTo(2);
              },
            ),
            _buildQuickActionCard(
              title: 'FLASHCARDS',
              description: 'Review 5 cards',
              icon: Icons.layers,
              color: NeoBrutalTheme.hotPink,
              rotation: -0.01,
              badge: '5',
              onTap: () {
                // TODO: Navigate to Flashcards
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Flashcards coming soon!')),
                );
              },
            ),
            _buildQuickActionCard(
              title: 'VOICE LAB',
              description: 'AI speech practice',
              icon: Icons.mic,
              color: NeoBrutalTheme.neonGreen,
              rotation: 0.01,
              onTap: () {
                // TODO: Navigate to Voice Lab
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voice Lab coming soon!')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required double rotation,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Transform.rotate(
      angle: rotation,
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.black, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      offset: const Offset(6, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, size: 40, color: Colors.black),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (badge != null)
            Positioned(
              top: -12,
              right: -12,
              child: Transform.rotate(
                angle: 0.12,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: Center(
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFE500),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: NeoBrutalTheme.hotPink,
                border: Border.all(color: Colors.black, width: 4),
              ),
              child: const Icon(Icons.psychology, size: 28, color: Colors.black),
            ),
            const SizedBox(width: 12),
            const Text(
              'AI RECOMMENDATIONS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildRecommendationCard(
          emoji: '⏰',
          title: 'REVIEW DUE TODAY',
          description: 'You have 5 flashcards ready for review',
          color: NeoBrutalTheme.electricYellow,
          rotation: -0.01,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Flashcards coming soon!')),
            );
          },
        ),
        const SizedBox(height: 12),
        BlocBuilder<WordBloc, WordState>(
          builder: (context, state) {
            final favoriteCount = state is WordLoaded 
                ? state.words.where((w) => w.isFavorite).length 
                : 0;
            
            if (favoriteCount > 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRecommendationCard(
                  emoji: '⭐',
                  title: 'YOUR FAVORITES',
                  description: '$favoriteCount words saved for quick access',
                  color: NeoBrutalTheme.cyanBlue,
                  rotation: 0.01,
                  onTap: () {
                    context.read<WordBloc>().add(const LoadAllWords(isFavorite: true));
                    DefaultTabController.of(context).animateTo(1);
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        BlocBuilder<WordBloc, WordState>(
          builder: (context, state) {
            final wordCount = state is WordLoaded ? state.words.length : 0;
            
            if (wordCount < 10) {
              return _buildRecommendationCard(
                emoji: '📚',
                title: 'BUILD YOUR VOCABULARY',
                description: 'Add more words to unlock advanced features',
                color: NeoBrutalTheme.neonGreen,
                rotation: -0.01,
                onTap: () {
                  DefaultTabController.of(context).animateTo(1);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildRecommendationCard({
    required String emoji,
    required String title,
    required String description,
    required Color color,
    required double rotation,
    required VoidCallback onTap,
  }) {
    return Transform.rotate(
      angle: rotation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  offset: const Offset(6, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$emoji $title',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 32,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyGoal() {
    return Transform.rotate(
      angle: -0.01,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(6, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DAILY GOAL',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'XP GOAL: 50',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '0/50',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                border: Border.all(color: Colors.black, width: 4),
              ),
              child: Stack(
                children: [
                  Container(
                    width: 0, // 0% progress
                    decoration: BoxDecoration(
                      color: NeoBrutalTheme.neonGreen,
                      border: Border(
                        right: BorderSide(color: Colors.black, width: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '50 XP left to reach your daily goal!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
