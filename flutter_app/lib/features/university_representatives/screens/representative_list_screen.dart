import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/representative.dart';
import '../services/representative_service.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/widgets/error_screen.dart';
import '../../../core/widgets/content_card.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('ممثلي الجامعات'),
      ),
      body: FutureBuilder<List<UniversityRepresentative>>(
        future: _representativesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
            return const Center(child: Text('لا يوجد ممثلين حالياً'));
          }

          final representatives = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: representatives.length,
            itemBuilder: (context, index) {
              final rep = representatives[index];
              return ContentCard(
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
            },
          );
        },
      ),
    );
  }
}
