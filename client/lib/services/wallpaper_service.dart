import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/models/wallpaper.dart';

class WallpaperService {
  final String _baseUrl = 'http://192.168.8.213:5000/api/wallpapers/search';

  Future<List<Wallpaper>> searchWallpapers(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl?query=$query'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['wallpapers'];
      return data
          .map((wallpaperJson) => Wallpaper.fromJson(wallpaperJson))
          .toList();
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}
