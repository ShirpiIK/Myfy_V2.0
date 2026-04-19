import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart';

class ApiService {

  static String baseUrl = 'http://127.0.0.1:5000';

  final Dio _dio = Dio(BaseOptions(

    baseUrl: baseUrl,

    connectTimeout: const Duration(seconds: 30),

    receiveTimeout: const Duration(minutes: 5),

  ));

  ApiService() {

    if (kDebugMode) {

      _dio.interceptors.add(LogInterceptor(

        request: true,

        requestHeader: true,

        requestBody: true,

        responseHeader: true,

        responseBody: true,

        error: true,

      ));

    }

  }

  // 🟢 SEARCH SONGS (iTunes API via Termux)

  Future<List<dynamic>> searchSongs(String query, {int page = 1, int limit = 20}) async {

    try {

      final response = await _dio.post(

        '/api/search_song',

        data: {'song_name': query, 'page': page, 'limit': limit},

      );

      return response.data['results'] ?? [];

    } on DioException catch (e) {

      debugPrint('🔴 searchSongs Error: ${e.message}');

      return [];

    }

  }

  // 🟢 SEARCH MOVIES/ALBUMS (iTunes API via Termux)

  Future<List<dynamic>> searchMovies(String query, {int page = 1, int limit = 20}) async {

    try {

      final response = await _dio.post(

        '/api/search_movie',

        data: {'movie_name': query, 'page': page, 'limit': limit},

      );

      return response.data['results'] ?? [];

    } on DioException catch (e) {

      debugPrint('🔴 searchMovies Error: ${e.message}');

      return [];

    }

  }

  // 🟢 GET ALBUM TRACKS

  Future<List<dynamic>> getAlbumTracks(String albumId) async {

    try {

      final response = await _dio.post(

        '/api/album_tracks',

        data: {'album_id': albumId},

      );

      final results = response.data['tracks'] ?? [];

      return results.skip(1).toList();

    } on DioException catch (e) {

      debugPrint('🔴 getAlbumTracks Error: ${e.message}');

      return [];

    }

  }

  // 🟢 DOWNLOAD TRACK

  Future<Map<String, dynamic>> downloadTrack(Map<String, dynamic> track, String bitrate) async {

    try {

      final response = await _dio.post(

        '/api/download_track',

        data: {'track': track, 'bitrate': bitrate},

      );

      return response.data;

    } on DioException catch (e) {

      debugPrint('🔴 downloadTrack Error: ${e.message}');

      return {'status': 'error', 'message': e.message};

    }

  }

  // 🟢 DIRECT YOUTUBE MUSIC SEARCH (Fallback)

  Future<List<dynamic>> searchYtMusic(String query) async {

    try {

      final response = await _dio.post(

        '/api/search_yt',

        data: {'query': query},

      );

      return response.data['results'] ?? [];

    } on DioException catch (e) {

      debugPrint('🔴 searchYtMusic Error: ${e.message}');

      return [];

    }

  }

}