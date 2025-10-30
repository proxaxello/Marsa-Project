import 'package:flutter/material.dart';
import 'package:marsa_app/data/models/folder_model.dart';
import 'package:marsa_app/presentation/theme/neo_brutal_theme.dart';
import 'package:marsa_app/presentation/screens/games/multiple_choice_screen.dart';

class GameSelectionScreen extends StatelessWidget {
  final FolderModel folder;

  const GameSelectionScreen({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    final games = [
      {
        'name': 'MULTIPLE CHOICE',
        'description': 'Test your knowledge with quiz questions',
        'icon': Icons.check_circle,
        'color': NeoBrutalTheme.electricYellow,
        'rotation': -0.02,
      },
      {
        'name': 'FLASHCARDS',
        'description': 'Flip cards to learn and memorize',
        'icon': Icons.layers,
        'color': NeoBrutalTheme.hotPink,
        'rotation': 0.01,
      },
      {
        'name': 'MATCHING',
        'description': 'Connect English words with Vietnamese',
        'icon': Icons.grid_3x3,
        'color': NeoBrutalTheme.cyanBlue,
        'rotation': -0.01,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: NeoBrutalTheme.electricYellow,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          folder.name.toUpperCase(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.black,
            height: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                _buildHeroSection(),
                const SizedBox(height: 24),

                // Game Cards
                _buildGameCards(context, games),
                const SizedBox(height: 24),

                // Tips Section
                _buildTipsSection(),
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
          color: NeoBrutalTheme.neonGreen,
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
            const Text(
              'CHOOSE GAME',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${folder.wordCount} words ready to practice',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCards(BuildContext context, List<Map<String, dynamic>> games) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        childAspectRatio: 2.0,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return _buildGameCard(
          context: context,
          name: game['name'] as String,
          description: game['description'] as String,
          icon: game['icon'] as IconData,
          color: game['color'] as Color,
          rotation: game['rotation'] as double,
        );
      },
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String name,
    required String description,
    required IconData icon,
    required Color color,
    required double rotation,
  }) {
    return Transform.rotate(
      angle: rotation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to game screen based on game name
            if (name == 'MULTIPLE CHOICE') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultipleChoiceScreen(folder: folder),
                ),
              );
            } else {
              // TODO: Implement other games
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$name coming soon!'),
                  backgroundColor: Colors.black,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(24),
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
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

  Widget _buildTipsSection() {
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
              'GAME TIPS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildTipItem(
              icon: Icons.check_circle,
              title: 'MULTIPLE CHOICE',
              description: 'Best for testing your vocabulary knowledge',
              color: NeoBrutalTheme.electricYellow,
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              icon: Icons.layers,
              title: 'FLASHCARDS',
              description: 'Great for memorizing new words quickly',
              color: NeoBrutalTheme.hotPink,
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              icon: Icons.grid_3x3,
              title: 'MATCHING',
              description: 'Perfect for connecting words with meanings',
              color: NeoBrutalTheme.cyanBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: Icon(
            icon,
            size: 24,
            color: Colors.black,
          ),
        ),
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
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
