class SongModel {

  final String id;

  final String title;

  final String artist;

  final String album;

  final String? artworkUrl;

  final int durationMs;

  final bool isDownloaded;

  final String? localPath;

  final DateTime? modifiedTime;  // 🆕 வரிசைப்படுத்த பயன்படும்

  SongModel({

    required this.id,

    required this.title,

    required this.artist,

    required this.album,

    this.artworkUrl,

    required this.durationMs,

    this.isDownloaded = false,

    this.localPath,

    this.modifiedTime,

  });

  factory SongModel.fromItunesJson(Map<String, dynamic> json) {

    return SongModel(

      id: json['trackId']?.toString() ?? '',

      title: json['trackName'] ?? 'Unknown',

      artist: json['artistName'] ?? 'Unknown',

      album: json['collectionName'] ?? 'Unknown',

      artworkUrl: json['artworkUrl100']?.toString().replaceAll('100x100bb', '600x600bb'),

      durationMs: json['trackTimeMillis'] ?? 0,

    );

  }

  Map<String, dynamic> toJson() => {

        'trackName': title,

        'artistName': artist,

        'collectionName': album,

        'trackTimeMillis': durationMs,

        'artworkUrl100': artworkUrl,

      };

}