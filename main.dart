\
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasHero = prefs.containsKey('heroName');
  runApp(DailyQuestApp(hasHero: hasHero));
}

class DailyQuestApp extends StatelessWidget {
  final bool hasHero;
  const DailyQuestApp({super.key, required this.hasHero});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Quest Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF151019),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ),
      home: hasHero ? const HomePage() : const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      Image.asset('assets/images/bg_welcome.png', fit: BoxFit.cover),
      Container(color: Colors.black.withOpacity(0.45)),
      Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset('assets/icons/app_icon.png', width: 120, height: 120),
          const SizedBox(height: 16),
          const Text('Daily Quest', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('heroName', 'Héroe');
              await prefs.setString('currentEra', 'Edad Antigua');
              await prefs.setInt('level', 1);
              await prefs.setInt('xp', 0);
              await prefs.setInt('coins', 0);
              await prefs.setInt('streak', 0);
              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Comenzar aventura'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent, padding: const EdgeInsets.symmetric(horizontal:20, vertical:12)),
          ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.5, duration: 700.ms),
        ]),
      ),
    ]);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _heroName;
  late String _currentEra;
  late int _level;
  int _xp = 0;
  int _coins = 0;
  int _streak = 0;
  bool _showReward = false;

  final Map<String, String> _eraBackgrounds = const {
    'Edad Antigua': 'assets/images/bg_edad_antigua.png',
    'Edad Media': 'assets/images/bg_edad_media.png',
    'Renacimiento': 'assets/images/bg_renacimiento.png',
    'Fantasía Oscura': 'assets/images/bg_fantasia_oscura.png',
  };

  final Map<String, Color> _eraColor = const {
    'Edad Antigua': Colors.brown,
    'Edad Media': Colors.indigo,
    'Renacimiento': Colors.orange,
    'Fantasía Oscura': Colors.deepPurple,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _heroName = prefs.getString('heroName') ?? 'Héroe';
    _currentEra = prefs.getString('currentEra') ?? 'Edad Antigua';
    _level = prefs.getInt('level') ?? 1;
    _xp = prefs.getInt('xp') ?? 0;
    _coins = prefs.getInt('coins') ?? 0;
    _streak = prefs.getInt('streak') ?? 0;
    setState(() {});
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('heroName', _heroName);
    await prefs.setString('currentEra', _currentEra);
    await prefs.setInt('level', _level);
    await prefs.setInt('xp', _xp);
    await prefs.setInt('coins', _coins);
    await prefs.setInt('streak', _streak);
  }

  void _completeMission() {
    setState(() {
      _xp += 20;
      _coins += 5;
      _streak += 1;
      if (_xp >= 100) {
        _xp -= 100;
        _level += 1;
        // change era automatically
        final eras = _eraBackgrounds.keys.toList();
        _currentEra = eras[(_level ~/ 5).clamp(0, eras.length-1)];
        _showReward = true;
      }
    });
    _save();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {});
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _showReward = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = _eraBackgrounds[_currentEra] ?? 'assets/images/bg_edad_antigua.png';
    final color = _eraColor[_currentEra] ?? Colors.deepPurple;
    return Stack(fit: StackFit.expand, children: [
      Image.asset(bg, fit: BoxFit.cover),
      Container(color: Colors.black.withOpacity(0.45)),
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [Image.asset('assets/icons/app_icon.png', width:40), const SizedBox(width:8), Text(_heroName, style: const TextStyle(color: Colors.white))]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('Nivel $_level', style: TextStyle(color: color)), Text('XP $_xp/100', style: const TextStyle(color: Colors.white70))])
            ]),
            const SizedBox(height: 12),
            Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Completar misión'),
                style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(horizontal:18, vertical:14)),
                onPressed: _completeMission,
              ).animate().scale(duration: 350.ms),
              const SizedBox(height: 16),
              if (_showReward)
                Column(children: [
                  const Text('¡Recompensa!', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: List.generate(8, (i) => Text(['🎉','✨','🏆','💎','⚔️','🛡️'][i%6], style: const TextStyle(fontSize: 28))).animate().fadeIn(duration: 500.ms)
                  )
                ])
            ]))),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Column(children: [const Icon(Icons.monetization_on, color: Colors.amber), const SizedBox(height:6), Text('$_coins', style: const TextStyle(color: Colors.white))]),
              Column(children: [const Icon(Icons.local_fire_department, color: Colors.redAccent), const SizedBox(height:6), Text('$_streak', style: const TextStyle(color: Colors.white))]),
              IconButton(onPressed: () async { 
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                _load();
              }, icon: const Icon(Icons.refresh, color: Colors.white)),
            ])
          ]),
        ),
      )
    ]);
  }
}
