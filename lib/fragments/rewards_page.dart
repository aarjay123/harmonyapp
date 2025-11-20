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
  final String _apiKey = 'AIzaSyBWqVZsarbdDTsKwabpao7kiVJSvxThvSA'; // Your specific API key

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

    // Basic check to ensure key is present (though it is hardcoded above)
    if (_apiKey.isEmpty || _apiKey == 'YOUR_API_KEY') {
      setState(() {
        _error = 'Please configure your Blogger API Key in the code.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch both lists concurrently
      final results = await Future.wait([
        _fetchOffersByLabel('active-offer'),
        _fetchOffersByLabel('expired-offer'),
      ]);

      if (mounted) {
        setState(() {
          _activeOffers = _sortOffersByDate(results[0]);
          _expiredOffers = _sortOffersByDate(results[1]);
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

  // Helper method to sort offers by date (newest first)
  List<_Offer> _sortOffersByDate(List<_Offer> offers) {
    offers.sort((a, b) {
      if (a.postedDate == null || b.postedDate == null) return 0;
      return b.postedDate!.compareTo(a.postedDate!);
    });
    return offers;
  }

  Future<List<_Offer>> _fetchOffersByLabel(String label) async {
    final url = Uri.parse(
        'https://www.googleapis.com/blogger/v3/blogs/$_blogId/posts?fetchBodies=true&labels=$label&key=$_apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> posts = data['items'] ?? [];
        return posts.map((post) => _Offer.fromBloggerPost(post)).toList();
      } else {
        // Instead of throwing immediately, log or return empty so one failure doesn't break everything
        debugPrint('Failed to load offers for label $label (Status: ${response.statusCode})');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching offers for label $label: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: RefreshIndicator(
          onRefresh: _fetchOffers,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar.large(
                  title: Text('HiRewards', style: TextStyle(color: colorScheme.onSurface)),
                  backgroundColor: colorScheme.surface,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.withOpacity(0.3), colorScheme.surface],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        // Padding to ensure icon doesn't clash with TabBar or Title
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 48.0),
                          child: Icon(Icons.loyalty_rounded, size: 80, color: Colors.purple.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    labelColor: colorScheme.primary,
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    indicatorColor: colorScheme.primary,
                    tabs: const [
                      Tab(text: 'Active Offers'),
                      Tab(text: 'Expired Offers'),
                    ],
                  ),
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
    );
  }

  // --- Builder Widgets ---

  Widget _buildBarcodeCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        color: colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text('Your Membership', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSecondaryContainer)),
              const SizedBox(height: 16),
              // Using a larger icon to represent the QR code clearly
              Icon(Icons.qr_code_2_rounded, size: 150, color: colorScheme.onSecondaryContainer),
              const SizedBox(height: 16),
              Text('Please scan this at checkout to apply offers', style: TextStyle(color: colorScheme.onSecondaryContainer), textAlign: TextAlign.center),
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
            const Icon(Icons.cloud_off_rounded, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            FilledButton.icon(
                onPressed: _fetchOffers,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry')
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyListView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 60, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text("Check back later for new rewards!", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferList(List<_Offer> offers, String emptyMessage, {required bool isExpired}) {
    // Special handling for the active offers list to include the barcode at the top
    if (!isExpired && offers.isEmpty) {
      // Even if empty, show the barcode card
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildBarcodeCard(context)),
          SliverFillRemaining(child: _buildEmptyListView(emptyMessage)),
        ],
      );
    } else if (isExpired && offers.isEmpty) {
      return _buildEmptyListView(emptyMessage);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: isExpired ? offers.length : offers.length + 1, // +1 for barcode card in active list
      itemBuilder: (context, index) {
        if (!isExpired) {
          if (index == 0) return _buildBarcodeCard(context);
          return _OfferCard(offer: offers[index - 1], isExpired: isExpired);
        }
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
    final dateFormat = DateFormat.yMMMd();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(offer.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    ),
                    if (offer.postedDate != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          dateFormat.format(offer.postedDate!),
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(offer.description, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 16, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(offer.expiryInfo, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.7))),
                  ],
                ),
              ],
            ),
          ),
          if (showRedeemButton) ...[
            Divider(height: 1, color: colorScheme.outlineVariant),
            // IMPROVED: "Ticket stub" style for the redeem button section.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("COST", style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSecondaryContainer)),
                      Text("${offer.points} Points", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSecondaryContainer)),
                    ],
                  ),
                  FilledButton.tonal(
                    onPressed: () => _showRedeemDialog(context),
                    style: FilledButton.styleFrom(
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