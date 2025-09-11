import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom Bottom Navigation Bar implementing gesture-first navigation
/// with contextual floating actions for Japanese university circle
/// management applications.
class CustomBottomBar extends StatefulWidget {
  /// The currently selected index
  final int currentIndex;

  /// Callback when a navigation item is tapped
  final ValueChanged<int> onTap;

  /// The bottom bar variant to use
  final CustomBottomBarVariant variant;

  /// Whether to show labels on navigation items
  final bool showLabels;

  /// Custom background color (overrides theme)
  final Color? backgroundColor;

  /// Whether to show elevation shadow
  final bool showElevation;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = CustomBottomBarVariant.standard,
    this.showLabels = true,
    this.backgroundColor,
    this.showElevation = true,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (widget.variant) {
      case CustomBottomBarVariant.standard:
        return _buildStandardBottomBar(context, colorScheme);
      case CustomBottomBarVariant.floating:
        return _buildFloatingBottomBar(context, colorScheme);
      case CustomBottomBarVariant.minimal:
        return _buildMinimalBottomBar(context, colorScheme);
    }
  }

  Widget _buildStandardBottomBar(
      BuildContext context, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colorScheme.surface,
        boxShadow: widget.showElevation
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavigationItems(context, colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar(
      BuildContext context, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: widget.showElevation
                ? [
                    BoxShadow(
                      color: colorScheme.shadow.withAlpha(38),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: SafeArea(
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _buildNavigationItems(context, colorScheme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalBottomBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withAlpha(51),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavigationItems(context, colorScheme),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavigationItems(
      BuildContext context, ColorScheme colorScheme) {
    final items = _getNavigationItems();

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = index == widget.currentIndex;

      return Expanded(
        child: GestureDetector(
          onTapDown: (_) => _animationController.forward(),
          onTapUp: (_) {
            _animationController.reverse();
            widget.onTap(index);
            _navigateToRoute(context, item.route);
          },
          onTapCancel: () => _animationController.reverse(),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isSelected ? 1.0 : _scaleAnimation.value,
                child: _buildNavigationItem(
                  context,
                  colorScheme,
                  item,
                  isSelected,
                ),
              );
            },
          ),
        ),
      );
    }).toList();
  }

  Widget _buildNavigationItem(
    BuildContext context,
    ColorScheme colorScheme,
    _NavigationItem item,
    bool isSelected,
  ) {
    final color =
        isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with selection indicator
          Stack(
            alignment: Alignment.center,
            children: [
              // Selection background
              if (isSelected)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              // Icon
              Icon(
                isSelected ? item.selectedIcon : item.icon,
                color: isSelected ? colorScheme.onPrimaryContainer : color,
                size: 24,
              ),
            ],
          ),

          // Label
          if (widget.showLabels) ...[
            const SizedBox(height: 4),
            Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: color,
                letterSpacing: 0.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  List<_NavigationItem> _getNavigationItems() {
    return [
      _NavigationItem(
        icon: Icons.explore_outlined,
        selectedIcon: Icons.explore_rounded,
        label: 'Discover',
        route: '/circle-discovery',
      ),
      _NavigationItem(
        icon: Icons.event_outlined,
        selectedIcon: Icons.event_rounded,
        label: 'Events',
        route: '/event-details',
      ),
      _NavigationItem(
        icon: Icons.groups_outlined,
        selectedIcon: Icons.groups_rounded,
        label: 'Circle',
        route: '/circle-profile',
      ),
      _NavigationItem(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: 'Portfolio',
        route: '/portfolio-builder',
      ),
    ];
  }

  void _navigateToRoute(BuildContext context, String route) {
    // Prevent navigation to the same route
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == route) return;

    // Use pushReplacementNamed to replace the current route
    // This maintains the bottom navigation state
    Navigator.pushReplacementNamed(context, route);
  }
}

/// Navigation item data class
class _NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}

/// Enum defining different bottom bar variants
enum CustomBottomBarVariant {
  /// Standard bottom bar with full width and elevation
  standard,

  /// Floating bottom bar with rounded corners and margin
  floating,

  /// Minimal bottom bar with transparent background and subtle border
  minimal,
}
