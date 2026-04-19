// widgets/mini_player.dart

import 'package:flutter/material.dart';

import '../utils/theme.dart';

import '../models/song_model.dart';

class MiniPlayer extends StatelessWidget {

  final SongModel song;

  final VoidCallback onTap;

  const MiniPlayer({super.key, required this.song, required this.onTap});

  @override

  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        margin: const EdgeInsets.all(12),

        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

        decoration: BoxDecoration(

          color: MyfyTheme.surfaceColor,

          borderRadius: BorderRadius.circular(16),

          border: Border.all(color: MyfyTheme.borderColor),

        ),

        child: Row(

          children: [

            Container(

              width: 44,

              height: 44,

              decoration: BoxDecoration(

                gradient: const LinearGradient(

                  colors: [MyfyTheme.primaryOrange, Color(0xFFFF8C33)],

                ),

                borderRadius: BorderRadius.circular(10),

              ),

              child: const Icon(Icons.music_note_rounded, color: Colors.white),

            ),

            const SizedBox(width: 12),

            Expanded(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                mainAxisSize: MainAxisSize.min,

                children: [

                  Text(song.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),

                  Text(song.artist, style: const TextStyle(color: MyfyTheme.textSecondary)),

                ],

              ),

            ),

            IconButton(icon: const Icon(Icons.play_arrow_rounded), onPressed: onTap),

          ],

        ),

      ),

    );

  }

}