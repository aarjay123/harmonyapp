import 'package:flutter/material.dart';

/// A data class to define the properties of each mini Floating Action Button.
class MiniFabItem {
  final IconData icon;      // The icon to display on the mini FAB.
  final String label;      // The tooltip/label for the mini FAB.
  final VoidCallback onTap; // The action to perform when the mini FAB is tapped.

  MiniFabItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// A widget that provides an expanding Floating Action Button menu.
/// Tapping the main FAB reveals/hides a set of smaller FABs.
class AnimatedFabMenu extends StatefulWidget {
  final List<MiniFabItem> fabItems; // List of items to display as mini FABs.
  final IconData mainIcon;          // Icon for the main FAB (e.g., Icons.menu).
  final IconData openIcon;          // Icon for the main FAB when menu is open (e.g., Icons.close).

  const AnimatedFabMenu({
    super.key,
    required this.fabItems,
    this.mainIcon = Icons.menu_open_rounded, // Default icon for closed state
    this.openIcon = Icons.close_rounded,     // Default icon for open state
  });

  @override
  State<AnimatedFabMenu> createState() => _AnimatedFabMenuState();
}

class _AnimatedFabMenuState extends State<AnimatedFabMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Controls the animation of the menu expansion.
  late Animation<double> _animation;    // The actual animation value (0.0 to 1.0).
  bool _isOpen = false;                 // Current state of the menu (open/closed).

  @override
  void initState() {
    super.initState();
    // Initialize AnimationController with a duration for the expansion.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Create a curved animation for smooth interpolation.
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller to prevent memory leaks.
    super.dispose();
  }

  /// Toggles the menu's open/closed state and starts the animation.
  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward(); // Start animation forward if opening.
      } else {
        _controller.reverse(); // Start animation backward if closing.
      }
    });
  }

  /// Builds a single mini Floating Action Button.
  Widget _buildMiniFab(MiniFabItem item, int index, ColorScheme colorScheme) {
    // Calculate the vertical offset for each mini FAB to stack them upwards.
    // Adjusted calculation to stack consistently.
    final double spacing = 65.0; // Vertical spacing between mini FABs
    // The index here is the *reversed* index, so 0 is the highest button, and fabItems.length-1 is lowest.
    // We want the lowest button to be closest to the main FAB.
    final double bottomOffset = (index + 1) * spacing; // +1 because index is 0-based

    return Positioned(
      right: 14.0, // Aligns with the main FAB's default position (standard FAB margin)
      bottom: 8.0 + bottomOffset, // MODIFIED: Base bottom position of main FAB + animated offset
      child: ScaleTransition( // Use ScaleTransition directly for cleaner animation
        scale: _animation,
        child: FadeTransition( // Use FadeTransition for opacity animation
          opacity: _animation,
          child: FloatingActionButton.small(
            heroTag: 'miniFab_${item.label}_$index', // Ensure unique hero tag for each FAB.
            onPressed: () {
              _toggleMenu(); // Close menu when a mini FAB is tapped.
              item.onTap();  // Perform the item's specific action.
            },
            child: Icon(item.icon),
            tooltip: item.label, // Show label as tooltip.
            backgroundColor: colorScheme.secondaryContainer, // Distinct background color.
            foregroundColor: colorScheme.onSecondaryContainer, // Icon color.
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      // Use a Stack to layer the mini FABs over the main content and the main FAB.
      // To ensure mini FABs are clickable, they MUST be rendered *after* the main FAB in the children list.
      // Alignment is handled by Positioned widgets within the stack.
      children: [
        // The main Floating Action Button. This should be the first child if other Positioned widgets are relative to it
        // OR it should be explicitly positioned. Placing it here makes it appear "below" the other positioned elements in Z-order.
        Positioned(
          right: 16.0, // Standard FAB horizontal padding
          bottom: 8.0, // MODIFIED: Standard FAB vertical padding, moved lower
          child: FloatingActionButton(
            heroTag: 'mainFab', // Unique hero tag for the main FAB.
            onPressed: _toggleMenu, // Toggles the menu.
            child: AnimatedIcon( // Animates icon between menu and close.
              icon: AnimatedIcons.menu_close,
              progress: _animation,
              color: colorScheme.onPrimary, // Icon color for the main FAB.
            ),
            backgroundColor: colorScheme.primary, // Main FAB background color.
            tooltip: _isOpen ? 'Close Menu' : 'Open Menu', // Dynamic tooltip.
          ),
        ),
        // Iterate through fabItems to build each mini FAB.
        // Render them after the main FAB to ensure they are on top for clickability.
        // We reverse the list for display logic so the 'first' item in fabItems (e.g. Download Menus) is at the top.
        // MODIFIED: Added .toList() before .asMap() to resolve the error.
        ...widget.fabItems.reversed.toList().asMap().entries.map((entry) {
          int index = entry.key; // This index is 0 for the last item in the original list, 1 for second to last, etc.
          MiniFabItem item = entry.value;
          return _buildMiniFab(item, index, colorScheme);
        }).toList(),
      ],
    );
  }
}