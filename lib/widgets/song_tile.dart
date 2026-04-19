import 'dart:io'; // 🟢 File-க்கு இது தேவை

import 'package:flutter/material.dart';

import '../utils/theme.dart';

import '../models/song_model.dart';

class SongTile extends StatelessWidget {

  final SongModel song;

  final VoidCallback onTap;

  const SongTile({

    super.key,

    required this.song,

    required this.onTap,

  });

  @override

  Widget build(BuildContext context) {

    return ListTile(

      onTap: onTap,

      leading: Container(

        width: 50,

        height: 50,

        decoration: BoxDecoration(

          color: MyfyTheme.primaryOrange.withOpacity(0.15),

          borderRadius: BorderRadius.circular(12),

        ),

        child: song.artworkUrl != null && song.artworkUrl!.isNotEmpty

            ? ClipRRect(

                borderRadius: BorderRadius.circular(12),

                child: song.artworkUrl!.startsWith('http')

                    ? Image.network(

                        song.artworkUrl!,

                        fit: BoxFit.cover,

                        errorBuilder: (_, __, ___) => const Icon(

                          Icons.music_note_rounded,

                          color: MyfyTheme.primaryOrange,

                          size: 28,

                        ),

                      )

                    : Image.file(

                        File(song.artworkUrl!), // 🟢 File() இப்போது வேலை செய்யும்

                        fit: BoxFit.cover,

                        errorBuilder: (_, __, ___) => const Icon(

                          Icons.music_note_rounded,

                          color: MyfyTheme.primaryOrange,

                          size: 28,

                        ),

                      ),

              )

            : const Icon(

                Icons.music_note_rounded,

                color: MyfyTheme.primaryOrange,

                size: 28,

              ),

      ),

      title: Text(

        song.title,

        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),

        maxLines: 1,

        overflow: TextOverflow.ellipsis,

      ),

      subtitle: Text(

        song.artist,

        style: const TextStyle(color: MyfyTheme.textSecondary),

        maxLines: 1,

        overflow: TextOverflow.ellipsis,

      ),

      trailing: IconButton(

        icon: const Icon(Icons.more_vert_rounded, color: MyfyTheme.textSecondary),

        onPressed: () {

          showModalBottomSheet(

            context: context,

            backgroundColor: MyfyTheme.surfaceColor,

            shape: const RoundedRectangleBorder(

              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),

            ),

            builder: (context) => Column(

              mainAxisSize: MainAxisSize.min,

              children: [

                const SizedBox(height: 8),

                Container(

                  width: 40,

                  height: 4,

                  decoration: BoxDecoration(

                    color: MyfyTheme.textSecondary.withOpacity(0.3),

                    borderRadius: BorderRadius.circular(2),

                  ),

                ),

                ListTile(

                  leading: const Icon(Icons.download_rounded, color: MyfyTheme.primaryOrange),

                  title: const Text('Download', style: TextStyle(color: Colors.white)),

                  onTap: () => Navigator.pop(context),

                ),

                ListTile(

                  leading: const Icon(Icons.playlist_add_rounded, color: MyfyTheme.primaryOrange),

                  title: const Text('Add to Playlist', style: TextStyle(color: Colors.white)),

                  onTap: () => Navigator.pop(context),

                ),

                ListTile(

                  leading: const Icon(Icons.queue_music_rounded, color: MyfyTheme.primaryOrange),

                  title: const Text('Add to Queue', style: TextStyle(color: Colors.white)),

                  onTap: () => Navigator.pop(context),

                ),

                const SizedBox(height: 20),

              ],

            ),

          );

        },

      ),

    );

  }

}