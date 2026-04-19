import 'package:flutter/material.dart';

import '../utils/theme.dart';

import '../widgets/bottom_nav_bar.dart';

import '../widgets/mini_player.dart';

import '../models/song_model.dart';          // 🟢 IMPORT

import 'search_screen.dart';

import 'library_screen.dart';

import 'player_screen.dart';                 // 🟢 IMPORT

import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override

  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {

  int _selectedIndex = 0;

  SongModel? _currentSong;                  // 🟢 இப்போது பிழை வராது

  late final List<Widget> _screens;

  @override

  void initState() {

    super.initState();

    _screens = [

      const _HomeContent(),

      SearchScreen(

        onBackToHome: () => setState(() => _selectedIndex = 0),

      ),

      LibraryScreen(

        onPlaySong: (song) {

          setState(() => _currentSong = song);

        },

      ),

    ];

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(

        children: [

          _screens[_selectedIndex],

          if (_currentSong != null)

            Positioned(

              bottom: 0,

              left: 0,

              right: 0,

              child: MiniPlayer(

                song: _currentSong!,

                onTap: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) => PlayerScreen(song: _currentSong!),

                    ),

                  );

                },

              ),

            ),

        ],

      ),

      bottomNavigationBar: BottomNavBar(

        currentIndex: _selectedIndex,

        onTap: (index) => setState(() => _selectedIndex = index),

      ),

    );

  }

}

class _HomeContent extends StatelessWidget {

  const _HomeContent();

  @override

  Widget build(BuildContext context) {

    return SafeArea(

      child: Column(

        children: [

          // Header

          Padding(

            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),

            child: Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(

                      'Myfy',

                      style: Theme.of(context).textTheme.titleLarge?.copyWith(

                            foreground: Paint()

                              ..shader = const LinearGradient(

                                colors: [Colors.white, MyfyTheme.primaryOrange],

                              ).createShader(const Rect.fromLTWH(0, 0, 100, 40)),

                          ),

                    ),

                    const Text(

                      'Discover new music',

                      style: TextStyle(color: MyfyTheme.textSecondary, fontSize: 14),

                    ),

                  ],

                ),

                Row(

                  children: [

                    IconButton(

                      icon: const Icon(Icons.notifications_none_rounded),

                      onPressed: () {},

                    ),

                    IconButton(

                      icon: const Icon(Icons.settings_outlined),

                      onPressed: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(builder: (_) => const SettingsScreen()),

                        );

                      },

                    ),

                  ],

                ),

              ],

            ),

          ),

          const Spacer(),

          // மையப்படுத்தப்பட்ட தேடல் பகுதி

          Padding(

            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: Column(

              children: [

                Container(

                  width: 80,

                  height: 80,

                  decoration: BoxDecoration(

                    gradient: const LinearGradient(

                      colors: [MyfyTheme.primaryOrange, Color(0xFFFF8C33)],

                    ),

                    borderRadius: BorderRadius.circular(24),

                    boxShadow: [

                      BoxShadow(

                        color: MyfyTheme.primaryOrange.withOpacity(0.3),

                        blurRadius: 20,

                        spreadRadius: 2,

                      ),

                    ],

                  ),

                  child: const Icon(

                    Icons.search_rounded,

                    size: 40,

                    color: Colors.white,

                  ),

                ),

                const SizedBox(height: 24),

                const Text(

                  'What do you want to listen to?',

                  style: TextStyle(

                    fontSize: 20,

                    fontWeight: FontWeight.w600,

                    color: Colors.white,

                  ),

                  textAlign: TextAlign.center,

                ),

                const SizedBox(height: 12),

                const Text(

                  'Search for songs, artists, albums, or paste a URL',

                  style: TextStyle(

                    fontSize: 15,

                    color: MyfyTheme.textSecondary,

                  ),

                  textAlign: TextAlign.center,

                ),

                const SizedBox(height: 32),

                GestureDetector(

                  onTap: () {

                    final homeState = context.findAncestorStateOfType<_HomeScreenState>();

                    homeState?.setState(() => homeState._selectedIndex = 1);

                  },

                  child: Container(

                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

                    decoration: BoxDecoration(

                      color: MyfyTheme.surfaceColor,

                      borderRadius: BorderRadius.circular(50),

                      border: Border.all(color: MyfyTheme.borderColor),

                    ),

                    child: Row(

                      children: [

                        const Icon(

                          Icons.search_rounded,

                          color: MyfyTheme.primaryOrange,

                          size: 24,

                        ),

                        const SizedBox(width: 12),

                        Expanded(

                          child: Text(

                            'Search music or paste URL',

                            style: TextStyle(

                              color: MyfyTheme.textSecondary.withOpacity(0.7),

                              fontSize: 16,

                            ),

                          ),

                        ),

                        IconButton(

                          icon: const Icon(Icons.content_paste_rounded, color: MyfyTheme.primaryOrange),

                          onPressed: () {

                            ScaffoldMessenger.of(context).showSnackBar(

                              const SnackBar(

                                content: Text('Paste URL feature coming soon!'),

                                duration: Duration(seconds: 1),

                              ),

                            );

                          },

                        ),

                      ],

                    ),

                  ),

                ),

              ],

            ),

          ),

          const Spacer(),

          const SizedBox(height: 20),

        ],

      ),

    );

  }

}