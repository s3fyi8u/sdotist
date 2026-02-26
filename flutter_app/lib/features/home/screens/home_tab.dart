import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../auth/screens/register_screen.dart';
import '../../executive_offices/screens/office_list_screen.dart';
import '../../university_representatives/screens/representative_list_screen.dart';
import '../../events/screens/event_details_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/animated_hover_card.dart';
import '../../events/models/event_model.dart';

class HomeTab extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeTab({super.key, required this.onTabChange});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _latestNews = [];
  bool _isLoadingNews = true;
  Map<String, int> _statistics = {'members': 0, 'events': 0, 'years': 0};
  bool _isLoadingStatistics = true;
  List<Event> _upcomingEvents = [];
  bool _isLoadingEvents = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestNews();
    _fetchStatistics();
    _fetchUpcomingEvents();
  }

  Future<void> _fetchUpcomingEvents() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.events);
      if (mounted) {
        setState(() {
          final List<dynamic> allEvents = response.data;
          _upcomingEvents = allEvents
              .map((json) => Event.fromJson(json))
              .where((event) => !event.isEnded)
              .take(2)
              .toList();
          _isLoadingEvents = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingEvents = false;
        });
        debugPrint('Error fetching upcoming events: $e');
      }
    }
  }

  Future<void> _fetchStatistics() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.statistics);
      if (mounted) {
        setState(() {
          _statistics = {
            'members': response.data['total_users'] ?? 0,
            'events': response.data['total_events'] ?? 0,
            'years': DateTime.now().year - 2013,
          };
          _isLoadingStatistics = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Fallback values if backend endpoint is not yet deployed
          _statistics = {
            'members': 500,
            'events': 25,
            'years': DateTime.now().year - 2013,
          };
          _isLoadingStatistics = false;
        });
        debugPrint('Error fetching statistics: $e');
      }
    }
  }

  Future<void> _fetchLatestNews() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.news);
      if (mounted) {
        setState(() {
          // Take only the last 2 items
          final List<dynamic> allNews = response.data;
          _latestNews = allNews.take(2).toList();
          _isLoadingNews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingNews = false;
        });
        debugPrint('Error fetching news: $e');
      }
    }
  }
  
  String _getNewsImage(Map<String, dynamic> news) {
    if (news['images'] != null && (news['images'] as List).isNotEmpty) {
      final firstImg = news['images'][0];
      if (firstImg is Map && firstImg['image_url'] != null) {
        return firstImg['image_url'].toString();
      }
    }
    if (news['image'] != null) {
      return news['image'].toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = AppLocalizations.of(context).isRtl;

    return ResponsiveLayout.constrainedBox(
      context,
      maxWidth: 1100,
      SingleChildScrollView(
        child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // ── HEADER SECTION ──────────────────────────────────
              // Logo + Title/Subtitle/Description side by side on wide screens
              LayoutBuilder(builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final logoWidget = Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/logoo.png',
                      width: isWide ? 180 : 120,
                      height: isWide ? 180 : 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                );

                final textWidget = Column(
                  crossAxisAlignment: isWide
                      ? (isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start)
                      : CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('home_main_title'),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isWide ? 32 : 24,
                        color: Theme.of(context).textTheme.displayLarge?.color,
                      ),
                      textAlign: isWide ? (isRtl ? TextAlign.right : TextAlign.left) : TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context).translate('home_main_subtitle'),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        height: 1.6,
                      ),
                      textAlign: isWide ? (isRtl ? TextAlign.right : TextAlign.left) : TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).translate('home_description'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      ),
                      textAlign: isWide ? (isRtl ? TextAlign.right : TextAlign.left) : TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (!_isLoadingStatistics)
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        alignment: isWide
                            ? (isRtl ? WrapAlignment.end : WrapAlignment.start)
                            : WrapAlignment.center,
                        children: [
                          _buildInlineStatBadge(
                            context,
                            value: '${_statistics['members']}+',
                            label: AppLocalizations.of(context).translate('members_stat'),
                          ),
                          _buildInlineStatBadge(
                            context,
                            value: '${_statistics['events']}+',
                            label: AppLocalizations.of(context).translate('events_stat'),
                          ),
                          _buildInlineStatBadge(
                            context,
                            value: '${_statistics['years']}',
                            label: AppLocalizations.of(context).translate('years_stat'),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: isWide ? 200 : double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppLocalizations.of(context).translate('register_membership'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Expanded(child: textWidget),
                      const SizedBox(width: 40),
                      logoWidget,
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      logoWidget,
                      const SizedBox(height: 28),
                      textWidget,
                    ],
                  );
                }
              }),

              const SizedBox(height: 48),

              // About Us Section
              _buildAboutUsCard(context, isRtl),
              const SizedBox(height: 32),

              // Quick Access Section (Executive Offices & University Reps)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildQuickAccessCard(
                        context,
                        title: AppLocalizations.of(context).translate('university_representatives'),
                        icon: Icons.school,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RepresentativeListScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildQuickAccessCard(
                        context,
                        title: AppLocalizations.of(context).translate('executive_offices'),
                        icon: Icons.business_center,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OfficeListScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Upcoming Events Section
              _buildUpcomingEventsSection(context, isRtl),
              const SizedBox(height: 48),

              // Services Section
              Align(
                alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context).translate('services'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  final cardWidth = isWide
                      ? (constraints.maxWidth - 32) / 3
                      : (constraints.maxWidth - 16) / 2;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildServiceCard(
                        context,
                        icon: Icons.event_outlined,
                        title: AppLocalizations.of(context).translate('events'),
                        onTap: () => widget.onTabChange(2),
                        width: cardWidth,
                      ),
                      _buildServiceCard(
                        context,
                        icon: Icons.article_outlined,
                        title: AppLocalizations.of(context).translate('news'),
                        onTap: () => widget.onTabChange(1),
                        width: cardWidth,
                      ),
                      _buildServiceCard(
                        context,
                        icon: Icons.card_membership_outlined,
                        title: AppLocalizations.of(context).translate('membership'),
                        onTap: () => widget.onTabChange(3),
                        width: cardWidth,
                      ),

                    ],
                  );
                },
              ),
              const SizedBox(height: 48),

              // Latest News Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('latest_news'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onTabChange(1),
                    child: Text(AppLocalizations.of(context).translate('see_all')),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Latest News Data
              if (_isLoadingNews)
                const Center(child: CircularProgressIndicator())
              else if (_latestNews.isEmpty)
                Center(child: Text(AppLocalizations.of(context).translate('no_news')))
              else
                ..._latestNews.map((news) => _buildNewsCard(context, news)),

              const SizedBox(height: 32),

              // Join Us Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('join_us_now'),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context).translate('join_community_subtitle'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppLocalizations.of(context).translate('register_membership'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Contact Us Section
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  AppLocalizations.of(context).translate('contact_us'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.email, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).translate('email_label'),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'info@sdotist.org',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context).translate('follow_us'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon(context, FontAwesomeIcons.facebookF),
                        const SizedBox(width: 16),
                        _buildSocialIcon(
                          context,
                          FontAwesomeIcons.instagram,
                          'https://www.instagram.com/sdotist',
                        ),
                        const SizedBox(width: 16),
                        _buildSocialIcon(context, FontAwesomeIcons.twitter),
                        const SizedBox(width: 16),
                        _buildSocialIcon(context, FontAwesomeIcons.whatsapp),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // ── HELPER: Inline stat badge for header ──────────────────────
  Widget _buildInlineStatBadge(BuildContext context, {required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // ── HELPER: About Us card (extracted) ────────────────────────
  Widget _buildAboutUsCard(BuildContext context, bool isRtl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            AppLocalizations.of(context).translate('about_us'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildAboutRow(
                context,
                icon: Icons.account_balance_outlined,
                titleKey: 'foundation',
                descKey: 'foundation_text',
              ),
              const SizedBox(height: 20),
              _buildAboutRow(
                context,
                icon: Icons.visibility_outlined,
                titleKey: 'our_vision',
                descKey: 'our_vision_text',
              ),
              const SizedBox(height: 20),
              _buildAboutRow(
                context,
                icon: Icons.rocket_launch_outlined,
                titleKey: 'our_mission',
                descKey: 'our_mission_text',
              ),
              const SizedBox(height: 20),
              _buildAboutRow(
                context,
                icon: Icons.diamond_outlined,
                titleKey: 'our_values',
                descKey: 'our_values_text',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(BuildContext context, dynamic news) {
     final imageUrl = _getNewsImage(news);

    return AnimatedHoverCard(
      padding: const EdgeInsets.all(12),
      onTap: () => widget.onTabChange(1), // Navigate to News tab
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content Side
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news['title'] ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  news['description'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  news['created_at'] != null 
                    ? news['created_at'].toString().substring(0, 10) 
                    : '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Image Side
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 20),
                  ),
                )
              : Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 30, color: Colors.grey),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AnimatedHoverCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required double width,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      width: width,
      child: AnimatedHoverCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        backgroundColor: Colors.transparent, // Uses AppTheme natively otherwise but let's keep transparent for this variant
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAboutRow(
    BuildContext context, {
    required IconData icon,
    required String titleKey,
    required String descKey,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate(titleKey),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context).translate(descKey),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            value: '${_statistics['members']}+',
            label: AppLocalizations.of(context).translate('members_stat'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            value: '${_statistics['events']}+',
            label: AppLocalizations.of(context).translate('events_stat'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            value: '${_statistics['years']}',
            label: AppLocalizations.of(context).translate('years_stat'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, {required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light 
            ? Colors.white 
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon, [String? url]) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: url != null ? () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        } : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: FaIcon(
            icon,
            size: 24,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  String _getMonthName(BuildContext context, int month) {
    bool isAr = AppLocalizations.of(context).locale.languageCode == 'ar';
    bool isTr = AppLocalizations.of(context).locale.languageCode == 'tr';

    if (month < 1 || month > 12) return '';

    if (isAr) {
      const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
      return months[month - 1];
    } else if (isTr) {
      const months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
      return months[month - 1];
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return months[month - 1];
    }
  }

  String _formatTimeLocalized(BuildContext context, DateTime date) {
    bool isAr = AppLocalizations.of(context).locale.languageCode == 'ar';
    bool isTr = AppLocalizations.of(context).locale.languageCode == 'tr';

    int hour = date.hour;
    int minute = date.minute;
    String periodInfo;

    if (isAr) {
      periodInfo = hour >= 12 ? 'مساءً' : 'صباحاً';
    } else if (isTr) {
      // 24-hour style or AM/PM equivalent
      periodInfo = hour >= 12 ? 'ÖS' : 'ÖÖ';
    } else {
      periodInfo = hour >= 12 ? 'PM' : 'AM';
    }

    if (!isTr) {
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '$hour:${minute.toString().padLeft(2, '0')} $periodInfo';
    } else {
      // TR generally prefers 24 hour "14:30"
      return '${date.hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildUpcomingEventsSection(BuildContext context, bool isRtl) {
    if (_isLoadingEvents) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).translate('upcoming_events'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => widget.onTabChange(2),
              child: Text(AppLocalizations.of(context).translate('see_all')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_upcomingEvents.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy_outlined,
                  size: 40,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'لا يوجد فعاليات قادمة في الوقت الحالي',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ..._upcomingEvents.map((event) => _buildUpcomingEventCard(context, event, isRtl)),
      ],
    );
  }

  Widget _buildUpcomingEventCard(BuildContext context, Event event, bool isRtl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(eventId: event.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Badge
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C), // Dark widget for date
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  event.date.day.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getMonthName(context, event.date.month),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Event Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${event.location} - ${_formatTimeLocalized(context, event.date)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.group,
                      size: 20,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${AppLocalizations.of(context).translate('participant') ?? 'مشارك'} ${event.registrations.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w600,
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
}
