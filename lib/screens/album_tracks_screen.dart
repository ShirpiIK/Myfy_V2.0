import 'package:flutter/material.dart';

import '../utils/theme.dart';

import '../models/song_model.dart';

import '../widgets/song_tile.dart';

import 'player_screen.dart';

class AlbumTracksScreen extends StatelessWidget {

  final String albumName;

  final List<dynamic> tracks;

  const AlbumTracksScreen({

    super.key,

    required this.albumName,

    required this.tracks,

  });

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: MyfyTheme.darkBackground,

      appBar: AppBar(

        title: Text(albumName),

        leading: IconButton(

          icon: const Icon(Icons.arrow_back_ios_new_rounded),

          onPressed: () => Navigator.pop(context),

        ),

      ),

      body: tracks.isEmpty

          ? const Center(

              child: Text('No tracks found', style: TextStyle(color: MyfyTheme.textSecondary)),

            )

          : ListView.builder(

              padding: const EdgeInsets.symmetric(vertical: 8),

              itemCount: tracks.length,

              itemBuilder: (context, index) {

                final track = tracks[index];

                final song = SongModel.fromItunesJson(track);

                return SongTile(

                  song: song,

                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(builder: (_) => PlayerScreen(song: song)),

                    );

                  },

                );

              },

            ),

    );

  }

}