import 'dart:io';                     // 🟢 File-க்கு தேவை

import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';

import 'package:path_provider/path_provider.dart';

import '../utils/theme.dart';

import '../models/song_model.dart';

import '../widgets/song_tile.dart';

import 'player_screen.dart';

enum SortType { ascending, descending, newest, oldest }

class LibraryScreen extends StatefulWidget {

  final Function(SongModel) onPlaySong;

  const LibraryScreen({super.key, required this.onPlaySong});

  @override

  State<LibraryScreen> createState() => _LibraryScreenState();

}

class _LibraryScreenState extends State<LibraryScreen> {

  int _selectedFilter = 0;

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  List<Playlist> _playlists = [];

  List<SongModel> _allDownloadedSongs = [];

  bool _isLoadingLocal = false;

  SortType _currentSort = SortType.ascending;

  @override

  void initState() {

    super.initState();

    _loadLocalSongs();

  }

  Future<void> _loadLocalSongs() async {

    setState(() => _isLoadingLocal = true);

    if (!await Permission.storage.isGranted && !await Permission.manageExternalStorage.isGranted) {

      await [Permission.storage, Permission.manageExternalStorage].request();

    }

    try {

      final directory = Directory('/storage/emulated/0/Download/Myfy');

      if (directory.existsSync()) {

        final files = directory.listSync().where((f) => f.path.endsWith('.mp3')).toList();

        List<SongModel> songs = [];

        for (var file in files) {

          try {

            final metadata = await readMetadata(File(file.path), getImage: true);

            final stat = file.statSync();

            String? artworkPath;

            if (metadata.pictures.isNotEmpty) {

              final picture = metadata.pictures.first;

              final tempDir = await getTemporaryDirectory();

              final artFile = File('${tempDir.path}/${file.path.hashCode}.jpg');

              await artFile.writeAsBytes(picture.bytes);

              artworkPath = artFile.path;

            }

            songs.add(SongModel(

              id: file.path,

              title: metadata.title ?? file.path.split('/').last.replaceAll('.mp3', ''),

              artist: metadata.artist ?? 'Unknown Artist',

              album: metadata.album ?? 'Unknown Album',

              artworkUrl: artworkPath,

              durationMs: metadata.duration?.inMilliseconds ?? 0,

              isDownloaded: true,

              localPath: file.path,

              modifiedTime: stat.modified,

            ));

          } catch (e) {

            final stat = file.statSync();

            songs.add(SongModel(

              id: file.path,

              title: file.path.split('/').last.replaceAll('.mp3', ''),

              artist: 'Unknown Artist',

              album: 'Myfy Downloads',

              durationMs: 0,

              isDownloaded: true,

              localPath: file.path,

              modifiedTime: stat.modified,

            ));

          }

        }

        setState(() => _allDownloadedSongs = songs);

      }

    } catch (e) {

      debugPrint('Local scan error: $e');

    }

    setState(() => _isLoadingLocal = false);

  }

  Future<void> _createNewPlaylist() async {

    final nameController = TextEditingController();

    return showDialog(

      context: context,

      builder: (context) => AlertDialog(

        backgroundColor: MyfyTheme.surfaceColor,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: const Text('Create Playlist', style: TextStyle(color: Colors.white)),

        content: TextField(

          controller: nameController,

          style: const TextStyle(color: Colors.white),

          decoration: InputDecoration(

            hintText: 'Playlist Name',

            hintStyle: const TextStyle(color: MyfyTheme.textSecondary),

            filled: true,

            fillColor: MyfyTheme.darkBackground,

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),

          ),

        ),

        actions: [

          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),

          ElevatedButton(

            style: ElevatedButton.styleFrom(backgroundColor: MyfyTheme.primaryOrange, foregroundColor: Colors.white),

            onPressed: () {

              if (nameController.text.trim().isNotEmpty) {

                setState(() => _playlists.add(Playlist(name: nameController.text.trim())));

                Navigator.pop(context);

              }

            },

            child: const Text('Create'),

          ),

        ],

      ),

    );

  }

  List<dynamic> _getFilteredAndSortedItems() {

    List<dynamic> items;

    switch (_selectedFilter) {

      case 0:

        items = _playlists;

        break;

      case 1:

        final albumMap = <String, List<SongModel>>{};

        for (var song in _allDownloadedSongs) {

          albumMap.putIfAbsent(song.album, () => []).add(song);

        }

        items = albumMap.entries.map((e) => AlbumGroup(name: e.key, songs: e.value)).toList();

        break;

      case 2:

        final artistMap = <String, List<SongModel>>{};

        for (var song in _allDownloadedSongs) {

          artistMap.putIfAbsent(song.artist, () => []).add(song);

        }

        items = artistMap.entries.map((e) => ArtistGroup(name: e.key, songs: e.value)).toList();

        break;

      case 3:

        items = _allDownloadedSongs;

        break;

      default:

        items = [];

    }

    if (_searchQuery.isNotEmpty && (_selectedFilter == 3)) {

      items = (items as List<SongModel>).where((song) => song.title.toLowerCase().contains(_searchQuery.toLowerCase()) || song.artist.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    }

    items = _sortItems(items);

    return items;

  }

  List<dynamic> _sortItems(List<dynamic> items) {

    if (items.isEmpty) return items;

    if (items.first is SongModel) {

      List<SongModel> songs = items.cast<SongModel>();

      switch (_currentSort) {

        case SortType.ascending:

          songs.sort((a, b) => a.title.compareTo(b.title));

          break;

        case SortType.descending:

          songs.sort((a, b) => b.title.compareTo(a.title));

          break;

        case SortType.newest:

          songs.sort((a, b) => (b.modifiedTime ?? DateTime(1970)).compareTo(a.modifiedTime ?? DateTime(1970)));

          break;

        case SortType.oldest:

          songs.sort((a, b) => (a.modifiedTime ?? DateTime(1970)).compareTo(b.modifiedTime ?? DateTime(1970)));

          break;

      }

      return songs;

    } else if (items.first is AlbumGroup) {

      List<AlbumGroup> groups = items.cast<AlbumGroup>();

      groups.sort((a, b) => a.name.compareTo(b.name));

      return groups;

    } else if (items.first is ArtistGroup) {

      List<ArtistGroup> groups = items.cast<ArtistGroup>();

      groups.sort((a, b) => a.name.compareTo(b.name));

      return groups;

    } else if (items.first is Playlist) {

      List<Playlist> playlists = items.cast<Playlist>();

      playlists.sort((a, b) => a.name.compareTo(b.name));

      return playlists;

    }

    return items;

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: MyfyTheme.darkBackground,

      body: SafeArea(

        child: Column(

          children: [

            Padding(

              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),

              child: Row(

                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [

                  Text('Your Library', style: Theme.of(context).textTheme.titleLarge),

                  Row(

                    children: [

                      IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),

                      IconButton(icon: const Icon(Icons.add_rounded), onPressed: _createNewPlaylist),

                    ],

                  ),

                ],

              ),

            ),

            Padding(

              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

              child: TextField(

                controller: _searchController,

                style: const TextStyle(color: Colors.white),

                decoration: InputDecoration(

                  hintText: 'Search in Library...',

                  hintStyle: const TextStyle(color: MyfyTheme.textSecondary),

                  prefixIcon: const Icon(Icons.search, color: MyfyTheme.primaryOrange),

                  suffixIcon: _searchController.text.isNotEmpty

                      ? IconButton(

                          icon: const Icon(Icons.clear, color: MyfyTheme.textSecondary),

                          onPressed: () {

                            _searchController.clear();

                            setState(() => _searchQuery = '');

                          },

                        )

                      : null,

                  filled: true,

                  fillColor: MyfyTheme.surfaceColor,

                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),

                  contentPadding: const EdgeInsets.symmetric(vertical: 12),

                ),

                onChanged: (value) => setState(() => _searchQuery = value),

              ),

            ),

            Padding(

              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Row(

                children: [

                  Expanded(

                    child: SingleChildScrollView(

                      scrollDirection: Axis.horizontal,

                      child: Row(

                        children: [

                          _FilterChip(label: 'Playlists', active: _selectedFilter == 0, onTap: () => setState(() => _selectedFilter = 0)),

                          const SizedBox(width: 8),

                          _FilterChip(label: 'Albums', active: _selectedFilter == 1, onTap: () => setState(() => _selectedFilter = 1)),

                          const SizedBox(width: 8),

                          _FilterChip(label: 'Artists', active: _selectedFilter == 2, onTap: () => setState(() => _selectedFilter = 2)),

                          const SizedBox(width: 8),

                          _FilterChip(label: 'Downloaded', active: _selectedFilter == 3, onTap: () => setState(() => _selectedFilter = 3)),

                        ],

                      ),

                    ),

                  ),

                  PopupMenuButton<SortType>(

                    icon: const Icon(Icons.sort_rounded, color: MyfyTheme.primaryOrange),

                    onSelected: (SortType type) => setState(() => _currentSort = type),

                    itemBuilder: (context) => [

                      const PopupMenuItem(value: SortType.ascending, child: Text('Ascending (A-Z)')),

                      const PopupMenuItem(value: SortType.descending, child: Text('Descending (Z-A)')),

                      const PopupMenuItem(value: SortType.newest, child: Text('Newest First')),

                      const PopupMenuItem(value: SortType.oldest, child: Text('Oldest First')),

                    ],

                  ),

                ],

              ),

            ),

            Expanded(child: _buildContent()),

          ],

        ),

      ),

    );

  }

  Widget _buildContent() {

    final items = _getFilteredAndSortedItems();

    if (_isLoadingLocal) {

      return const Center(child: CircularProgressIndicator(color: MyfyTheme.primaryOrange));

    }

    if (items.isEmpty) {

      return Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(_selectedFilter == 0 ? Icons.playlist_play_rounded : Icons.music_note_rounded, size: 64, color: MyfyTheme.textSecondary.withOpacity(0.5)),

            const SizedBox(height: 16),

            Text(

              _selectedFilter == 0 ? 'No playlists yet' : _selectedFilter == 3 ? 'No downloaded songs found' : 'Nothing here yet',

              style: const TextStyle(color: MyfyTheme.textSecondary, fontSize: 16),

            ),

          ],

        ),

      );

    }

    return ListView.builder(

      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),

      itemCount: items.length,

      itemBuilder: (context, index) {

        final item = items[index];

        if (item is Playlist) {

          return _PlaylistTile(playlist: item);

        } else if (item is AlbumGroup) {

          return _GroupTile(

            title: item.name,

            subtitle: '${item.songs.length} songs',

            icon: Icons.album_rounded,

            onTap: () => _showSongsList(context, item.songs, item.name),

          );

        } else if (item is ArtistGroup) {

          return _GroupTile(

            title: item.name,

            subtitle: '${item.songs.length} songs',

            icon: Icons.person_rounded,

            onTap: () => _showSongsList(context, item.songs, item.name),

          );

        } else if (item is SongModel) {

          return SongTile(

            song: item,

            onTap: () {

              widget.onPlaySong(item);

              Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(song: item)));

            },

          );

        }

        return const SizedBox();

      },

    );

  }

  void _showSongsList(BuildContext context, List<SongModel> songs, String title) {

    showModalBottomSheet(

      context: context,

      backgroundColor: MyfyTheme.surfaceColor,

      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),

      builder: (context) => Container(

        height: MediaQuery.of(context).size.height * 0.7,

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),

            Expanded(

              child: ListView.builder(

                itemCount: songs.length,

                itemBuilder: (ctx, i) {

                  final song = songs[i];

                  return SongTile(

                    song: song,

                    onTap: () {

                      Navigator.pop(context);

                      widget.onPlaySong(song);

                      Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(song: song)));

                    },

                  );

                },

              ),

            ),

          ],

        ),

      ),

    );

  }

}

class Playlist {

  final String name;

  final List<SongModel> songs;

  Playlist({required this.name, this.songs = const []});

}

class AlbumGroup {

  final String name;

  final List<SongModel> songs;

  AlbumGroup({required this.name, required this.songs});

}

class ArtistGroup {

  final String name;

  final List<SongModel> songs;

  ArtistGroup({required this.name, required this.songs});

}

class _FilterChip extends StatelessWidget {

  final String label;

  final bool active;

  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.active, required this.onTap});

  @override

  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        decoration: BoxDecoration(

          color: active ? MyfyTheme.primaryOrange : MyfyTheme.surfaceColor,

          borderRadius: BorderRadius.circular(20),

        ),

        child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.white70, fontWeight: FontWeight.w500)),

      ),

    );

  }

}

class _PlaylistTile extends StatelessWidget {

  final Playlist playlist;

  const _PlaylistTile({required this.playlist});

  @override

  Widget build(BuildContext context) {

    return ListTile(

      leading: Container(

        width: 50,

        height: 50,

        decoration: BoxDecoration(

          gradient: LinearGradient(colors: [MyfyTheme.primaryOrange.withOpacity(0.7), MyfyTheme.primaryOrange]),

          borderRadius: BorderRadius.circular(12),

        ),

        child: const Icon(Icons.playlist_play_rounded, color: Colors.white),

      ),

      title: Text(playlist.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),

      onTap: () {},

    );

  }

}

class _GroupTile extends StatelessWidget {

  final String title;

  final String subtitle;

  final IconData icon;

  final VoidCallback onTap;

  const _GroupTile({required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override

  Widget build(BuildContext context) {

    return ListTile(

      leading: Container(

        width: 50,

        height: 50,

        decoration: BoxDecoration(color: MyfyTheme.primaryOrange.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),

        child: Icon(icon, color: MyfyTheme.primaryOrange),

      ),

      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),

      subtitle: Text(subtitle, style: const TextStyle(color: MyfyTheme.textSecondary)),

      onTap: onTap,

    );

  }

}