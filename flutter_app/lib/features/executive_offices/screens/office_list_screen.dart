import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/office_models.dart';
import '../services/office_service.dart';
import 'office_detail_screen.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/widgets/error_screen.dart';
import '../../../core/widgets/content_card.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/web_navigation_bar.dart';

class OfficeListScreen extends StatefulWidget {
  const OfficeListScreen({super.key});

  @override
  State<OfficeListScreen> createState() => _OfficeListScreenState();
}

class _OfficeListScreenState extends State<OfficeListScreen> {
  final OfficeService _officeService = OfficeService();
  late Future<List<ExecutiveOffice>> _officesFuture;
  AppError? _error;

  // Wrapper to handle errors
  Future<List<ExecutiveOffice>> _fetchOffices() async {
    try {
      _error = null;
      return await _officeService.getOffices();
    } catch (e) {
      _error = ErrorMapper.map(e);
      // Rethrow so FutureBuilder sees error state or handle in builder
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    super.initState();
    _officesFuture = _fetchOffices();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileScaffold: _buildMobileScaffold(context),
      tabletScaffold: _buildDesktopScaffold(context),
      desktopScaffold: _buildDesktopScaffold(context),
    );
  }

  Widget _buildDesktopScaffold(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WebNavigationBar(
            selectedIndex: -1, // No tab selected
            onItemTapped: (index) {
              // Navigate based on index if needed, or better, make navbar capable of navigation
              // For now, since this is a push screen, we might want to pop or standard navigate
               if (index == 0) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
               // Add other navigation logic here if consistent with main navbar
            },
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                           BackButton(color: Theme.of(context).textTheme.bodyLarge?.color),
                           const SizedBox(width: 8),
                           Text(
                            'المكاتب التنفيذية', // "Executive Offices"
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: FutureBuilder<List<ExecutiveOffice>>(
                          future: _officesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return ErrorScreen(
                                error: _error ?? ErrorMapper.map(snapshot.error),
                                onRetry: () {
                                  setState(() {
                                    _officesFuture = _fetchOffices();
                                  });
                                },
                              );
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text('No offices found.'));
                            }

                            final offices = snapshot.data!;
                            return GridView.builder(
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                                childAspectRatio: 0.85, 
                              ),
                              itemCount: offices.length,
                              itemBuilder: (context, index) {
                                final office = offices[index];
                                return _buildOfficeCard(context, office);
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
        title: const Text('المكاتب التنفيذية'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ExecutiveOffice>>(
        future: _officesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
             return ErrorScreen(
               error: _error ?? ErrorMapper.map(snapshot.error),
               onRetry: () {
                 setState(() {
                   _officesFuture = _fetchOffices();
                 });
               },
             );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No offices found.'));
          }

          final offices = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: offices.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final office = offices[index];
              return _buildOfficeCard(context, office);
            },
          );
        },
      ),
    );
  }

  Widget _buildOfficeCard(BuildContext context, ExecutiveOffice office) {
    return ContentCard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OfficeDetailScreen(officeId: office.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (office.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: office.imageUrl!,
                height: 150,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: Icon(Icons.business, size: 50, color: Colors.grey[500]),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  office.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (office.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    office.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
