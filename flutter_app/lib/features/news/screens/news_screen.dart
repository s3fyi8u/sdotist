import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/widgets/error_screen.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/animated_hover_card.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/l10n/app_localizations.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _newsList = [];
  bool _isLoading = true;
  AppError? _error;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.dio.get(ApiConstants.news);
      if (mounted) {
        setState(() {
          _newsList = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = ErrorMapper.map(e);
        });
      }
    }
  }

  /// Get all image URLs for a news item (from images list or legacy single image)
  List<String> _getNewsImages(Map<String, dynamic> news) {
    final List<String> imageUrls = [];
    
    // Check for new images list first
    if (news['images'] != null && (news['images'] as List).isNotEmpty) {
      for (var img in news['images']) {
        if (img is Map && img['image_url'] != null) {
          imageUrls.add(img['image_url'].toString());
        }
      }
    }
    
    // Fallback to legacy single image if no images list
    if (imageUrls.isEmpty && news['image'] != null) {
      imageUrls.add(news['image'].toString());
    }
    
    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorScreen(
        error: _error!,
        onRetry: _fetchNews,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('news')),
        centerTitle: false,
      ),
      body: _isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ShimmerLoading(
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                );
              },
            )
          : _newsList.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.article_outlined,
                  title: AppLocalizations.of(context).translate('no_news'),
                  subtitle: 'No articles have been published yet. Please check back later.',
                  onAction: _fetchNews,
                  actionLabel: AppLocalizations.of(context).translate('try_again'),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNews,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 650) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: constraints.maxWidth >= 1200 ? 3 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _newsList.length,
                          itemBuilder: (context, index) {
                            return _buildNewsCard(context, _newsList[index], isGrid: true);
                          },
                        );
                      } else {
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _newsList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildNewsCard(context, _newsList[index], isGrid: false),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
    );
  }

  Widget _buildNewsCard(BuildContext context, dynamic news, {bool isGrid = false}) {
    final images = _getNewsImages(news);
    Widget contentPlaceholder = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            news['title'] ?? 'No Title',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (news['description'] != null) ...[
            Text(
              news['description'] ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          if (isGrid)
            Expanded(
              child: Text(
                news['body'] ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            Text(
              news['body'] ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                news['created_at'] != null
                    ? news['created_at'].toString().substring(0, 10)
                    : '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ],
          ),
        ],
      ),
    );

    return AnimatedHoverCard(
      padding: EdgeInsets.zero,
      child: isGrid
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (images.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: _ImageCarousel(
                      images: images,
                      heroTag: 'news_image_${news['id']}',
                    ),
                  ),
                Expanded(child: contentPlaceholder),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (images.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: _ImageCarousel(
                      images: images,
                      heroTag: 'news_image_${news['id']}',
                    ),
                  ),
                contentPlaceholder,
              ],
            ),
    );
  }
}

/// Instagram-style image carousel with dot indicators
class _ImageCarousel extends StatefulWidget {
  final List<String> images;
  final String? heroTag;
  
  const _ImageCarousel({
    required this.images,
    this.heroTag,
  });

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    // Single image - no carousel needed
    if (widget.images.length == 1) {
      Widget imageWidget = CachedNetworkImage(
        imageUrl: widget.images[0],
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.error, size: 40),
        ),
      );

      if (widget.heroTag != null) {
        imageWidget = Hero(
          tag: widget.heroTag!,
          child: imageWidget,
        );
      }

      return AspectRatio(
        aspectRatio: 16 / 9,
        child: imageWidget,
      );
    }

    // Multiple images - carousel with dots
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.images[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, size: 40),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.images.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 8 : 6,
              height: _currentPage == index ? 8 : 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey[400],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
