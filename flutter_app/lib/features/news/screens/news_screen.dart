import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/widgets/error_screen.dart';
import '../../../core/widgets/content_card.dart';

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
        title: const Text('News'),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _newsList.isEmpty
              ? const Center(child: Text('No news available.'))
              : RefreshIndicator(
        onRefresh: _fetchNews,
        child: ListView.builder(
          itemCount: _newsList.length,
          itemBuilder: (context, index) {
            final news = _newsList[index];
            return ContentCard(
              padding: EdgeInsets.zero, // ContentCard has default padding, but we want zero for the image
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (news['image'] != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CachedNetworkImage(
                          imageUrl: news['image'].toString(),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.error, size: 40),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          news['title'] ?? 'No Title',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (news['description'] != null) ...[
                          Text(
                            news['description'] ?? '',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
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
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
