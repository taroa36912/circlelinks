import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom AppBar widget implementing Contemporary Spatial Minimalism
/// with contextual actions and gesture-friendly interactions for
/// Japanese university circle management applications.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String title;

  /// The app bar variant to use
  final CustomAppBarVariant variant;

  /// Whether to show the back button (auto-detected if null)
  final bool? showBackButton;

  /// Custom leading widget (overrides back button)
  final Widget? leading;

  /// Action widgets to display on the right
  final List<Widget>? actions;

  /// Whether to show elevation shadow
  final bool showElevation;

  /// Custom background color (overrides theme)
  final Color? backgroundColor;

  /// Custom foreground color (overrides theme)
  final Color? foregroundColor;

  /// Whether the app bar is pinned in a sliver
  final bool pinned;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.standard,
    this.showBackButton,
    this.leading,
    this.actions,
    this.showElevation = false,
    this.backgroundColor,
    this.foregroundColor,
    this.pinned = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine if we should show back button
    final shouldShowBack = showBackButton ??
        (leading == null && ModalRoute.of(context)?.canPop == true);

    return AppBar(
      title: _buildTitle(context),
      leading: leading ?? (shouldShowBack ? _buildBackButton(context) : null),
      actions: _buildActions(context),
      backgroundColor: backgroundColor ?? _getBackgroundColor(colorScheme),
      foregroundColor: foregroundColor ?? _getForegroundColor(colorScheme),
      elevation: showElevation ? _getElevation() : 0,
      scrolledUnderElevation: showElevation ? 1 : 0,
      shadowColor: colorScheme.shadow,
      surfaceTintColor: Colors.transparent,
      centerTitle: _shouldCenterTitle(),
      automaticallyImplyLeading: false,
      titleSpacing: _getTitleSpacing(),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case CustomAppBarVariant.standard:
        return Text(
          title,
          style: GoogleFonts.notoSansJp(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: foregroundColor ?? theme.colorScheme.onSurface,
          ),
        );

      case CustomAppBarVariant.large:
        return Text(
          title,
          style: GoogleFonts.notoSansJp(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: foregroundColor ?? theme.colorScheme.onSurface,
          ),
        );

      case CustomAppBarVariant.compact:
        return Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: foregroundColor ?? theme.colorScheme.onSurface,
          ),
        );

      case CustomAppBarVariant.minimal:
        return Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            color: foregroundColor ?? theme.colorScheme.onSurface,
          ),
        );
    }
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      iconSize: 20,
      padding: const EdgeInsets.all(12),
      tooltip: 'Back',
      splashRadius: 20,
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (actions != null) return actions;

    // Default contextual actions based on current route
    final currentRoute = ModalRoute.of(context)?.settings.name;

    switch (currentRoute) {
      case '/circle-discovery':
        return [
          IconButton(
            onPressed: () => _showSearchBottomSheet(context),
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search Circles',
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/portfolio-builder'),
            icon: const Icon(Icons.person_rounded),
            tooltip: 'Profile',
          ),
        ];

      case '/event-details':
        return [
          IconButton(
            onPressed: () => _showShareBottomSheet(context),
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Event',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleEventAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Edit Event'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Duplicate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ];

      case '/circle-profile':
        return [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/event-creation'),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Create Event',
          ),
          IconButton(
            onPressed: () => _showCircleSettings(context),
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Circle Settings',
          ),
        ];

      default:
        return null;
    }
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    switch (variant) {
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.large:
        return colorScheme.surface;
      case CustomAppBarVariant.compact:
      case CustomAppBarVariant.minimal:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(ColorScheme colorScheme) {
    return colorScheme.onSurface;
  }

  double _getElevation() {
    switch (variant) {
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.large:
        return 2;
      case CustomAppBarVariant.compact:
      case CustomAppBarVariant.minimal:
        return 0;
    }
  }

  bool _shouldCenterTitle() {
    switch (variant) {
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.large:
        return false;
      case CustomAppBarVariant.compact:
      case CustomAppBarVariant.minimal:
        return true;
    }
  }

  double _getTitleSpacing() {
    switch (variant) {
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.large:
        return 16;
      case CustomAppBarVariant.compact:
      case CustomAppBarVariant.minimal:
        return 0;
    }
  }

  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search circles...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onChanged: (value) {
                  // Implement search logic
                },
              ),
            ),
            // Add search results here
          ],
        ),
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Share Event',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(context, Icons.link_rounded, 'Copy Link'),
                _buildShareOption(context, Icons.message_rounded, 'Message'),
                _buildShareOption(context, Icons.email_rounded, 'Email'),
                _buildShareOption(context, Icons.more_horiz_rounded, 'More'),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _handleEventAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        Navigator.pushNamed(context, '/event-creation');
        break;
      case 'duplicate':
        // Implement duplicate logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event duplicated')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text(
            'Are you sure you want to delete this event? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Event deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCircleSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Circle Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            // Add settings options here
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    switch (variant) {
      case CustomAppBarVariant.standard:
        return const Size.fromHeight(56);
      case CustomAppBarVariant.large:
        return const Size.fromHeight(64);
      case CustomAppBarVariant.compact:
        return const Size.fromHeight(48);
      case CustomAppBarVariant.minimal:
        return const Size.fromHeight(44);
    }
  }
}

/// Enum defining different app bar variants
enum CustomAppBarVariant {
  /// Standard app bar with normal height and styling
  standard,

  /// Large app bar with increased height and prominent title
  large,

  /// Compact app bar with reduced height for dense layouts
  compact,

  /// Minimal app bar with transparent background and subtle styling
  minimal,
}
