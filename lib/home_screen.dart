import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'game_page.dart';
import 'models.dart';
import 'settings_page.dart';
import 'stats_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeTab(),
      const _DailyChallengesTab(),
      const StatsTab(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: pages,
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        index: _index,
        onChanged: (value) => setState(() => _index = value),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _BottomNavBar({
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      onTap: onChanged,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Головна',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_rounded),
          label: 'Щоденний виклик',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_rounded),
          label: 'Статистика',
        ),
      ],
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final theme = Theme.of(context);
    final difficulty = app.featuredStatsDifficulty;
    final stats = app.statsFor(difficulty);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(
            onSettingsTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
          const SizedBox(height: 24),
          _ChallengeCarousel(
            battleWinRate: app.battleWinRate,
            championshipScore: app.championshipScore,
          ),
          const SizedBox(height: 32),
          Text(
            'Судоку Майстер',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          _DailyChain(streak: app.dailyStreak),
          const SizedBox(height: 18),
          _ProgressCard(
            difficulty: difficulty,
            stats: stats,
            onNewGame: () => _openDifficultySheet(context),
            heartBonus: app.heartBonus,
          ),
        ],
      ),
    );
  }

  Future<void> _openDifficultySheet(BuildContext context) async {
    final app = context.read<AppState>();
    final difficulty = await showModalBottomSheet<Difficulty>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        final items = Difficulty.values;
        final selected = app.featuredStatsDifficulty;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7DBEB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Виберіть складність',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Щоденний виклик',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF79819C),
                      ),
                ),
              ),
              const SizedBox(height: 8),
              _DifficultyTile(
                title: 'Щоденне виклик',
                rankLabel: 'Ранг 1',
                progress: '—',
                isActive: false,
                onTap: () => Navigator.pop(context, Difficulty.beginner),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 320,
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final diff = items[index];
                    final stats = app.statsFor(diff);
                    return _DifficultyTile(
                      title: diff.title,
                      rankLabel: 'Ранг ${stats.rank}',
                      progress: stats.progressText,
                      isActive: diff == selected,
                      onTap: () => Navigator.pop(context, diff),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!context.mounted || difficulty == null) return;

    app.startGame(difficulty);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GamePage()),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const _TopBar({required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF4B5CF5), Color(0xFF6D7AFF)],
            ),
          ),
          child: const Icon(Icons.person_outline, color: Colors.white),
        ),
        Row(
          children: [
            _CircleButton(
              icon: Icons.emoji_events_outlined,
              onTap: () {},
            ),
            const SizedBox(width: 12),
            _CircleButton(
              icon: Icons.leaderboard_outlined,
              onTap: () {},
            ),
            const SizedBox(width: 12),
            _CircleButton(
              icon: Icons.settings_outlined,
              onTap: onSettingsTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A1B1D3A),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF4B5CF5)),
      ),
    );
  }
}

class _ChallengeCarousel extends StatelessWidget {
  final int battleWinRate;
  final int championshipScore;

  const _ChallengeCarousel({
    required this.battleWinRate,
    required this.championshipScore,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('d MMMM', 'uk');
    final today = formatter.format(DateTime.now());

    final cards = [
      _ChallengeCardData(
        title: 'Щоденне виклик',
        subtitle: today,
        buttonLabel: 'Грати',
        gradient: const [Color(0xFFFFF0B3), Color(0xFFFFC26F)],
        icon: Icons.emoji_events,
        onPressed: () {},
      ),
      _ChallengeCardData(
        title: 'Чемпіонат',
        subtitle: 'Рахунок $championshipScore',
        buttonLabel: 'Грати',
        gradient: const [Color(0xFFFFB2D0), Color(0xFFE55D87)],
        icon: Icons.workspace_premium_outlined,
        onPressed: () {},
        badge: '2G',
      ),
      _ChallengeCardData(
        title: 'Битва',
        subtitle: 'Win Rate ${battleWinRate}%',
        buttonLabel: 'Почати',
        gradient: const [Color(0xFFB1C6FF), Color(0xFF5A7CFF)],
        icon: Icons.sports_esports_outlined,
        onPressed: () {},
      ),
    ];

    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 24),
        itemBuilder: (context, index) => _ChallengeCard(data: cards[index]),
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemCount: cards.length,
      ),
    );
  }
}

class _ChallengeCardData {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback onPressed;
  final String? badge;

  const _ChallengeCardData({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.gradient,
    required this.icon,
    required this.onPressed,
    this.badge,
  });
}

class _ChallengeCard extends StatelessWidget {
  final _ChallengeCardData data;

  const _ChallengeCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: data.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  data.icon,
                  color: data.gradient.last,
                  size: 22,
                ),
              ),
              const Spacer(),
              if (data.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    data.badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            data.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: data.gradient.last,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              onPressed: data.onPressed,
              child: Text(
                data.buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _DailyChain extends StatelessWidget {
  final int streak;

  const _DailyChain({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141B1D3A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Color(0xFFFF713B)),
          const SizedBox(width: 8),
          Text(
            'Ланцюг днів',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE2D5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              streak.toString(),
              style: const TextStyle(
                color: Color(0xFFFD6E44),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final Difficulty difficulty;
  final DifficultyStats stats;
  final VoidCallback onNewGame;
  final int heartBonus;

  const _ProgressCard({
    required this.difficulty,
    required this.stats,
    required this.onNewGame,
    required this.heartBonus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141B1D3A),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Рівень ${stats.level} — ${difficulty.title}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${stats.bestTimeText} — ${difficulty.title}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6D7392),
                      ),
                    ),
                  ],
                ),
              ),
              _HeartBonusChip(amount: heartBonus),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Прогрес рангу',
            style: theme.textTheme.labelLarge?.copyWith(
              color: const Color(0xFF8187A5),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: stats.progressTarget == 0
                  ? 0
                  : stats.progressCurrent / stats.progressTarget,
              backgroundColor: const Color(0xFFE8EBFB),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF4B5CF5)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ранг ${stats.rank}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                stats.progressText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6D7392),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNewGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B5CF5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Нова гра',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartBonusChip extends StatelessWidget {
  final int amount;

  const _HeartBonusChip({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEF0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, color: Color(0xFFE25562), size: 18),
          const SizedBox(width: 6),
          Text(
            '+$amount',
            style: const TextStyle(
              color: Color(0xFFE25562),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final String title;
  final String rankLabel;
  final String progress;
  final bool isActive;
  final VoidCallback onTap;

  const _DifficultyTile({
    required this.title,
    required this.rankLabel,
    required this.progress,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = isActive ? const Color(0xFFFFEEF0) : Colors.white;
    final borderColor = isActive ? const Color(0xFFE86C82) : const Color(0xFFE2E5F3);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? const Color(0xFFE25562)
                          : const Color(0xFF1F2437),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rankLabel,
                    style: const TextStyle(
                      color: Color(0xFF7A81A0),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              progress,
              style: const TextStyle(
                color: Color(0xFF7A81A0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _DailyChallengesTab extends StatelessWidget {
  const _DailyChallengesTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    final formatter = DateFormat('E', 'uk');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Щоденний виклик',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _DailyHeroCard(
            dateLabel: DateFormat('d MMMM', 'uk').format(today),
          ),
          const SizedBox(height: 28),
          Text(
            'Тижневий прогрес',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final date in days)
                _DayProgress(
                  label: formatter.format(date),
                  day: date.day,
                  isToday: date.day == today.day,
                  completed: date.isBefore(today),
                ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Нагороди',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const _RewardTile(
            icon: Icons.favorite_outline,
            title: 'Завершіть виклик без помилок',
            reward: '+1 серце',
          ),
          const SizedBox(height: 12),
          const _RewardTile(
            icon: Icons.emoji_events_outlined,
            title: 'Закінчіть три виклики поспіль',
            reward: 'Унікальний трофей',
          ),
          const SizedBox(height: 12),
          const _RewardTile(
            icon: Icons.local_fire_department_outlined,
            title: 'Підтримуйте серію 7 днів',
            reward: '+50 зірок',
          ),
        ],
      ),
    );
  }
}

class _DailyHeroCard extends StatelessWidget {
  final String dateLabel;

  const _DailyHeroCard({required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9AD3FF), Color(0xFF4E8BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              dateLabel,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Сьогоднішня головоломка',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Завершіть судоку, щоб зібрати додаткову нагороду та продовжити серію.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 160,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4E8BFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Продовжити',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayProgress extends StatelessWidget {
  final String label;
  final int day;
  final bool isToday;
  final bool completed;

  const _DayProgress({
    required this.label,
    required this.day,
    required this.isToday,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final color = isToday
        ? const Color(0xFF4B5CF5)
        : completed
            ? const Color(0xFF6ACB8A)
            : const Color(0xFFB0B7D3);

    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF7B83A6),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            day.toString(),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _RewardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String reward;

  const _RewardTile({
    required this.icon,
    required this.title,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1B1D3A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EBFB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF4B5CF5)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2437),
              ),
            ),
          ),
          Text(
            reward,
            style: const TextStyle(
              color: Color(0xFF4B5CF5),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
