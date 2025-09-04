import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// --- Data Model ---

class _Offer {
  final String title;
  final String description;
  final String expiryInfo;
  final int? points;
  final DateTime? postedDate;

  const _Offer({
    required this.title,
    required this.description,
    required this.expiryInfo,
    this.points,
    this.postedDate,
  });

  factory _Offer.fromBloggerPost(Map<String, dynamic> post) {
    String rawContent = post['content'] ?? '';
    const detailMarker = '<!--DETAILS-->';
    String description = rawContent.split(detailMarker).first.trim();
    String detailsSection = rawContent.contains(detailMarker)
        ? rawContent.split(detailMarker).last.trim()
        : '';

    String expiryInfo = 'No expiry information.';
    int? points;
    DateTime? postedDate;

    // Use a robust parsing method for the date
    if (post['published'] != null) {
      postedDate = DateTime.tryParse(post['published']);
    }

    for (String line in detailsSection.split('\n')) {
      if (line.toLowerCase().startsWith('expires:')) {
        expiryInfo = line.substring('expires:'.length).trim();
      } else if (line.toLowerCase().startsWith('points:')) {
        points = int.tryParse(line.substring('points:'.length).trim());
      }
    }

    return _Offer(
      title: post['title'] ?? 'No Title',
      description: description,
      expiryInfo: expiryInfo,
      points: points,
      postedDate: postedDate,
    );
  }
}

// --- Main Page Widget ---

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  static const double _contentMaxWidth = 1200.0;
  List<_Offer> _activeOffers = [];
  List<_Offer> _expiredOffers = [];
  bool _isLoading = true;
  String? _error;

  final String _blogId = '8654667946288784337';
  final String _apiKey = 'AIzaSyBWqVZsarbdDTsKwabpao7kiVJSvxThvSA'; // IMPORTANT: Replace with your actual key

  @override
  void initState() {
    super.initState();
    _fetchOffers();
  }

  Future<void> _fetchOffers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (_apiKey == 'YOUR_API_KEY') {
      setState(() {
        _error = 'Please configure your Blogger API Key in the code.';
        _isLoading = false;
      });
      return;
    }

    try {
      final responses = await Future.wait([
        _fetchOffersByLabel('active-offer'),
        _fetchOffersByLabel('expired-offer'),
      ]);
      if (mounted) {
        setState(() {
          _activeOffers = responses[0];
          _expiredOffers = responses[1];
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<_Offer>> _fetchOffersByLabel(String label) async {
    final url = Uri.parse(
        'https://www.googleapis.com/blogger/v3/blogs/$_blogId/posts?fetchBodies=true&labels=$label&key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> posts = data['items'] ?? [];
      List<_Offer> offers = posts.map((post) => _Offer.fromBloggerPost(post)).toList();
      offers.sort((a, b) {
        if (a.postedDate == null || b.postedDate == null) return 0;
        return b.postedDate!.compareTo(a.postedDate!);
      });
      return offers;
    } else {
      throw Exception('Failed to load offers (Status: ${response.statusCode})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
              child: RefreshIndicator(
                onRefresh: _fetchOffers,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(child: _buildHeader(context)),
                      SliverToBoxAdapter(child: _buildBarcodeCard(context)),
                      SliverPersistentHeader(
                        delegate: _SliverTabBarDelegate(
                          TabBar(
                            tabs: const [
                              Tab(text: 'Active Offers'),
                              Tab(text: 'Expired Offers'),
                            ],
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? _buildErrorView()
                      : TabBarView(
                    children: [
                      _buildOfferList(_activeOffers, 'No active offers available right now.', isExpired: false),
                      _buildOfferList(_expiredOffers, 'You have no expired offers.', isExpired: true),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Builder Widgets ---

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: [colorScheme.primary, colorScheme.tertiary],
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
            child: Text('HiRewards', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Text('View your offers and membership barcode below.', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildBarcodeCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        color: colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text('Your Membership', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSecondaryContainer)),
              const SizedBox(height: 16),
              Icon(Icons.qr_code_2_rounded, size: 150, color: colorScheme.onSecondaryContainer),
              const SizedBox(height: 16),
              Text('Please scan this at checkout to apply offers', style: TextStyle(color: colorScheme.onSecondaryContainer)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 60),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchOffers, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  // IMPROVED: Added a more engaging empty state
  Widget _buildEmptyListView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_offer_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text("Check back later for new rewards!", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferList(List<_Offer> offers, String emptyMessage, {required bool isExpired}) {
    if (offers.isEmpty) {
      return _buildEmptyListView(emptyMessage);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        return _OfferCard(offer: offers[index], isExpired: isExpired);
      },
    );
  }
}

// --- Custom Widgets ---

// IMPROVED: Extracted the offer card into its own stateless widget for clarity.
class _OfferCard extends StatelessWidget {
  final _Offer offer;
  final bool isExpired;

  const _OfferCard({required this.offer, required this.isExpired});

  // IMPROVED: Added a dialog for a better redemption flow.
  void _showRedeemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Redeem Offer'),
          content: Text('To redeem "${offer.title}", please scan your membership barcode at the till.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool showRedeemButton = offer.points != null && !isExpired;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.surfaceVariant,
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Text(offer.description, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.9))),
                const SizedBox(height: 12),
                Text(offer.expiryInfo, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.7))),
              ],
            ),
          ),
          if (showRedeemButton) ...[
            const SizedBox(height: 8),
            // IMPROVED: "Ticket stub" style for the redeem button section.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("COST", style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onPrimaryContainer)),
                      Text("${offer.points} Points", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _showRedeemDialog(context),
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                    child: const Text('Redeem'),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}

// A custom delegate to make the TabBar stick to the top when scrolling.
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height + 16;
  @override
  double get maxExtent => tabBar.preferredSize.height + 16;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.8),
          borderRadius: BorderRadius.circular(50),
        ),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
