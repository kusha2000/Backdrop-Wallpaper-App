import 'package:client/models/wallpaper.dart';
import 'package:client/widgets/reusable/custom_button.dart';
import 'package:flutter/material.dart';

class WallpaperDetailsPage extends StatelessWidget {
  final Wallpaper wallpaper;

  WallpaperDetailsPage({required this.wallpaper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallpaper Details"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              wallpaper.url,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallpaper.description,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Photographer: ${wallpaper.photographer}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  wallpaper.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  isLoading: false,
                  onPressed: () {},
                  labelText: "Add to Favorites",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
