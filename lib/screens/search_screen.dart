import 'package:flutter/material.dart';

import '../utils/theme.dart';

import '../models/song_model.dart';

import '../services/api_service.dart';

import '../widgets/song_tile.dart';

import 'album_tracks_screen.dart';

class SearchScreen extends StatefulWidget {

  final VoidCallback onBackToHome;

  const SearchScreen({super.key, required this.onBackToHome});

  @override

  State<SearchScreen> createState() => _SearchScreenState();

}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {

  final TextEditingController _searchController = TextEditingController();

  final ApiService _apiService = ApiService();

  final FocusNode _focusNode = FocusNode();

  List<dynamic> _songResults = [];

  List<dynamic> _albumResults = [];

  bool _isLoading = false;

  bool _hasSearched = false;

  late TabController _tabController;

  @override

  void initState() {

    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {

      _focusNode.requestFocus();

    });

  }

  @override

  void dispose() {

    _searchController.dispose();

    _focusNode.dispose();

    _tabController.dispose();

    super.dispose();

  }

  Future<void> _performSearch() async {

    final query = _searchController.text.trim();

    if (query.isEmpty) return;

    setState(() {

      _isLoading = true;

      _hasSearched = true;

      _songResults = [];

      _albumResults = [];

    });

    try {

      final songs = await _apiService.searchSongs(query);

      final albums = await _apiService.searchMovies(query);

      setState(() {

        _songResults = songs;

        _albumResults = albums;

        _isLoading = false;

      });

    } catch (e) {

      setState(() {

        _songResults = [];

        _albumResults = [];

        _isLoading = false;

      });

    }

  }

  void _showDownloadOptions(BuildContext context, SongModel song) {

    showModalBottomSheet(

      context: context,

      backgroundColor: MyfyTheme.surfaceColor,

      shape: const RoundedRectangleBorder(

        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),

      ),

      builder: (context) {

        return Container(

          padding: const EdgeInsets.all(24),

          child: Column(

            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Row(

                children: [

                  Container(

                    width: 50,

                    height: 50,

                    decoration: BoxDecoration(

                      color: MyfyTheme.primaryOrange.withOpacity(0.2),

                      borderRadius: BorderRadius.circular(12),

                    ),

                    child: song.artworkUrl != null && song.artworkUrl!.isNotEmpty

                        ? ClipRRect(

                            borderRadius: BorderRadius.circular(12),

                            child: Image.network(song.artworkUrl!, fit: BoxFit.cover),

                          )

                        : const Icon(Icons.music_note_rounded, color: MyfyTheme.primaryOrange),

                  ),

                  const SizedBox(width: 16),

                  Expanded(

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Text(song.title,

                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),

                        Text(song.artist,

                            style: const TextStyle(color: MyfyTheme.textSecondary, fontSize: 14)),

                      ],

                    ),

                  ),

                ],

              ),

              const SizedBox(height: 24),

              const Text('Select Audio Quality',

                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),

              const SizedBox(height: 16),

              Wrap(

                spacing: 12,

                runSpacing: 12,

                children: [

                  _QualityOption(bitrate: '128', onTap: () => _downloadSong(song, '128')),

                  _QualityOption(bitrate: '160', onTap: () => _downloadSong(song, '160')),

                  _QualityOption(bitrate: '192', onTap: () => _downloadSong(song, '192')),

                  _QualityOption(bitrate: '256', onTap: () => _downloadSong(song, '256')),

                  _QualityOption(bitrate: '320', onTap: () => _downloadSong(song, '320'), recommended: true),

                ],

              ),

              const SizedBox(height: 20),

            ],

          ),

        );

      },

    );

  }

  void _downloadSong(SongModel song, String bitrate) async {

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Row(

          children: [

            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),

            const SizedBox(width: 12),

            Text('Downloading ${song.title} at ${bitrate}kbps...'),

          ],

        ),

        duration: const Duration(seconds: 2),

        backgroundColor: MyfyTheme.surfaceColor,

      ),

    );

    final result = await _apiService.downloadTrack(song.toJson(), bitrate);

    if (result['status'] == 'success') {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('✅ ${song.title} downloaded successfully!'), backgroundColor: Colors.green.shade800),

      );

    }

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: MyfyTheme.darkBackground,

      body: SafeArea(

        child: Column(

          children: [

            Container(

              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),

              decoration: BoxDecoration(

                color: MyfyTheme.darkBackground,

                border: Border(

                  bottom: BorderSide(

                    color: _hasSearched ? MyfyTheme.borderColor : Colors.transparent,

                  ),

                ),

              ),

              child: Row(

                children: [

                  IconButton(

                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),

                    onPressed: widget.onBackToHome,

                  ),

                  Expanded(

                    child: TextField(

                      controller: _searchController,

                      focusNode: _focusNode,

                      style: const TextStyle(color: Colors.white, fontSize: 16),

                      decoration: InputDecoration(

                        hintText: 'Search songs or movies...',

                        prefixIcon: const Icon(Icons.search_rounded, color: MyfyTheme.primaryOrange, size: 22),

                        suffixIcon: _searchController.text.isNotEmpty

                            ? IconButton(

                                icon: const Icon(Icons.clear_rounded, size: 20),

                                onPressed: () {

                                  _searchController.clear();

                                  setState(() {

                                    _songResults = [];

                                    _albumResults = [];

                                    _hasSearched = false;

                                  });

                                },

                              )

                            : null,

                        contentPadding: const EdgeInsets.symmetric(vertical: 12),

                      ),

                      onSubmitted: (_) => _performSearch(),

                      onChanged: (value) => setState(() {}),

                    ),

                  ),

                ],

              ),

            ),

            if (_hasSearched)

              Container(

                decoration: const BoxDecoration(

                  color: MyfyTheme.darkBackground,

                  border: Border(

                    bottom: BorderSide(color: MyfyTheme.borderColor, width: 0.5),

                  ),

                ),

                child: TabBar(

                  controller: _tabController,

                  indicator: BoxDecoration(color: Colors.transparent),

                  indicatorColor: MyfyTheme.primaryOrange,

                  labelColor: MyfyTheme.primaryOrange,

                  unselectedLabelColor: MyfyTheme.textSecondary,

                  tabs: const [

                    Tab(text: 'Songs'),

                    Tab(text: 'Albums'),

                  ],

                ),

              ),

            Expanded(

              child: _buildBody(),

            ),

          ],

        ),

      ),

    );

  }

  Widget _buildBody() {

    if (!_hasSearched) {

      return Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(Icons.search_rounded, size: 64, color: MyfyTheme.textSecondary.withOpacity(0.3)),

            const SizedBox(height: 16),

            Text('Search for your favorite music',

                style: TextStyle(color: MyfyTheme.textSecondary.withOpacity(0.7), fontSize: 15)),

          ],

        ),

      );

    }

    if (_isLoading) {

      return const Center(child: CircularProgressIndicator(color: MyfyTheme.primaryOrange));

    }

    return TabBarView(

      controller: _tabController,

      children: [

        _buildSongList(),

        _buildAlbumList(),

      ],

    );

  }

  Widget _buildSongList() {

    if (_songResults.isEmpty) {

      return const Center(

        child: Text('No songs found', style: TextStyle(color: MyfyTheme.textSecondary)),

      );

    }

    return ListView.builder(

      padding: const EdgeInsets.symmetric(vertical: 8),

      itemCount: _songResults.length,

      itemBuilder: (context, index) {

        final item = _songResults[index];

        final song = SongModel.fromItunesJson(item);

        return SongTile(

          song: song,

          onTap: () => _showDownloadOptions(context, song),

        );

      },

    );

  }

  Widget _buildAlbumList() {

    if (_albumResults.isEmpty) {

      return const Center(

        child: Text('No albums found', style: TextStyle(color: MyfyTheme.textSecondary)),

      );

    }

    return ListView.builder(

      padding: const EdgeInsets.symmetric(vertical: 8),

      itemCount: _albumResults.length,

      itemBuilder: (context, index) {

        final album = _albumResults[index];

        return _AlbumTile(

          album: album,

          onTap: () async {

            final tracks = await _apiService.getAlbumTracks(album['collectionId'].toString());

            Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) => AlbumTracksScreen(

                  albumName: album['collectionName'] ?? 'Unknown Album',

                  tracks: tracks,

                ),

              ),

            );

          },

        );

      },

    );

  }

}

class _AlbumTile extends StatelessWidget {

  final Map<String, dynamic> album;

  final VoidCallback onTap;

  const _AlbumTile({required this.album, required this.onTap});

  @override

  Widget build(BuildContext context) {

    final artworkUrl = album['artworkUrl100']?.toString().replaceAll('100x100bb', '300x300bb');

    return ListTile(

      onTap: onTap,

      leading: Container(

        width: 56,

        height: 56,

        decoration: BoxDecoration(

          color: MyfyTheme.primaryOrange.withOpacity(0.15),

          borderRadius: BorderRadius.circular(12),

        ),

        child: artworkUrl != null

            ? ClipRRect(

                borderRadius: BorderRadius.circular(12),

                child: Image.network(artworkUrl, fit: BoxFit.cover),

              )

            : const Icon(Icons.album_rounded, color: MyfyTheme.primaryOrange, size: 28),

      ),

      title: Text(

        album['collectionName'] ?? 'Unknown Album',

        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),

        maxLines: 1,

        overflow: TextOverflow.ellipsis,

      ),

      subtitle: Text(

        album['artistName'] ?? 'Unknown Artist',

        style: const TextStyle(color: MyfyTheme.textSecondary),

        maxLines: 1,

        overflow: TextOverflow.ellipsis,

      ),

    );

  }

}

class _QualityOption extends StatelessWidget {

  final String bitrate;

  final VoidCallback onTap;

  final bool recommended;

  const _QualityOption({required this.bitrate, required this.onTap, this.recommended = false});

  @override

  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),

        decoration: BoxDecoration(

          color: recommended ? MyfyTheme.primaryOrange.withOpacity(0.15) : MyfyTheme.darkBackground,

          borderRadius: BorderRadius.circular(12),

          border: Border.all(color: recommended ? MyfyTheme.primaryOrange : MyfyTheme.borderColor, width: recommended ? 1.5 : 1),

        ),

        child: Column(

          children: [

            Text(bitrate,

                style: TextStyle(color: recommended ? MyfyTheme.primaryOrange : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),

            Text('kbps',

                style: TextStyle(color: recommended ? MyfyTheme.primaryOrange.withOpacity(0.8) : MyfyTheme.textSecondary, fontSize: 12)),

            if (recommended)

              Container(

                margin: const EdgeInsets.only(top: 4),

                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),

                decoration: BoxDecoration(color: MyfyTheme.primaryOrange, borderRadius: BorderRadius.circular(4)),

                child: const Text('BEST', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),

              ),

          ],

        ),

      ),

    );

  }

}