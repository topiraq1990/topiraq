import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const TopIraqApp());
}

class TopIraqApp extends StatefulWidget {
  const TopIraqApp({super.key});

  @override
  State<TopIraqApp> createState() => _TopIraqAppState();
}

class _TopIraqAppState extends State<TopIraqApp> {
  int _balance = 12480;
  int _xp = 8540;
  List<DailyTask> _dailyTasks = const [
    DailyTask(
      id: 'daily_room',
      title: 'زيارة الغرفة العامة',
      subtitle: 'كن متصلًا في غرفة اجتماعية لمدة 10 دقائق.',
      xpReward: 120,
      coinReward: 80,
      goal: 1,
      progress: 1,
      icon: Icons.headset_mic_rounded,
      accent: Color(0xFFF29CB0),
    ),
    DailyTask(
      id: 'daily_gifts',
      title: 'إرسال هدية',
      subtitle: 'شارك هدية مع مستخدم داخل الغرفة.',
      xpReward: 180,
      coinReward: 100,
      goal: 2,
      progress: 1,
      icon: Icons.card_giftcard_rounded,
      accent: Color(0xFFD9A65F),
    ),
    DailyTask(
      id: 'daily_vip',
      title: 'فتح جولة VIP',
      subtitle: 'استكمل مهمة VIP وتجربة المستوى اليومي.',
      xpReward: 240,
      coinReward: 140,
      goal: 1,
      progress: 0,
      icon: Icons.workspace_premium_rounded,
      accent: Color(0xFF9ECDB4),
    ),
  ];

  void _completeTask(String taskId) {
    setState(() {
      _dailyTasks = _dailyTasks.map((task) {
        if (task.id != taskId) return task;
        if (task.isCompleted) return task;
        final nextProgress = task.progress + 1;
        final isCompleted = nextProgress >= task.goal;
        if (isCompleted) {
          _xp += task.xpReward;
          _balance += task.coinReward;
        }
        return task.copyWith(
          progress: isCompleted ? task.goal : nextProgress,
          isCompleted: isCompleted,
        );
      }).toList();
    });
  }

  void _applyWalletChange(int newBalance) {
    setState(() {
      _balance = newBalance;
    });
  }

  int get currentVipLevel => VipLevelResolver.levelFromXp(_xp);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Top Iraq',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E3D4C),
          brightness: Brightness.light,
          primary: const Color(0xFF0F3C4C),
          secondary: const Color(0xFF256D9D),
          surface: const Color(0xFFF4F9FB),
        ),
        scaffoldBackgroundColor: const Color(0xFFEAF4F7),
        useMaterial3: true,
        textTheme: ThemeData.light()
            .textTheme
            .apply(
              bodyColor: const Color(0xFF1B2E38),
              displayColor: const Color(0xFF1B2E38),
            )
            .copyWith(
              headlineLarge: const TextStyle(fontWeight: FontWeight.w900),
              headlineMedium: const TextStyle(fontWeight: FontWeight.w800),
              titleLarge: const TextStyle(fontWeight: FontWeight.w800),
              titleMedium: const TextStyle(fontWeight: FontWeight.w700),
              bodyLarge: const TextStyle(fontWeight: FontWeight.w700),
              bodyMedium: const TextStyle(fontWeight: FontWeight.w700),
              labelLarge: const TextStyle(fontWeight: FontWeight.w800),
            ),
      ),
      home: HomeScreen(
        balance: _balance,
        xp: _xp,
        vipLevel: currentVipLevel,
        dailyTasks: _dailyTasks,
        onTaskCompleted: _completeTask,
        onBalanceChanged: _applyWalletChange,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.balance,
    required this.xp,
    required this.vipLevel,
    required this.dailyTasks,
    required this.onTaskCompleted,
    required this.onBalanceChanged,
  });

  final int balance;
  final int xp;
  final int vipLevel;
  final List<DailyTask> dailyTasks;
  final ValueChanged<String> onTaskCompleted;
  final ValueChanged<int> onBalanceChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;
  String _username = 'ضيف';

  void _handleLogin(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }

    setState(() {
      _username = trimmed;
      _isLoggedIn = true;
      _currentIndex = 3;
    });
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _username = 'ضيف';
      _currentIndex = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeContent(
        balance: widget.balance,
        xp: widget.xp,
        vipLevel: widget.vipLevel,
        dailyTasks: widget.dailyTasks,
        onTaskCompleted: widget.onTaskCompleted,
        onBalanceChanged: widget.onBalanceChanged,
      ),
      const Center(child: Text('المحادثات')),
      const Center(child: Text('التحديات')),
      _isLoggedIn
          ? AccountScreen(
              username: _username,
              onLogout: _handleLogout,
              balance: widget.balance,
              xp: widget.xp,
              vipLevel: widget.vipLevel,
            )
          : LocalLoginScreen(onLogin: _handleLogin),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFEDE5DF),
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF5F1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 22,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (value) {
                setState(() {
                  _currentIndex = value;
                });
              },
              backgroundColor: const Color(0xFFFAF5F1),
              indicatorColor: const Color(0xFFE9C784),
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_rounded),
                  label: 'الرئيسية',
                ),
                NavigationDestination(
                  icon: Icon(Icons.headset_mic_rounded),
                  label: 'الصوت',
                ),
                NavigationDestination(
                  icon: Icon(Icons.emoji_events_rounded),
                  label: 'المهام',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_rounded),
                  label: 'حسابي',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LocalLoginScreen extends StatefulWidget {
  const LocalLoginScreen({super.key, required this.onLogin});

  final ValueChanged<String> onLogin;

  @override
  State<LocalLoginScreen> createState() => _LocalLoginScreenState();
}

class _LocalLoginScreenState extends State<LocalLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9F9),
        appBar: AppBar(
          title: const Text('تسجيل الدخول'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2D1F1F),
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEFDFB),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFD25D7D),
                              Color(0xFFC98B2E),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD25D7D)
                                  .withValues(alpha: 0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Center(
                      child: Text(
                        'مرحباً بك في Top Iraq',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D1F1F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'اسم المستخدم التجريبي',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5C4B4B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _usernameController,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: 'اكتب اسمك هنا',
                        hintStyle: const TextStyle(color: Color(0xFFB9A1A1)),
                        filled: true,
                        fillColor: const Color(0xFFFDF4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onLogin(_usernameController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFF29CB0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'دخول',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    required this.username,
    required this.onLogout,
    required this.balance,
    required this.xp,
    required this.vipLevel,
  });

  final String username;
  final VoidCallback onLogout;
  final int balance;
  final int xp;
  final int vipLevel;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9F9),
        appBar: AppBar(
          title: const Text('حسابي'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2D1F1F),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFFDE3ED),
                        Color(0xFFF8E7D0),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF29CB0),
                              Color(0xFFD9A65F),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 46,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D1F1F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          VipLevelResolver.labelForLevel(vipLevel),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB28752),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _AccountStatCard(
                        value: '$xp',
                        label: 'XP',
                        icon: Icons.trending_up_rounded,
                        color: const Color(0xFFFDE3ED),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AccountStatCard(
                        value: '$balance',
                        label: 'العملات',
                        icon: Icons.monetization_on_rounded,
                        color: const Color(0xFFF8E7D0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AccountStatCard(
                        value: VipLevelResolver.labelForLevel(vipLevel),
                        label: 'المستوى',
                        icon: Icons.workspace_premium_rounded,
                        color: const Color(0xFFF3E5B6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const _AccountActionTile(
                      icon: Icons.edit_note_rounded,
                      title: 'تعديل الملف',
                      subtitle: 'تحديث الصورة والبيانات الشخصية',
                      color: Color(0xFFF29CB0),
                    ),
                    const _AccountActionTile(
                      icon: Icons.settings_rounded,
                      title: 'الإعدادات',
                      subtitle: 'إعدادات التنبيهات والخصوصية',
                      color: Color(0xFFD9A65F),
                    ),
                    _AccountActionTile(
                      icon: Icons.logout_rounded,
                      title: 'تسجيل الخروج',
                      subtitle: 'الخروج من الحساب التجريبي',
                      color: const Color(0xFF9ECDB4),
                      onTap: onLogout,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountStatCard extends StatelessWidget {
  const _AccountStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF4C2D2D), size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D1F1F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7C5A5A),
            ),
          ),
        ],
      ),
    );
  }
}

class DailyTaskCard extends StatelessWidget {
  const DailyTaskCard({
    super.key,
    required this.task,
    required this.onComplete,
  });

  final DailyTask task;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final progressRatio = (task.progress / task.goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFDFB),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: task.accent.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: task.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(task.icon, color: task.accent, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D1F1F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B6F6F),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                task.isCompleted ? 'مكتملة' : '+${task.xpReward} XP',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: task.isCompleted
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFD9A65F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progressRatio,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFF8E7D0),
                    valueColor: AlwaysStoppedAnimation<Color>(task.accent),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${task.progress}/${task.goal}',
                style: const TextStyle(
                  color: Color(0xFF5C4B4B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: task.isCompleted ? null : onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: task.isCompleted
                    ? const Color(0xFF9ECDB4)
                    : const Color(0xFFF29CB0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                task.isCompleted ? 'مكتملة' : 'إكمال المهمة',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VipLevelResolver {
  static const List<VipLevelConfig> levels = [
    VipLevelConfig(
      name: 'VIP برونزي',
      requiredXp: 0,
      accent: Color(0xFFB9883F),
      description: 'مستوى تجريبي للمبتدئين.',
    ),
    VipLevelConfig(
      name: 'VIP فضي',
      requiredXp: 2500,
      accent: Color(0xFFD9A65F),
      description: 'مزايا فاخرة للمستخدم النشط.',
    ),
    VipLevelConfig(
      name: 'VIP ذهبي',
      requiredXp: 6000,
      accent: Color(0xFFE7C66B),
      description: 'مستوى ذهبية مع مكافآت متقدمة.',
    ),
    VipLevelConfig(
      name: 'VIP رُز گولد',
      requiredXp: 10000,
      accent: Color(0xFFF29CB0),
      description: 'مستوى فاخر للمستخدم الحصري.',
    ),
  ];

  static int levelFromXp(int xp) {
    int level = 0;
    for (final levelConfig in levels) {
      if (xp >= levelConfig.requiredXp) {
        level = levels.indexOf(levelConfig);
      }
    }
    return level;
  }

  static String labelForLevel(int level) {
    if (level < 0 || level >= levels.length) {
      return levels.last.name;
    }
    return levels[level].name;
  }

  static VipLevelConfig configForLevel(int level) {
    if (level < 0 || level >= levels.length) {
      return levels.last;
    }
    return levels[level];
  }
}

class VipLevelConfig {
  const VipLevelConfig({
    required this.name,
    required this.requiredXp,
    required this.accent,
    required this.description,
  });

  final String name;
  final int requiredXp;
  final Color accent;
  final String description;
}

class VipScreen extends StatelessWidget {
  const VipScreen({
    super.key,
    required this.xp,
    required this.balance,
    required this.vipLevel,
  });

  final int xp;
  final int balance;
  final int vipLevel;

  @override
  Widget build(BuildContext context) {
    final currentConfig = VipLevelResolver.configForLevel(vipLevel);
    final nextLevel = vipLevel + 1 < VipLevelResolver.levels.length
        ? VipLevelResolver.levels[vipLevel + 1]
        : null;
    final progress = nextLevel == null
        ? 1.0
        : ((xp - currentConfig.requiredXp) /
                (nextLevel.requiredXp - currentConfig.requiredXp))
            .clamp(0.0, 1.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9F9),
        appBar: AppBar(
          title: const Text('VIP'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2D1F1F),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFFDE3ED),
                        Color(0xFFF8E7D0),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'مستوى المستخدم الحالي',
                        style: TextStyle(
                          color: Color(0xFF7C5A5A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color:
                                  currentConfig.accent.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.workspace_premium_rounded,
                              color: currentConfig.accent,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentConfig.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2D1F1F),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentConfig.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF7C5A5A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'XP',
                        style: TextStyle(
                          color: Color(0xFF7C5A5A),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 12,
                                backgroundColor: const Color(0xFFF3E8DC),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  currentConfig.accent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$xp',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2D1F1F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        nextLevel == null
                            ? 'أنت وصلت إلى أعلى مستوى VIP تجريبي.'
                            : 'الانتقال إلى ${nextLevel.name} يحتاج ${nextLevel.requiredXp - xp} XP',
                        style: const TextStyle(
                          color: Color(0xFFB28752),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'المستويات',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D1F1F),
                  ),
                ),
                const SizedBox(height: 12),
                ...VipLevelResolver.levels.map(
                  (level) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            vipLevel == VipLevelResolver.levels.indexOf(level)
                                ? const Color(0xFFF29CB0)
                                : const Color(0xFFF2E7EA),
                        width:
                            vipLevel == VipLevelResolver.levels.indexOf(level)
                                ? 2
                                : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: level.accent.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.workspace_premium_rounded,
                            color: level.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2D1F1F),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                level.description,
                                style: const TextStyle(
                                  color: Color(0xFF7C5A5A),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${level.requiredXp} XP',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB28752),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'المهام اليومية',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D1F1F),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'الرصيد الحالي: $balance عملة محلية • XP الحالية: $xp',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7C5A5A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DailyTask {
  const DailyTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.xpReward,
    required this.coinReward,
    required this.goal,
    required this.progress,
    required this.icon,
    required this.accent,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final int xpReward;
  final int coinReward;
  final int goal;
  final int progress;
  final IconData icon;
  final Color accent;
  final bool isCompleted;

  DailyTask copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? xpReward,
    int? coinReward,
    int? goal,
    int? progress,
    IconData? icon,
    Color? accent,
    bool? isCompleted,
  }) {
    return DailyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      goal: goal ?? this.goal,
      progress: progress ?? this.progress,
      icon: icon ?? this.icon,
      accent: accent ?? this.accent,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class _AccountActionTile extends StatelessWidget {
  const _AccountActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D1F1F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8B6F6F),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xFF7C5A5A),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({
    super.key,
    required this.balance,
    required this.xp,
    required this.vipLevel,
    required this.dailyTasks,
    required this.onTaskCompleted,
    required this.onBalanceChanged,
  });

  final int balance;
  final int xp;
  final int vipLevel;
  final List<DailyTask> dailyTasks;
  final ValueChanged<String> onTaskCompleted;
  final ValueChanged<int> onBalanceChanged;

  @override
  Widget build(BuildContext context) {
    final categories = [
      const _CategoryItem(
        icon: Icons.headset_mic_rounded,
        label: 'الغرف الصوتية',
        color: Color(0xFFF9D7E2),
      ),
      const _CategoryItem(
        icon: Icons.videogame_asset_rounded,
        label: 'الألعاب',
        color: Color(0xFFFDE3ED),
      ),
      const _CategoryItem(
        icon: Icons.card_giftcard_rounded,
        label: 'الهدايا',
        color: Color(0xFFF8E7D0),
      ),
      const _CategoryItem(
        icon: Icons.currency_bitcoin_rounded,
        label: 'العملات',
        color: Color(0xFFEFE3B8),
      ),
      const _CategoryItem(
        icon: Icons.workspace_premium_rounded,
        label: 'VIP',
        color: Color(0xFFEFE1F7),
      ),
      const _CategoryItem(
        icon: Icons.task_alt_rounded,
        label: 'المهام',
        color: Color(0xFFE5F1FF),
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5F1),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 14,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: Color(0xFF4E3131),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFB96075),
                                  Color(0xFFD5944C),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD5944C)
                                      .withValues(alpha: 0.28),
                                  blurRadius: 14,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'أهلاً بعودتك',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF8A6B68),
                                ),
                              ),
                              Text(
                                'باسم العراق',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2A1E1D),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF071E2A),
                          Color(0xFF0F3745),
                          Color(0xFF1B5E83),
                          Color(0xFFE0B25A),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      border: Border.all(
                        color: const Color(0xFFB7E7F1),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF0C2E3B).withValues(alpha: 0.28),
                          blurRadius: 26,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color:
                              const Color(0xFF3E82B6).withValues(alpha: 0.22),
                          blurRadius: 36,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Top Iraq',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.6,
                                  color: Color(0xFFBFEFF7),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'توب عراق يرحب بكم',
                                style: TextStyle(
                                  fontSize: 27,
                                  height: 1.3,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'العالم الافتراضي\nللتجربة والمكافآت',
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFDDECF2),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0E3D4C)
                                          .withValues(alpha: 0.18),
                                      blurRadius: 14,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department_rounded,
                                      color: Color(0xFFB77D2B),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      VipLevelResolver.labelForLevel(vipLevel),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0F3C4C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const RoyalLionPortrait(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _StatPill(
                          label: 'العملات',
                          value: '$balance',
                          color: const Color(0xFFF8E7D0),
                          icon: Icons.monetization_on_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatPill(
                          label: 'XP',
                          value: '$xp',
                          color: const Color(0xFFFDE3ED),
                          icon: Icons.trending_up_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'الأقسام',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D1F1F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: isWide ? 3 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.0,
                    children: categories
                        .map(
                          (item) => _CategoryCard(
                            item: item,
                            balance: balance,
                            xp: xp,
                            vipLevel: vipLevel,
                            onBalanceChanged: onBalanceChanged,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مهام اليوم',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D1F1F),
                        ),
                      ),
                      Text(
                        'عرض الكل',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFB28752),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...dailyTasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DailyTaskCard(
                        task: task,
                        onComplete: () => onTaskCompleted(task.id),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.item,
    required this.balance,
    required this.xp,
    required this.vipLevel,
    required this.onBalanceChanged,
  });

  final _CategoryItem item;
  final int balance;
  final int xp;
  final int vipLevel;
  final ValueChanged<int> onBalanceChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        if (item.label == 'الغرف الصوتية') {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const VoiceRoomsScreen(),
            ),
          );
        } else if (item.label == 'الألعاب') {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => GamesScreen(
                balance: balance,
                onBalanceChanged: onBalanceChanged,
              ),
            ),
          );
        } else if (item.label == 'الهدايا') {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const WalletScreen(),
            ),
          );
        } else if (item.label == 'العملات') {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const WalletScreen(),
            ),
          );
        } else if (item.label == 'VIP') {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => VipScreen(
                xp: xp,
                balance: balance,
                vipLevel: vipLevel,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF2E7EA), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: item.color.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(item.icon, color: const Color(0xFF4C2D2D), size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D1F1F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4C2D2D), size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8B6F6F),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D1F1F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RoyalLionPortrait extends StatelessWidget {
  const RoyalLionPortrait({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1F1512),
            Color(0xFF4A2D22),
            Color(0xFF8C5A2C),
            Color(0xFFE3B76B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD8A45B).withValues(alpha: 0.42),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipOval(
        child: CustomPaint(
          painter: _RoyalLionPainter(),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _RoyalLionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 2);
    final manePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF331A15),
          Color(0xFF6C3C20),
          Color(0xFF8B5724),
          Color(0xFFB6782C),
          Color(0xFF5B2F1F),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    canvas.drawCircle(center, 54, manePaint);

    final innerManePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF2D1A16),
          Color(0xFF8A4D22),
          Color(0xFFE0A958),
        ],
      ).createShader(
          Rect.fromCircle(center: center, radius: size.width / 2 - 16));
    canvas.drawCircle(center, 42, innerManePaint);

    final cheekPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFF7E7BC),
          Color(0xFFF0C873),
          Color(0xFFDA9942),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCenter(
          center: center.translate(0, 4), width: 64, height: 58));
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(0, 7), width: 62, height: 56),
      cheekPaint,
    );

    final muzzlePaint = Paint()..color = const Color(0xFFF9E8C4);
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(0, 22), width: 32, height: 22),
      muzzlePaint,
    );

    final nosePaint = Paint()..color = const Color(0xFF6D341C);
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(0, 23), width: 12, height: 10),
      nosePaint,
    );

    final earPaint = Paint()..color = const Color(0xFFD58A39);
    final leftEar = Path()
      ..moveTo(center.dx - 20, center.dy - 20)
      ..lineTo(center.dx - 12, center.dy - 36)
      ..lineTo(center.dx - 2, center.dy - 18)
      ..close();
    final rightEar = Path()
      ..moveTo(center.dx + 20, center.dy - 20)
      ..lineTo(center.dx + 12, center.dy - 36)
      ..lineTo(center.dx + 2, center.dy - 18)
      ..close();
    canvas.drawPath(leftEar, earPaint);
    canvas.drawPath(rightEar, earPaint);

    final browPaint = Paint()..color = const Color(0xFF42251D);
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(-12, 0), width: 12, height: 7),
      browPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(12, 0), width: 12, height: 7),
      browPaint,
    );

    final eyeShadow = Paint()..color = const Color(0xFF2A1B17);
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(-13, 8), width: 8, height: 6),
      eyeShadow,
    );
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(13, 8), width: 8, height: 6),
      eyeShadow,
    );

    final eyeHighlight = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(-12, 6), width: 3, height: 2.5),
      eyeHighlight,
    );
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(14, 6), width: 3, height: 2.5),
      eyeHighlight,
    );

    final whiskerPaint = Paint()..color = const Color(0xFF43261D);
    canvas.drawLine(
      Offset(center.dx - 20, center.dy + 21),
      Offset(center.dx - 34, center.dy + 28),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(center.dx - 16, center.dy + 23),
      Offset(center.dx - 26, center.dy + 31),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 20, center.dy + 21),
      Offset(center.dx + 34, center.dy + 28),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 16, center.dy + 23),
      Offset(center.dx + 26, center.dy + 31),
      whiskerPaint,
    );

    final crownPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFF9E7A6),
          Color(0xFFE3BF5F),
          Color(0xFF9C6825),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCenter(
          center: center.translate(0, -42), width: 52, height: 20));
    final crown = Path()
      ..moveTo(center.dx - 20, center.dy - 18)
      ..lineTo(center.dx - 14, center.dy - 34)
      ..lineTo(center.dx - 6, center.dy - 20)
      ..lineTo(center.dx, center.dy - 36)
      ..lineTo(center.dx + 6, center.dy - 20)
      ..lineTo(center.dx + 14, center.dy - 34)
      ..lineTo(center.dx + 20, center.dy - 18)
      ..lineTo(center.dx + 15, center.dy - 12)
      ..lineTo(center.dx - 15, center.dy - 12)
      ..close();
    canvas.drawPath(crown, crownPaint);

    final gemPaint = Paint()..color = const Color(0xFFF7F1D9);
    canvas.drawCircle(center.translate(-10, -26), 3.5, gemPaint);
    canvas.drawCircle(center.translate(0, -30), 4.2, gemPaint);
    canvas.drawCircle(center.translate(10, -26), 3.5, gemPaint);

    final glowPaint = Paint()..color = Colors.white.withValues(alpha: 0.18);
    canvas.drawCircle(center.translate(-20, -18), 16, glowPaint);
    canvas.drawCircle(center.translate(18, -12), 10, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CategoryItem {
  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _balance = 12480;
  String _selectedRecipient = 'أميرة';

  final List<GiftItem> _gifts = const [
    GiftItem(
      name: 'زجاجة قهوة فاخرة',
      emoji: '☕',
      price: 250,
      description: 'هدية لطيفة للغرفة',
      accent: Color(0xFFF29CB0),
    ),
    GiftItem(
      name: 'وردة ذهبية',
      emoji: '🌹',
      price: 420,
      description: 'إضاءة لطيفة للغرفة',
      accent: Color(0xFFD9A65F),
    ),
    GiftItem(
      name: 'كأس فاخر',
      emoji: '🏆',
      price: 680,
      description: 'عرض فاخر داخل الغرفة',
      accent: Color(0xFFEFE1F7),
    ),
    GiftItem(
      name: 'سيارة صغيرة',
      emoji: '🚗',
      price: 1200,
      description: 'هدية فاخرة ومميزة',
      accent: Color(0xFF9ECDB4),
    ),
  ];

  final List<String> _recipients = const [
    'أميرة',
    'سيف',
    'نور',
    'زهراء',
    'حسن',
  ];

  final List<GiftHistoryItem> _history = [
    const GiftHistoryItem(
      name: 'وردة ذهبية',
      recipient: 'أميرة',
      price: 420,
    ),
    const GiftHistoryItem(
      name: 'زجاجة قهوة فاخرة',
      recipient: 'سيف',
      price: 250,
    ),
  ];

  void _sendGift(GiftItem gift) {
    if (_balance < gift.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا توجد عملات كافية لإرسال ${gift.name}. الرصيد الحالي $_balance',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: const Color(0xFFB28752),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _balance -= gift.price;
    });

    final updatedHistory = <GiftHistoryItem>[
      GiftHistoryItem(
        name: gift.name,
        recipient: _selectedRecipient,
        price: gift.price,
      ),
      ..._history,
    ];

    setState(() {
      _history
        ..clear()
        ..addAll(updatedHistory.take(6));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إرسال ${gift.name} إلى $_selectedRecipient بنجاح',
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9F9),
        appBar: AppBar(
          title: const Text('العملات'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2D1F1F),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFFDE3ED),
                          Color(0xFFF8E7D0),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'رصيد العملات',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF7C5A5A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.monetization_on_rounded,
                              color: Color(0xFFD9A65F),
                              size: 32,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$_balance',
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2D1F1F),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'عملة محلية تجريبية',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B6F6F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'إرسال هدية إلى مستخدم داخل الغرفة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D1F1F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF2E7EA)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRecipient,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(16),
                        items: _recipients
                            .map(
                              (recipient) => DropdownMenuItem<String>(
                                value: recipient,
                                child: Text(recipient),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRecipient = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'عرض الهدايا',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D1F1F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _gifts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.88,
                    ),
                    itemBuilder: (context, index) {
                      final gift = _gifts[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: gift.accent.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Center(
                                child: Text(
                                  gift.emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              gift.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2D1F1F),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              gift.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8B6F6F),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${gift.price} عملة',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB28752),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _sendGift(gift),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF29CB0),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('إرسال'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'آخر الهدايا المرسلة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D1F1F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _history.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final gift = _history[index];
                        return Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDE3ED),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.card_giftcard_rounded,
                                color: Color(0xFFB28752),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${gift.name} → ${gift.recipient}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2D1F1F),
                                    ),
                                  ),
                                  Text(
                                    '${gift.price} عملة',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8B6F6F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GiftItem {
  const GiftItem({
    required this.name,
    required this.emoji,
    required this.price,
    required this.description,
    required this.accent,
  });

  final String name;
  final String emoji;
  final int price;
  final String description;
  final Color accent;
}

class GiftHistoryItem {
  const GiftHistoryItem({
    required this.name,
    required this.recipient,
    required this.price,
  });

  final String name;
  final String recipient;
  final int price;
}

class GamesScreen extends StatelessWidget {
  const GamesScreen({
    super.key,
    required this.balance,
    required this.onBalanceChanged,
  });

  final int balance;
  final ValueChanged<int> onBalanceChanged;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9F9),
        appBar: AppBar(
          title: const Text('🎮 الألعاب'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2D1F1F),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Games list
                Expanded(
                  child: ListView(
                    children: [
                      _GameCard(
                        title: '🎲 النرد',
                        subtitle: 'رمي نرد تجريبي وظهر نتيجة عشوائية.',
                        accent: const Color(0xFF74C1D7),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const DiceGameScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _GameCard(
                        title: '🌾 المزرعة',
                        subtitle:
                            'لعبة دائرية سريعة مع اختيار العناصر والمكافآت.',
                        accent: const Color(0xFFE3B866),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => FarmWheelScreen(
                                balance: balance,
                                onBalanceChanged: onBalanceChanged,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _GameCard(
                        title: '🎟️ السحب/الحظ',
                        subtitle: 'اختر رقمًا واطّلع على النتيجة المحلية.',
                        accent: const Color(0xFF9AD2BA),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const LuckyDrawScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: accent.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D1F1F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B5B5B),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'اللعب الآن →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiceGameScreen extends StatefulWidget {
  const DiceGameScreen({super.key});

  @override
  State<DiceGameScreen> createState() => _DiceGameScreenState();
}

class _DiceGameScreenState extends State<DiceGameScreen> {
  final Random _random = Random();
  int _diceValue = 1;
  int _reward = 0;

  void _rollDice() {
    final value = _random.nextInt(6) + 1;
    setState(() {
      _diceValue = value;
      _reward = value * 35;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9F9),
        appBar: AppBar(
          title: const Text('🎲 النرد'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2D1F1F),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'لعبة النرد التجريبية',
                      style: TextStyle(
                        color: Color(0xFF2D1F1F),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: Container(
                        key: ValueKey<int>(_diceValue),
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE3ED),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Center(
                          child: Text(
                            '🎲\n$_diceValue',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'النتيجة: $_diceValue',
                      style: const TextStyle(
                        color: Color(0xFF5C4B4B),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'مكافأة محلية: $_reward عملة',
                      style: const TextStyle(
                        color: Color(0xFFB28752),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _rollDice,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFF29CB0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'رمي النرد',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FarmWheelScreen extends StatefulWidget {
  const FarmWheelScreen({
    super.key,
    required this.balance,
    required this.onBalanceChanged,
  });

  final int balance;
  final ValueChanged<int> onBalanceChanged;

  @override
  State<FarmWheelScreen> createState() => _FarmWheelScreenState();
}

class _FarmWheelScreenState extends State<FarmWheelScreen>
    with SingleTickerProviderStateMixin {
  static const int _roundDurationSeconds = 12;
  static const List<FarmPrize> _prizes = [
    FarmPrize(
      name: 'كتكوت',
      multiplier: 45,
      color: Color(0xFFF5D4A5),
      emoji: '🐥',
      cost: 50,
    ),
    FarmPrize(
      name: 'سمكة',
      multiplier: 25,
      color: Color(0xFF74C1D7),
      emoji: '🐟',
      cost: 40,
    ),
    FarmPrize(
      name: 'بقرة',
      multiplier: 15,
      color: Color(0xFFE7C369),
      emoji: '🐄',
      cost: 30,
    ),
    FarmPrize(
      name: 'كمبري',
      multiplier: 10,
      color: Color(0xFFD9C7E8),
      emoji: '🦐',
      cost: 25,
    ),
    FarmPrize(
      name: 'ذرة',
      multiplier: 5,
      color: Color(0xFFE8D89B),
      emoji: '🌽',
      cost: 20,
    ),
    FarmPrize(
      name: 'جزر',
      multiplier: 5,
      color: Color(0xFFF7B55A),
      emoji: '🥕',
      cost: 20,
    ),
    FarmPrize(
      name: 'فلفل',
      multiplier: 5,
      color: Color(0xFF9ECDB4),
      emoji: '🌶️',
      cost: 20,
    ),
    FarmPrize(
      name: 'طماطم',
      multiplier: 5,
      color: Color(0xFFF29A8A),
      emoji: '🍅',
      cost: 20,
    ),
  ];

  final Random _random = Random();
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  // Game states
  bool _showSelection = true;
  bool _isSpinning = false;
  double _spinTargetDegrees = 0;
  FarmPrize? _selectedPrize;
  FarmPrize? _winPrize;
  int _roundNumber = 0;
  int _sessionReward = 0;
  int _remainingSeconds = _roundDurationSeconds;
  int? _roundBalance;
  int _winReward = 0;
  Timer? _roundTimer;

  int get _currentBalance => widget.balance;

  void _selectPrize(FarmPrize prize) {
    setState(() {
      _selectedPrize = prize;
      _winPrize = null;
    });
  }

  void _confirmPlay() {
    final prize = _selectedPrize;
    if (prize == null) return;

    if (_currentBalance < prize.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '❌ رصيدك غير كافٍ لهذه الجولة',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: const Color(0xFFC64048),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final balanceAfterStake = _currentBalance - prize.cost;
    setState(() {
      _showSelection = false;
      _isSpinning = true;
      _remainingSeconds = _roundDurationSeconds;
      _roundBalance = balanceAfterStake;
    });

    widget.onBalanceChanged(balanceAfterStake);

    // Simulate spin with randomness
    final targetIndex = _random.nextInt(_prizes.length);
    final step = 360 / _prizes.length;
    final rotateDegrees = 360 * 8 + (360 - (targetIndex * step + step / 2));

    setState(() {
      _spinTargetDegrees = rotateDegrees;
      _roundNumber += 1;
    });

    _roundTimer?.cancel();
    _roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isSpinning) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds = max(0, _remainingSeconds - 1);
      });
    });

    _controller
      ..reset()
      ..forward().whenComplete(() {
        if (mounted) {
          _roundTimer?.cancel();
          final winPrize = _prizes[targetIndex];
          final reward =
              winPrize.multiplier * (_selectedPrize?.multiplier ?? 1);

          setState(() {
            _isSpinning = false;
            _winPrize = winPrize;
            _winReward = reward;
            _sessionReward += reward;
          });

          widget.onBalanceChanged((_roundBalance ?? _currentBalance) + reward);

          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              _showResultDialog(winPrize, reward);
            }
          });
        }
      });
  }

  void _showResultDialog(FarmPrize winPrize, int reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: const Color(0xFFF8FBFD),
          title: Column(
            children: [
              Text(
                winPrize.emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              const Text(
                '🎉 مبروك!',
                style: TextStyle(
                  color: Color(0xFF123E4D),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'فزت بـ ${winPrize.emoji} ${winPrize.name}',
                style: const TextStyle(
                  color: Color(0xFF123E4D),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: winPrize.color.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: winPrize.color, width: 2),
                ),
                child: Text(
                  '+$reward عملة',
                  style: const TextStyle(
                    color: Color(0xFF123E4D),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _showSelection = true;
                    _selectedPrize = null;
                    _winPrize = null;
                    _winReward = 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F3C4C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'العب مرة أخرى',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9F9),
        appBar: AppBar(
          title: const Text('🌾 لعبة المزرعة'),
          backgroundColor: const Color(0xFF0F3C4C),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBFD),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFBEE7F4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF123E4D).withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0F3C4C),
                              Color(0xFF1E5D7A),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _HeaderStat(
                              icon: '💰',
                              label: 'الرصيد',
                              value: '$_currentBalance',
                            ),
                            _HeaderStat(
                              icon: '🎮',
                              label: 'الجولات',
                              value: '$_roundNumber',
                            ),
                            _HeaderStat(
                              icon: '🏆',
                              label: 'المكافآت',
                              value: '$_sessionReward',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_showSelection)
                        _buildPrizeSelection()
                      else
                        _buildGameWheel(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrizeSelection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: FittedBox(
                child: const RoyalLionPortrait(),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Top Iraq • مزرعة الأصدقاء',
              style: TextStyle(
                color: Color(0xFF123E4D),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'اختر الحيوان أو المحصول',
          style: TextStyle(
            color: Color(0xFF123E4D),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: _prizes.length,
          itemBuilder: (context, index) {
            final prize = _prizes[index];
            final canAfford = _currentBalance >= prize.cost;
            final isSelected = _selectedPrize == prize;
            return GestureDetector(
              onTap: canAfford ? () => _selectPrize(prize) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: canAfford
                      ? prize.color
                      : prize.color.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFE0B25A)
                        : canAfford
                            ? const Color(0xFF123E4D)
                            : const Color(0xFFBBBBBB),
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: canAfford
                      ? [
                          BoxShadow(
                            color: prize.color.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      prize.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prize.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF123E4D),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${prize.cost} 💰',
                      style: const TextStyle(
                        color: Color(0xFF0F3C4C),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        if (_selectedPrize != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBEE7F4)),
            ),
            child: Text(
              'اختيارك: ${_selectedPrize!.emoji} ${_selectedPrize!.name} • تكلفة الجولة ${_selectedPrize!.cost} Coins',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF123E4D),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _selectedPrize == null ? null : _confirmPlay,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('تأكيد والعب الآن'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F3C4C),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFD5E0E4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameWheel() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF123E4D),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF123E4D).withValues(alpha: 0.2),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                '${_selectedPrize?.emoji ?? ''} ${_selectedPrize?.name ?? ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              const Icon(Icons.timer_rounded, color: Color(0xFFE0B25A)),
              const SizedBox(width: 6),
              Text(
                '$_remainingSeconds ث',
                style: const TextStyle(
                  color: Color(0xFFE0B25A),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: _remainingSeconds / _roundDurationSeconds,
            minHeight: 7,
            backgroundColor: const Color(0xFFD9EAF0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE0B25A)),
          ),
        ),
        const SizedBox(height: 18),
        Stack(
          alignment: Alignment.topCenter,
          children: [
            const SizedBox(height: 300, width: 300),
            AnimatedBuilder(
              animation: _curve,
              builder: (context, child) {
                final degrees = _curve.value * _spinTargetDegrees;
                final scale =
                    _isSpinning ? 1 + sin(_curve.value * pi * 18) * 0.018 : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Transform.rotate(
                    angle: degrees * (pi / 180),
                    child: CustomPaint(
                      size: const Size(280, 280),
                      painter: _FarmWheelPainter(_prizes),
                    ),
                  ),
                );
              },
            ),
            // Pointer
            const Positioned(
              top: 4,
              child: SizedBox(
                width: 0,
                height: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        width: 14,
                        color: Color(0xFFE0B25A),
                      ),
                      right: BorderSide(
                        width: 14,
                        color: Color(0xFFE0B25A),
                      ),
                      bottom: BorderSide(
                        width: 0,
                        color: Colors.transparent,
                      ),
                      top: BorderSide(
                        width: 0,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0B25A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE0B25A).withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (!_isSpinning && _winPrize != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _winPrize!.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _winPrize!.color, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  'الفائز: ${_winPrize!.emoji} ${_winPrize!.name}',
                  style: const TextStyle(
                    color: Color(0xFF123E4D),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '+$_winReward Coins',
                  style: const TextStyle(
                    color: Color(0xFFB28752),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        if (_isSpinning)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '⏳ جاري الدوران...',
              style: TextStyle(
                color: Color(0xFF123E4D),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _FarmWheelPainter extends CustomPainter {
  const _FarmWheelPainter(this.prizes);

  final List<FarmPrize> prizes;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final slice = 360 / prizes.length;

    final backdrop = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF0F3C4C),
          Color(0xFF1E5D7A),
          Color(0xFFE8C36B),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, backdrop);

    for (var index = 0; index < prizes.length; index++) {
      final paint = Paint()..color = prizes[index].color;
      final startAngle = (index * slice - 90) * (pi / 180);
      final sweepAngle = (slice * (pi / 180));
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final labelAngle = ((index + 0.5) * slice - 90) * (pi / 180);
      final labelRadius = radius * 0.62;
      final labelX = center.dx + cos(labelAngle) * labelRadius;
      final labelY = center.dy + sin(labelAngle) * labelRadius;
      final label = TextPainter(
        text: TextSpan(
          text: '${prizes[index].emoji}\n${prizes[index].name}',
          style: const TextStyle(
            color: Color(0xFF123E4D),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
          recognizer: null,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      )..layout(maxWidth: radius * 0.44);

      final multiplier = TextPainter(
        text: TextSpan(
          text: '×${prizes[index].multiplier}',
          style: const TextStyle(
            color: Color(0xFF123E4D),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();

      label.paint(
        canvas,
        Offset(labelX - (label.width / 2), labelY - (label.height / 2)),
      );
      multiplier.paint(
        canvas,
        Offset(
          labelX - (multiplier.width / 2),
          labelY + label.height * 0.8,
        ),
      );
    }

    final innerPaint = Paint()..color = const Color(0xFFEAF5FA);
    canvas.drawCircle(center, radius * 0.22, innerPaint);
    final ringPaint = Paint()..color = const Color(0xFFE0B25A);
    canvas.drawCircle(center, radius * 0.25, ringPaint);
    final corePaint = Paint()..color = const Color(0xFF0F3C4C);
    canvas.drawCircle(center, radius * 0.14, corePaint);
  }

  @override
  bool shouldRepaint(covariant _FarmWheelPainter oldDelegate) => true;
}

class FarmPrize {
  const FarmPrize({
    required this.name,
    required this.multiplier,
    required this.color,
    required this.emoji,
    required this.cost,
  });

  final String name;
  final int multiplier;
  final Color color;
  final String emoji;
  final int cost;
}

class LuckyDrawScreen extends StatefulWidget {
  const LuckyDrawScreen({super.key});

  @override
  State<LuckyDrawScreen> createState() => _LuckyDrawScreenState();
}

class _LuckyDrawScreenState extends State<LuckyDrawScreen> {
  final Random _random = Random();
  final List<int> _numbers = List<int>.generate(10, (index) => index + 1);
  int _selectedNumber = 1;
  int _drawResult = 0;
  String _status = 'اختر رقمًا ثم اسحب';

  void _drawLuckyNumber() {
    final result = _random.nextInt(10) + 1;
    final isWin = result == _selectedNumber;
    final reward = isWin ? 220 : 30;

    setState(() {
      _drawResult = result;
      _status = isWin
          ? 'مبروك! الرقم $_drawResult ظهر، ورحلة الفتح اكتملت، فزت بـ $reward عملة محلية.'
          : 'الرقم الذي ظهر هو $_drawResult، جرب مرة أخرى وجرّب الحظ.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9F9),
        appBar: AppBar(
          title: const Text('🎟️ السحب/الحظ'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2D1F1F),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'سحب الحظ التجريبي',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D1F1F),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF4F6),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedNumber,
                          isExpanded: true,
                          items: _numbers
                              .map(
                                (number) => DropdownMenuItem<int>(
                                  value: number,
                                  child: Center(
                                    child: Text(
                                      number.toString(),
                                      style: const TextStyle(
                                        color: Color(0xFF2D1F1F),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedNumber = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'رقمك المختار: $_selectedNumber',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5C4B4B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE3ED),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF2D1F1F),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _drawLuckyNumber,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFF29CB0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'سحب الحظ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VoiceRoomsScreen extends StatelessWidget {
  const VoiceRoomsScreen({super.key});

  static const List<VoiceRoom> rooms = [
    VoiceRoom(
      name: 'مقهى بغداد',
      subtitle: 'غرفة هادئة للمحادثات',
      members: 128,
      status: 'مباشر',
      accent: Color(0xFFF29CB0),
      icon: Icons.waves_rounded,
      isLive: true,
    ),
    VoiceRoom(
      name: 'ساحة أربيل',
      subtitle: 'تحديات ومرح مع الأصدقاء',
      members: 94,
      status: 'مباشر',
      accent: Color(0xFFD9A65F),
      icon: Icons.campaign_rounded,
      isLive: true,
    ),
    VoiceRoom(
      name: 'غرفة الهدوء',
      subtitle: 'استرخاء ومحادثات ناعمة',
      members: 56,
      status: 'مستقرة',
      accent: Color(0xFF9ECDB4),
      icon: Icons.spatial_audio_rounded,
      isLive: false,
    ),
    VoiceRoom(
      name: 'إيصال النجوم',
      subtitle: 'استعراضات ومشاركة عربية',
      members: 148,
      status: 'مباشر',
      accent: Color(0xFFEFE1F7),
      icon: Icons.auto_awesome_rounded,
      isLive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9F9),
        appBar: AppBar(
          title: const Text('الغرف الصوتية'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2D1F1F),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ListView.separated(
                  itemCount: rooms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return _VoiceRoomCard(room: room);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _VoiceRoomCard extends StatelessWidget {
  const _VoiceRoomCard({required this.room});

  final VoiceRoom room;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => VoiceRoomDetailScreen(room: room),
          ),
        );
      },
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFF4E5E8), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: room.accent.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  room.accent.withValues(alpha: 0.96),
                  room.accent.withValues(alpha: 0.58),
                  const Color(0xFFFDF9FB),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -24,
                  right: -12,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -28,
                  left: -20,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(room.icon, size: 32, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    room.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF2D1F1F),
                                    ),
                                  ),
                                ),
                                if (room.isLive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'مباشر',
                                      style: TextStyle(
                                        color: Color(0xFFB28752),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              room.subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4C3B3B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.people_alt_rounded,
                                  size: 16,
                                  color: Color(0xFF4C2D2D),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${room.members} موجودين',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2D1F1F),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    room.status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: room.isLive
                                          ? const Color(0xFFB28752)
                                          : const Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    VoiceRoomDetailScreen(room: room),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF29CB0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            elevation: 0,
                          ),
                          child: const Text('دخول الغرفة'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VoiceRoomDetailScreen extends StatefulWidget {
  const VoiceRoomDetailScreen({super.key, required this.room});

  final VoiceRoom room;

  @override
  State<VoiceRoomDetailScreen> createState() => _VoiceRoomDetailScreenState();
}

class _VoiceRoomDetailScreenState extends State<VoiceRoomDetailScreen> {
  final List<VoiceMember> members = [
    VoiceMember(name: 'أميرة', isMuted: false, color: const Color(0xFFF29CB0)),
    VoiceMember(name: 'سيف', isMuted: true, color: const Color(0xFFD9A65F)),
    VoiceMember(name: 'نور', isMuted: false, color: const Color(0xFF9ECDB4)),
    VoiceMember(name: 'زهراء', isMuted: true, color: const Color(0xFFEFE1F7)),
    VoiceMember(name: 'حسن', isMuted: false, color: const Color(0xFFE5F1FF)),
    VoiceMember(name: 'لينا', isMuted: false, color: const Color(0xFFF8E7D0)),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2D1F1F),
          title: Text(widget.room.name),
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: LinearGradient(
                        colors: [
                          widget.room.accent.withValues(alpha: 0.9),
                          const Color(0xFFF7DDE7),
                          const Color(0xFFF4F0FF),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1.1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.room.accent.withValues(alpha: 0.24),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1.2,
                            ),
                          ),
                          child: Icon(widget.room.icon,
                              size: 34, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.room.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.people_alt_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.room.members} حاضرون الآن',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'المقاعد الصوتية',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D1F1F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: members.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width < 360 ? 2 : 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFF4E5E8),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: member.color.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: member.color,
                              child: Text(
                                member.name.substring(0, 1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              member.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2D1F1F),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: member.isMuted
                                    ? const Color(0xFFFDE3ED)
                                    : const Color(0xFFEFF7F1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                member.isMuted ? 'كتم' : 'مسموع',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: member.isMuted
                                      ? const Color(0xFFB28752)
                                      : const Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              for (final member in members) {
                                member.isMuted = !member.isMuted;
                              }
                            });
                          },
                          icon: const Icon(Icons.volume_off_rounded),
                          label: const Text('كتم / إلغاء الكتم'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD9A65F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.exit_to_app_rounded),
                      label: const Text('خروج'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5C4B4B),
                        side: const BorderSide(color: Color(0xFFE8D7DA)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VoiceRoom {
  const VoiceRoom({
    required this.name,
    required this.subtitle,
    required this.members,
    required this.status,
    required this.accent,
    required this.icon,
    required this.isLive,
  });

  final String name;
  final String subtitle;
  final int members;
  final String status;
  final Color accent;
  final IconData icon;
  final bool isLive;
}

class VoiceMember {
  VoiceMember({
    required this.name,
    required this.isMuted,
    required this.color,
  });

  final String name;
  final Color color;
  bool isMuted;
}
