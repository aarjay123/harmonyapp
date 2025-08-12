import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// A simple data model for a reward offer.
class _Offer {
  final String title;
  final String description;
  final String expiryInfo;
  final int? points; // Null for expired offers without a redeem button.
  final DateTime? postedDate; // New field to store the parsed posted date.

  const _Offer({
    required this.title,
    required this.description,
    required this.expiryInfo,
    this.points,
    this.postedDate,
  });

  // Factory constructor to parse a post from the Blogger API JSON response.
  factory _Offer.fromBloggerPost(Map<String, dynamic> post) {
    String rawContent = post['content'] ?? '';
    // Use a special marker in your blog post to separate description from details.
    const detailMarker = '<!--DETAILS-->';
    String description = rawContent.split(detailMarker).first.trim();
    String detailsSection = rawContent.contains(detailMarker)
        ? rawContent.split(detailMarker).last.trim()
        : '';

    String expiryInfo = 'No expiry information.';
    int? points;
    DateTime? postedDate;

    // Parse the details line by line.
    for (String line in detailsSection.split('\n')) {
      if (line.toLowerCase().startsWith('expires:')) {
        expiryInfo = line.substring('expires:'.length).trim();
      } else if (line.toLowerCase().startsWith('points:')) {
        points = int.tryParse(line.substring('points:'.length).trim());
      } else if (line.toLowerCase().startsWith('posted:')) {
        String dateString = line.substring('posted:'.length).trim();
        // Attempt to parse the date string. Assumes a "dd/MM/yyyy HH:mm" format.
        try {
          List<String> parts = dateString.split(' ');
          List<String> dateParts = parts[0].split('/');
          List<String> timeParts = parts[1].split(':');
          postedDate = DateTime(
            int.parse(dateParts[2]), // year
            int.parse(dateParts[1]), // month
            int.parse(dateParts[0]), // day
            int.parse(timeParts[0]), // hour
            int.parse(timeParts[1]), // minute
          );
        } catch (e) {
          // If parsing fails, leave the date as null.
          postedDate = null;
        }
      }
    }

    // The logic for expired offers is handled by the label 'expired-offer'.
    // If a post is labeled as expired, we will not show the redeem button later,
    // by checking if the offer belongs to the _expiredOffers list.
    // The presence of 'points' here is just for data parsing.
    return _Offer(
      title: post['title'] ?? 'No Title',
      description: description,
      expiryInfo: expiryInfo,
      points: points,
      postedDate: postedDate,
    );
  }
}

// --- RewardsPage Fragment ---
// This widget now fetches offers dynamically and has a responsive layout.
class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  // NEW: Added max width constraint for larger screens.
  static const double _contentMaxWidth = 1200.0;

  List<_Offer> _activeOffers = [];
  List<_Offer> _expiredOffers = [];
  bool _isLoading = true;
  String? _error;

  // TODO: Replace these with your actual Blogger credentials.
  final String _blogId = '8654667946288784337';
  final String _apiKey = 'AIzaSyBWqVZsarbdDTsKwabpao7kiVJSvxThvSA';

  @override
  void initState() {
    super.initState();
    _fetchOffers();
  }

  // Fetches offers from the Blogger API.
  Future<void> _fetchOffers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (_blogId == 'YOUR_BLOG_ID' || _apiKey == 'YOUR_API_KEY') {
      setState(() {
        _error = 'Please configure your Blog ID and API Key in the code.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch active and expired offers concurrently.
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
        setState(() {
          // Display the specific error message from the exception.
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper function to fetch posts for a specific label.
  Future<List<_Offer>> _fetchOffersByLabel(String label) async {
    final url = Uri.parse(
        'https://www.googleapis.com/blogger/v3/blogs/$_blogId/posts?fetchBodies=true&labels=$label&key=$_apiKey');
    final response = await http.get(url);

    // Check the HTTP status code to provide more specific error messages.
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> posts = data['items'] ?? [];
      List<_Offer> offers = posts.map((post) => _Offer.fromBloggerPost(post)).toList();

      // Sort the offers by postedDate, newest first.
      // Offers without a valid date will be placed at the end of the list.
      offers.sort((a, b) {
        if (a.postedDate == null && b.postedDate == null) return 0;
        if (a.postedDate == null) return 1;
        if (b.postedDate == null) return -1;
        return b.postedDate!.compareTo(a.postedDate!);
      });

      return offers;
    } else if (response.statusCode == 400) {
      throw Exception('Bad Request (400): Check if your Blog ID is correct.');
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Authorization Error (401/403): Check if your API Key is correct and the Blogger API is enabled.');
    } else if (response.statusCode == 404) {
      throw Exception('Not Found (404): The blog or post could not be found.');
    } else {
      // Throw a generic exception for other errors.
      throw Exception('Failed to load posts (Status code: ${response.statusCode}).');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          // UPDATED: Wrapped the entire scroll view in a centering and constraining widget
          // for a responsive layout on larger screens.
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
                            labelColor: Theme.of(context).colorScheme.onPrimary,
                            unselectedLabelColor: Theme.of(context).colorScheme.primary,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: const [
                              Tab(text: 'Active'),
                              Tab(text: 'Expired'),
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
                      // The logic to show/hide the redeem button is now inside _buildOfferList
                      _buildOfferList(_activeOffers, 'No active offers found.', isExpired: false),
                      _buildOfferList(_expiredOffers, 'No expired offers found.', isExpired: true),
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

  // --- BUILDER WIDGETS ---

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
            ).createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            child: Text(
              'HiRewards',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'View your offers and barcode',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
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
              Text(
                'Your Barcode',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Icon(Icons.qr_code_2_rounded, size: 150, color: colorScheme.onSecondaryContainer),
              const SizedBox(height: 16),
              Text(
                'Please scan this at checkout',
                style: TextStyle(color: colorScheme.onSecondaryContainer),
              ),
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
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchOffers,
              child: const Text('Retry'),
            )
          ],
        ),
      ),
    );
  }

  // UPDATED: Added an `isExpired` flag to control button visibility, restoring the original intent.
  Widget _buildOfferList(List<_Offer> offers, String emptyMessage, {required bool isExpired}) {
    if (offers.isEmpty) {
      return Center(
        child: Text(emptyMessage),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        final colorScheme = Theme.of(context).colorScheme;

        // The redeem button is only shown if the offer has points AND it's not in the expired list.
        final bool showRedeemButton = offer.points != null && !isExpired;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          color: colorScheme.surfaceVariant,
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  offer.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  offer.expiryInfo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
                if (showRedeemButton) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Scan the QR code on the homepage to redeem.'),
                            behavior: SnackBarBehavior.fixed,
                          ),
                        );
                      },
                      child: Text('${offer.points} Points - Redeem'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}

// A custom delegate to make the TabBar stick to the top when scrolling.
// This is now simpler as it doesn't need to manage the width itself.
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height + 16;
  @override
  double get maxExtent => tabBar.preferredSize.height + 16;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
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
