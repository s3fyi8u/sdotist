import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/representative.dart';
import '../services/representative_service.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/widgets/error_screen.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/animated_hover_card.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/web_navigation_bar.dart';
import '../../../core/l10n/app_localizations.dart';

class RepresentativeListScreen extends StatefulWidget {
  const RepresentativeListScreen({super.key});

  @override
  State<RepresentativeListScreen> createState() => _RepresentativeListScreenState();
}

class _RepresentativeListScreenState extends State<RepresentativeListScreen> {
  final RepresentativeService _service = RepresentativeService();
  late Future<List<UniversityRepresentative>> _representativesFuture;
  AppError? _error;

  Future<List<UniversityRepresentative>> _fetchRepresentatives() async {
    try {
      _error = null;
      return await _service.getRepresentatives();
    } catch (e) {
      _error = ErrorMapper.map(e);
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    _representativesFuture = _fetchRepresentatives();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileScaffold: _buildMobileScaffold(context),
      tabletScaffold: _buildMobileScaffold(context),
      desktopScaffold: _buildDesktopScaffold(context),
    );
  }

  Widget _buildDesktopScaffold(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WebNavigationBar(
            selectedIndex: -1,
            onItemTapped: (index) {
               if (index == 0) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                           BackButton(color: Theme.of(context).textTheme.bodyLarge?.color),
                           const SizedBox(width: 8),
                           Text(
                            AppLocalizations.of(context).translate('university_representatives'),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: FutureBuilder<List<UniversityRepresentative>>(
                          future: _representativesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return GridView.builder(
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 400,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 3, 
                                ),
                                itemCount: 6,
                                itemBuilder: (context, index) {
                                  return ShimmerLoading(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else if (snapshot.hasError) {
                              return ErrorScreen(
                                error: _error ?? ErrorMapper.map(snapshot.error),
                                onRetry: () {
                                  setState(() {
                                    _representativesFuture = _fetchRepresentatives();
                                  });
                                },
                              );
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(child: Text(AppLocalizations.of(context).translate('no_representatives')));
                            }

                            final representatives = snapshot.data!;
                            return GridView.builder(
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 3, // Wide card for rep
                              ),
                              itemCount: representatives.length,
                              itemBuilder: (context, index) {
                                return _buildRepCard(context, representatives[index]);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('university_representatives')),
      ),
      body: FutureBuilder<List<UniversityRepresentative>>(
        future: _representativesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return ShimmerLoading(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
             return ErrorScreen(
               error: _error ?? ErrorMapper.map(snapshot.error),
               onRetry: () {
                 setState(() {
                   _representativesFuture = _fetchRepresentatives();
                 });
               },
             );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context).translate('no_representatives')));
          }

          final representatives = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: representatives.length,
            itemBuilder: (context, index) {
              return _buildRepCard(context, representatives[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildRepCard(BuildContext context, UniversityRepresentative rep) {
    return AnimatedHoverCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            backgroundImage: rep.imageUrl != null
                ? CachedNetworkImageProvider(rep.imageUrl!)
                : null,
            child: rep.imageUrl == null
                ? Icon(Icons.person, size: 30, color: Colors.grey[400])
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  rep.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rep.university,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
