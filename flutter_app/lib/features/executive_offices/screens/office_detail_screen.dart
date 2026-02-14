import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/office_models.dart';
import '../services/office_service.dart';
import '../../../core/widgets/content_card.dart';

class OfficeDetailScreen extends StatefulWidget {
  final int officeId;

  const OfficeDetailScreen({super.key, required this.officeId});

  @override
  State<OfficeDetailScreen> createState() => _OfficeDetailScreenState();
}

class _OfficeDetailScreenState extends State<OfficeDetailScreen> {
  final OfficeService _officeService = OfficeService();
  late Future<ExecutiveOffice> _officeFuture;

  @override
  void initState() {
    super.initState();
    _officeFuture = _officeService.getOfficeDetails(widget.officeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المكتب')),
      body: FutureBuilder<ExecutiveOffice>(
        future: _officeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Office not found'));
          }

          final office = snapshot.data!;
          final manager = office.members.firstWhere(
            (m) => m.role == 'manager',
            orElse: () => OfficeMember(id: 0, officeId: 0, name: ''), // Dummy
          );
          final hasManager = manager.id != 0;
          final members = office.members.where((m) => m.role != 'manager').toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (office.imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: office.imageUrl!,
                        height: 200,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: Colors.grey[300],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            office.name,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (office.description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              office.description!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              if (hasManager) ...[
                 SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'مدير المكتب',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildMemberCard(context, manager, isManager: true),
                  ),
                ),
              ],

              if (members.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Text(
                      'أعضاء المكتب',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildMemberCard(context, members[index]),
                      childCount: members.length,
                    ),
                  ),
                ),
              ],
              
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, OfficeMember member, {bool isManager = false}) {
    return ContentCard(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: isManager ? 40 : 30,
            backgroundColor: Colors.grey[200],
            backgroundImage: member.imageUrl != null 
                ? CachedNetworkImageProvider(member.imageUrl!) 
                : null,
            child: member.imageUrl == null
                ? Icon(Icons.person, size: isManager ? 40 : 30, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            member.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isManager ? 18 : 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (member.position != null)
            Text(
              member.position!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
          const Spacer(),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (member.email != null)
                IconButton(
                  icon: const Icon(Icons.email_outlined, size: 20, color: Colors.blue),
                  onPressed: () => _launchUrl('mailto:${member.email}'),
                  tooltip: 'Email',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              if (member.email != null && member.phone != null)
                 const SizedBox(width: 16),
              if (member.phone != null)
                IconButton(
                  icon: const Icon(Icons.phone_outlined, size: 20, color: Colors.green),
                  onPressed: () => _launchUrl('tel:${member.phone}'),
                  tooltip: 'Call',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    }
  }
}
