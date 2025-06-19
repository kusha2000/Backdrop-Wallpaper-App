import 'package:client/services/fav_service.dart';
import 'package:flutter/material.dart';
import 'package:async_wallpaper/async_wallpaper.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with TickerProviderStateMixin {
  final FavoriteService _favoriteService = FavoriteService();
  List<dynamic> favoriteWallpapers = [];
  bool _isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Color scheme
  final Color primaryColor = const Color(0xFF7C3AED);
  final Color secondaryColor = const Color(0xFF06B6D4);
  final Color backgroundColor = const Color(0xFF0F0F23);
  final Color surfaceColor = const Color(0xFF1E1E2E);
  final Color cardColor = const Color(0xFF2D2D42);
  final Color textColor = const Color(0xFFE5E7EB);
  final Color subtitleColor = const Color(0xFF9CA3AF);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    fetchFavoriteWallpapers();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> fetchFavoriteWallpapers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<dynamic> favorites = await _favoriteService.getFavorites();
      setState(() {
        favoriteWallpapers = favorites;
      });
      _fadeController.forward();
    } catch (e) {
      print("Error fetching favorite wallpapers: $e");
      _showSnackBar('Failed to load favorites', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> removeFromFavorites(String id) async {
    try {
      await _favoriteService.removeFromFavorites(id);
      setState(() {
        favoriteWallpapers.removeWhere((wallpaper) => wallpaper['id'] == id);
      });
      _showSnackBar('Removed from favorites', icon: Icons.favorite_border);
    } catch (e) {
      print("Error removing from favorites: $e");
      _showSnackBar('Failed to remove from favorites', isError: true);
    }
  }

  Future<void> _setWallpaper(String url) async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool result = await AsyncWallpaper.setWallpaper(
        url: url,
        wallpaperLocation: AsyncWallpaper.BOTH_SCREENS,
        toastDetails: ToastDetails.success(),
        errorToastDetails: ToastDetails.error(),
        goToHome: true,
      );

      _showSnackBar(
        result ? 'Wallpaper set successfully!' : 'Failed to set wallpaper',
        isError: !result,
        icon: result ? Icons.wallpaper : null,
      );
    } catch (e) {
      print("Failed to set wallpaper: $e");
      _showSnackBar('Failed to set wallpaper. Please try again.',
          isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false, IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: surfaceColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.favorite_border,
              size: 64,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding wallpapers to your favorites\nto see them here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: subtitleColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWallpaperCard(dynamic wallpaper, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image with gradient overlay
            Stack(
              children: [
                Container(
                  height: 250,
                  child: Image.network(
                    wallpaper['url'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 250,
                        color: surfaceColor,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: surfaceColor,
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: subtitleColor,
                        ),
                      );
                    },
                  ),
                ),
                // Gradient overlay at the bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          cardColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    wallpaper['description'] ?? 'Beautiful Wallpaper',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Photographer info with icon
                  Row(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: secondaryColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "by ${wallpaper['photographer'] ?? 'Unknown'}",
                          style: TextStyle(
                            fontSize: 14,
                            color: subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      // Remove button
                      Expanded(
                        child: Container(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                removeFromFavorites(wallpaper['id']),
                            icon: const Icon(
                              Icons.favorite,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: const Text('Remove'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Set wallpaper button
                      Expanded(
                        child: Container(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _setWallpaper(wallpaper['url']),
                            icon: const Icon(
                              Icons.wallpaper,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: const Text('Set'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (favoriteWallpapers.isNotEmpty)
            IconButton(
              onPressed: fetchFavoriteWallpapers,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your favorites...',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : favoriteWallpapers.isEmpty
              ? _buildEmptyState()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: favoriteWallpapers.length,
                    itemBuilder: (context, index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        curve: Curves.easeOutBack,
                        child: _buildWallpaperCard(
                            favoriteWallpapers[index], index),
                      );
                    },
                  ),
                ),
    );
  }
}
