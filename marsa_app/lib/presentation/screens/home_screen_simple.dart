import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marsa_app/presentation/widgets/integrated_search_widget.dart';
import 'package:marsa_app/config/app_theme.dart';
import 'package:marsa_app/config/theme_colors.dart';

/// Simple Clean Home Screen - Light Mode
/// Colors: Orange #f64a00, Blue #1800ad, Green #57d9b2, Light Mode Text #12100E
class HomeScreenSimple extends StatefulWidget {
  const HomeScreenSimple({super.key});

  @override
  State<HomeScreenSimple> createState() => _HomeScreenSimpleState();
}

class _HomeScreenSimpleState extends State<HomeScreenSimple> {
  List<bool> _weekStreak = [false, true, false, false, false, false, false];
  int _todayWordCount = 5;
  int _yesterdayWordCount = 10;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load week streak from SharedPreferences
      final today = DateTime.now();
      final weekStreak = <bool>[];
      for (int i = 0; i < 7; i++) {
        final date = today.subtract(Duration(days: 6 - i));
        final dateStr = date.toIso8601String().split('T')[0];
        final searched = prefs.getBool('searched_$dateStr') ?? false;
        weekStreak.add(searched);
      }

      // Load today's word count
      final todayStr = today.toIso8601String().split('T')[0];
      final todayCount = prefs.getInt('word_count_$todayStr') ?? 0;

      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayStr = yesterday.toIso8601String().split('T')[0];
      final yesterdayCount = prefs.getInt('word_count_$yesterdayStr') ?? 0;

      if (mounted) {
        setState(() {
          _weekStreak = weekStreak;
          _todayWordCount = todayCount;
          _yesterdayWordCount = yesterdayCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int _getStreakCount() {
    int count = 0;
    for (int i = _weekStreak.length - 1; i >= 0; i--) {
      if (_weekStreak[i]) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(
            color: ThemeColors.getPrimary(context),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkBackgroundGradient : null,
          color: isDark ? null : theme.scaffoldBackgroundColor,
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
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
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: ThemeColors.getAccent(context),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'A',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Settings icon on the right
                        IconButton(
                          onPressed: () {
                            // TODO: Navigate to settings
                            print('[NAV] Settings button tapped');
                          },
                          icon: Icon(
                            Icons.settings,
                            color: isDark
                                ? Colors.white.withOpacity(0.8)
                                : const Color(0xFF12100E),
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar (scrolls with content)
                  const IntegratedSearchWidget(),
                  const SizedBox(height: 24),

                  // Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkCardBackground
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        width: 2,
                        color: isDark
                            ? Colors.transparent
                            : ThemeColors.getPrimary(context),
                      ),
                      gradient: isDark
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.gradientOrange.withOpacity(0.3),
                                AppTheme.gradientLightBlue.withOpacity(0.3),
                              ],
                            )
                          : null,
                    ),
                    child: Text(
                      'Banner thông báo & marketing cho apps',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF12100E),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Jump back in
                  Text(
                    'Jump back in',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF12100E),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // IELTS Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkCardBackground
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        width: 1.5,
                        color: isDark
                            ? Colors.transparent
                            : Colors.grey.shade200,
                      ),
                      gradient: isDark
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.gradientLightBlue.withOpacity(0.3),
                                AppTheme.gradientOrange.withOpacity(0.3),
                              ],
                            )
                          : null,
                      boxShadow: isDark
                          ? null
                          : [
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'IELTS',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF12100E),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.more_vert,
                              color: isDark
                                  ? Colors.white.withOpacity(0.6)
                                  : Colors.grey.shade400,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 0.5,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE8E8E8),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF8946),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFF9bcfff),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '4/80 Từ vựng đã học thuộc',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFCCCCCC)
                                    : const Color(0xFF12100E),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF8946),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '5/80 Từ vựng chưa học thuộc',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFCCCCCC)
                                    : const Color(0xFF12100E),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Continue button
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9bcfff),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              'TIẾP TỤC',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Cá nhân section
                  Text(
                    'Cá nhân',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF12100E),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Study time card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x38FFFFFF) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.3)
                            : Colors.grey.shade200,
                        width: 1,
                      ),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TRA TỪ ĐỂ GIỮ CHUỖI',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF12100E),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Fire icon in top-right
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFF8946,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    color: Color(0xFFFF8946),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_getStreakCount()}',
                                    style: const TextStyle(
                                      color: Color(0xFFFF8946),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              '48 Hour',
                              style: TextStyle(
                                color: Color(0xFF9bcfff),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Số giờ bạn đã học trong tuần này',
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFFCCCCCC)
                                      : const Color(0xFF12100E),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              '140 Min',
                              style: TextStyle(
                                color: Color(0xFFFF8946),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Số phút bạn đã học trong hôm nay',
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFFCCCCCC)
                                      : const Color(0xFF12100E),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Week days row at bottom
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDayCircle('Mon', _weekStreak[0], isDark),
                            _buildDayCircle('Tue', _weekStreak[1], isDark),
                            _buildDayCircle('Wed', _weekStreak[2], isDark),
                            _buildDayCircle('Thu', _weekStreak[3], isDark),
                            _buildDayCircle('Fri', _weekStreak[4], isDark),
                            _buildDayCircle('Sat', _weekStreak[5], isDark),
                            _buildDayCircle('Sun', _weekStreak[6], isDark),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Hôm nay đã tra section
                  Text(
                    'Hôm nay đã tra',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF12100E),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Today's lookup card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x38FFFFFF) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.3)
                            : Colors.grey.shade200,
                        width: 1,
                      ),
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              '$_todayWordCount Từ',
                              style: const TextStyle(
                                color: Color(0xFF9bcfff),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Số từ đã tra hôm nay',
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFFCCCCCC)
                                      : const Color(0xFF12100E),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_yesterdayWordCount > 0) ...[
                          Text(
                            _todayWordCount > _yesterdayWordCount
                                ? '+${((_todayWordCount - _yesterdayWordCount) / _yesterdayWordCount * 100).toStringAsFixed(0)}%'
                                : '${((_todayWordCount - _yesterdayWordCount) / _yesterdayWordCount * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: _todayWordCount > _yesterdayWordCount
                                  ? const Color(0xFF57d9b2)
                                  : const Color(0xFFf64a00),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'So với hôm qua',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFCCCCCC)
                                  : const Color(0xFF12100E),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Leaderboard
                  Text(
                    'Bảng xếp hạng',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF12100E),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x38FFFFFF) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.3)
                            : Colors.grey.shade200,
                        width: 1,
                      ),
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
                        _buildLeaderboardItem(
                          1,
                          'Nguyễn Văn A',
                          const Color(0xFFf64a00),
                          isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildLeaderboardItem(
                          2,
                          'Phi Nam',
                          const Color(0xFF1800ad),
                          isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildLeaderboardItem(
                          3,
                          'Vũ Tuyết',
                          const Color(0xFF1800ad),
                          isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Góp ý (Feedback) section
                  Text(
                    'Góp ý',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF12100E),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Horizontal scrollable feedback cards
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFeedbackCard(
                          'Ứng thấy giao diện khá đẹp, tuy nhiên mình muốn custom thêm',
                          'User',
                          isDark,
                        ),
                        const SizedBox(width: 16),
                        _buildFeedbackCard(
                          'App thần thiện, chế độ chơi cũng lạ',
                          'User',
                          isDark,
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Add feedback button
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: ThemeColors.getAccent(context),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Thêm góp ý cho Marsa',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF12100E),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCircle(String day, bool isActive, bool isDark) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1800ad) : const Color(0xFFD0D0D0),
            shape: BoxShape.circle,
          ),
          child: isActive
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: TextStyle(
            color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF12100E),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(String text, String userName, bool isDark) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x38FFFFFF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.3) : Colors.grey.shade200,
          width: 1,
        ),
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
          const Icon(Icons.format_quote, color: Color(0xFF1800ad), size: 32),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF12100E),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF1800ad),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'like button',
                  style: TextStyle(color: Color(0xFF57d9b2), fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Dislike button',
                  style: TextStyle(color: Color(0xFFf64a00), fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(
    int rank,
    String name,
    Color color,
    bool isDark,
  ) {
    return Row(
      children: [
        Text(
          '$rank',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF12100E),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const Center(
            child: Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
