import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// A simple page to display a webview in fullscreen (if needed for forms)
// In a real project, move this to a shared utility file if not already present.
class FullscreenWebViewPage extends StatelessWidget {
  final String url;
  final String title;

  const FullscreenWebViewPage({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
        ),
      ),
    );
  }
}

class AppFeedbackInfoPage extends StatefulWidget {
  const AppFeedbackInfoPage({super.key});

  @override
  State<AppFeedbackInfoPage> createState() => _AppFeedbackInfoPageState();
}

class _AppFeedbackInfoPageState extends State<AppFeedbackInfoPage> with TickerProviderStateMixin {
  late TabController _tabController;

  final String _feedbackFormUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSdt40E-D8WHqnvFp8B5AFTk2yK7xCEFrunE6lDbuEvYoTrMQQ/viewform?embedded=true';
  final String _feedbackFullscreenUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSdt40E-D8WHqnvFp8B5AFTk2yK7xCEFrunE6lDbuEvYoTrMQQ/viewform';

  final String _bugReportFormUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSeP5vjhqfapr854dS6N_sltLmeSXECDjbOz3VO0r5-_GieDhA/viewform?embedded=true';
  final String _bugReportFullscreenUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSeP5vjhqfapr854dS6N_sltLmeSXECDjbOz3VO0r5-_GieDhA/viewform';

  final String _complainFormUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSeHXG6XZo0qHtU57Y5IYeqpI44eEUsHVAYRRMVZWL8O1UathQ/viewform?embedded=true';
  final String _complainFullscreenUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSeHXG6XZo0qHtU57Y5IYeqpI44eEUsHVAYRRMVZWL8O1UathQ/viewform';

  static const double _contentMaxWidth = 768.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Feedback, Bug Report, Complain
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildFeedbackContentSection({
    required String sectionTitle,
    required String sectionSubtitle,
    required String iframeUrl,
    required String fullscreenUrl,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  color: colorScheme.secondaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            sectionTitle,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (sectionSubtitle.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              sectionSubtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSecondaryContainer.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        // Optional: Add fullscreen button if desired for these forms too
                        // ElevatedButton.icon(
                        //   icon: Icon(Icons.fullscreen_rounded, color: colorScheme.onPrimary),
                        //   label: Text('Open Form Fullscreen', style: TextStyle(color: colorScheme.onPrimary)),
                        //   onPressed: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (_) => FullscreenWebViewPage(url: fullscreenUrl, title: sectionTitle),
                        //       ),
                        //     );
                        //   },
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: colorScheme.primary,
                        //     foregroundColor: colorScheme.onPrimary,
                        //     elevation: 0,
                        //     padding: const EdgeInsets.symmetric(vertical: 10),
                        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                        //   ),
                        // ),
                        // const SizedBox(height: 16),
                        SizedBox(
                          height: 600,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: InAppWebView(
                              key: ValueKey(iframeUrl),
                              initialUrlRequest: URLRequest(url: WebUri(iframeUrl)),
                              initialSettings: InAppWebViewSettings(
                                javaScriptEnabled: true,
                                transparentBackground: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Feedback"),
      ),
      backgroundColor: colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rate_review_rounded, // Icon for Feedback
                          size: 36,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Send Feedback',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Use this page to send feedback to us.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Pill Navigation TabBar
          Material(
            color: colorScheme.surface,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: colorScheme.onPrimaryContainer,
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      color: colorScheme.primaryContainer,
                    ),
                    splashBorderRadius: BorderRadius.circular(24.0),
                    dividerHeight: 0.0,
                    tabs: const [
                      Tab(text: 'Feedback'),
                      Tab(text: 'Bug Report'),
                      Tab(text: 'Complain'),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeedbackContentSection(
                  sectionTitle: 'App Feedback',
                  sectionSubtitle: 'Have any feedback on the new HiOS mobile app that you would like to share with us? Please fill in the form below :)',
                  iframeUrl: _feedbackFormUrl,
                  fullscreenUrl: _feedbackFullscreenUrl,
                ),
                _buildFeedbackContentSection(
                  sectionTitle: 'Bug Report',
                  sectionSubtitle: 'Have you noticed a bug in HiOSMobile? Then please fill in the form below and we\'ll see to it ASAP!',
                  iframeUrl: _bugReportFormUrl,
                  fullscreenUrl: _bugReportFullscreenUrl,
                ),
                _buildFeedbackContentSection(
                  sectionTitle: 'Complain',
                  sectionSubtitle: 'Wanting to complain for something unsatisfactory you experienced from The Highland Cafe(tm)?\nWe\'d rather you didn\'t, but if you are being persistant about it, please fill in the form below. :(',
                  iframeUrl: _complainFormUrl,
                  fullscreenUrl: _complainFullscreenUrl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}