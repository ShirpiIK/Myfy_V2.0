import 'dart:io';                     // 🟢 File-க்கு தேவை

import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';

import 'package:path_provider/path_provider.dart';

import '../utils/theme.dart';

import '../models/song_model.dart';

class PlayerScreen extends StatefulWidget {

  final SongModel song;

  const PlayerScreen({super.key, required this.song});

  @override

  State<PlayerScreen> createState() => _PlayerScreenState();

}

class _PlayerScreenState extends State<PlayerScreen> {

  late AudioPlayer _player;

  bool _isPlaying = false;

  Duration _duration = Duration.zero;

  Duration _position = Duration.zero;

  Uint8List? _coverBytes;

  bool _shuffleEnabled = false;

  LoopMode _loopMode = LoopMode.off;   // 🟢 RepeatMode → LoopMode
 
  List<SongModel> _playlist = [];
    
  int _currentIndex = 0;  
    
  @override

  void initState() {

    super.initState();

    _player = AudioPlayer();

    _initPlayer();

  }

  Future<void> _initPlayer() async {

    try {

      if (widget.song.isDownloaded && widget.song.localPath != null) {

        await _player.setFilePath(widget.song.localPath!);

        final file = File(widget.song.localPath!);

        final metadata = await readMetadata(file, getImage: true);

        if (metadata.pictures.isNotEmpty) {

          setState(() => _coverBytes = metadata.pictures.first.bytes);

        }

      }

      _player.durationStream.listen((d) => setState(() => _duration = d ?? Duration.zero));

      _player.positionStream.listen((p) => setState(() => _position = p));

      _player.playbackEventStream.listen((event) {

        setState(() => _isPlaying = _player.playing);

      });

      await _player.play();

    } catch (e) {

      debugPrint("Error loading audio: $e");

    }

  }

  @override

  void dispose() {

    //_player.dispose();

    super.dispose();

  }

  String _formatDuration(Duration d) {

    final minutes = d.inMinutes.remainder(60);

    final seconds = d.inSeconds.remainder(60);

    return '${d.inHours > 0 ? '${d.inHours}:' : ''}${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: MyfyTheme.darkBackground,

      appBar: AppBar(

        leading: IconButton(icon: const Icon(Icons.keyboard_arrow_down_rounded), onPressed: () => Navigator.pop(context)),

        title: Text(widget.song.title, maxLines: 1),

      ),

      body: Padding(

        padding: const EdgeInsets.all(24),

        child: Column(

          children: [

            const Spacer(),

            Container(

              width: 300,

              height: 300,

              decoration: BoxDecoration(

                gradient: LinearGradient(colors: [MyfyTheme.primaryOrange.withOpacity(0.8), MyfyTheme.primaryOrange]),

                borderRadius: BorderRadius.circular(24),

                boxShadow: [BoxShadow(color: MyfyTheme.primaryOrange.withOpacity(0.4), blurRadius: 40, spreadRadius: 5)],

              ),

              child: _buildCoverImage(),

            ),

            const SizedBox(height: 40),

            Text(widget.song.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),

            const SizedBox(height: 8),

            Text(widget.song.artist, style: const TextStyle(color: MyfyTheme.textSecondary, fontSize: 18)),

            const SizedBox(height: 32),

            Column(

              children: [

                Slider(

                  value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),

                  max: _duration.inSeconds.toDouble(),

                  onChanged: (value) async => await _player.seek(Duration(seconds: value.toInt())),

                  activeColor: MyfyTheme.primaryOrange,

                ),

                Padding(

                  padding: const EdgeInsets.symmetric(horizontal: 8),

                  child: Row(

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [

                      Text(_formatDuration(_position), style: const TextStyle(color: MyfyTheme.textSecondary)),

                      Text(_formatDuration(_duration), style: const TextStyle(color: MyfyTheme.textSecondary)),

                    ],

                  ),

                ),

              ],

            ),

            const SizedBox(height: 24),

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [

                IconButton(

                  icon: Icon(_shuffleEnabled ? Icons.shuffle_rounded : Icons.shuffle_on_rounded, color: _shuffleEnabled ? MyfyTheme.primaryOrange : MyfyTheme.textSecondary),

                  onPressed: () {

                    setState(() => _shuffleEnabled = !_shuffleEnabled);

                    _player.setShuffleModeEnabled(_shuffleEnabled);

                  },

                ),

                IconButton(icon: const Icon(Icons.skip_previous_rounded, color: Colors.white), onPressed: () {}),

                Container(

                  width: 64,

                  height: 64,

                  decoration: BoxDecoration(color: MyfyTheme.primaryOrange, shape: BoxShape.circle),

                  child: IconButton(

                    icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 36),

                    onPressed: () => _isPlaying ? _player.pause() : _player.play(),

                  ),

                ),

                IconButton(icon: const Icon(Icons.skip_next_rounded, color: Colors.white), onPressed: () {}),

                IconButton(

                  icon: Icon(_loopMode == LoopMode.off ? Icons.repeat_rounded : Icons.repeat_one_rounded, color: _loopMode != LoopMode.off ? MyfyTheme.primaryOrange : MyfyTheme.textSecondary),

                  onPressed: () {

                    setState(() {

                      _loopMode = _loopMode == LoopMode.off ? LoopMode.all : LoopMode.off;

                    });

                    _player.setLoopMode(_loopMode);

                  },

                ),

              ],

            ),

            const Spacer(),

          ],

        ),

      ),

    );

  }

  Widget _buildCoverImage() {

    if (_coverBytes != null) {

      return ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.memory(_coverBytes!, fit: BoxFit.cover));

    } else if (widget.song.artworkUrl != null && widget.song.artworkUrl!.isNotEmpty) {

      if (widget.song.artworkUrl!.startsWith('http')) {

        return ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.network(widget.song.artworkUrl!, fit: BoxFit.cover));

      } else {

        return ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.file(File(widget.song.artworkUrl!), fit: BoxFit.cover));

      }

    } else {

      return const Icon(Icons.music_note_rounded, size: 120, color: Colors.white);

    }

  }

}