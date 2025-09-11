import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom Tab Bar implementing progressive information disclosure
/// with smooth animations and contextual content organization
/// for Japanese university circle management applications.
class CustomTabBar extends StatefulWidget {
  /// List of tab labels
  final List<String> tabs;

  /// List of tab content widgets
  final List<Widget> tabViews;

  /// Initial selected tab index
  final int initialIndex;

  /// Callback when tab changes
  final ValueChanged<int>? onTabChanged;

  /// The tab bar variant to use
  final CustomTabBarVariant variant;

  /// Whether tabs are scrollable
  final bool isScrollable;

  /// Custom tab indicator color
  final Color? indicatorColor;

  /// Custom tab label color
  final Color? labelColor;

  /// Custom unselected tab label color
  final Color? unselectedLabelColor;

  /// Whether to show tab icons (if provided)
  final List<IconData>? tabIcons;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.tabViews,
    this.initialIndex = 0,
    this.onTabChanged,
    this.variant = CustomTabBarVariant.standard,
    this.isScrollable = false,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.tabIcons,
  }) : assert(tabs.length == tabViews.length,
            'Tabs and tab views must have the same length');

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _indicatorAnimationController;
  late Animation<double> _indicatorAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      initialIndex: widget.initialIndex,
      vsync: this,
    );

    _indicatorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _indicatorAnimation = CurvedAnimation(
      parent: _indicatorAnimationController,
      curve: Curves.easeInOut,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _indicatorAnimationController.forward();
        widget.onTabChanged?.call(_tabController.index);
      } else {
        _indicatorAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _indicatorAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (widget.variant) {
      case CustomTabBarVariant.standard:
        return _buildStandardTabBar(context, colorScheme);
      case CustomTabBarVariant.pills:
        return _buildPillTabBar(context, colorScheme);
      case CustomTabBarVariant.segmented:
        return _buildSegmentedTabBar(context, colorScheme);
      case CustomTabBarVariant.minimal:
        return _buildMinimalTabBar(context, colorScheme);
    }
  }

  Widget _buildStandardTabBar(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withAlpha(51),
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: widget.isScrollable,
            indicatorColor: widget.indicatorColor ?? colorScheme.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: widget.labelColor ?? colorScheme.primary,
            unselectedLabelColor:
                widget.unselectedLabelColor ?? colorScheme.onSurfaceVariant,
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
            ),
            tabs: _buildTabs(),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabViews,
          ),
        ),
      ],
    );
  }

  Widget _buildPillTabBar(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: widget.isScrollable,
            indicator: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: widget.labelColor ?? colorScheme.onSurface,
            unselectedLabelColor:
                widget.unselectedLabelColor ?? colorScheme.onSurfaceVariant,
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
            ),
            tabs: _buildTabs(),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabViews,
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedTabBar(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outline,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              indicator: BoxDecoration(
                color: colorScheme.primaryContainer,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: widget.labelColor ?? colorScheme.onPrimaryContainer,
              unselectedLabelColor:
                  widget.unselectedLabelColor ?? colorScheme.onSurfaceVariant,
              labelStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
              ),
              tabs: _buildTabs(),
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabViews,
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalTabBar(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            isScrollable: widget.isScrollable,
            indicatorColor: Colors.transparent,
            dividerColor: Colors.transparent,
            labelColor: widget.labelColor ?? colorScheme.primary,
            unselectedLabelColor:
                widget.unselectedLabelColor ?? colorScheme.onSurfaceVariant,
            labelStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
            tabs: widget.tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isSelected = index == _tabController.index;

              return AnimatedBuilder(
                animation: _tabController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(tab),
                  );
                },
              );
            }).toList(),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabViews,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTabs() {
    return widget.tabs.asMap().entries.map((entry) {
      final index = entry.key;
      final tab = entry.value;
      final hasIcon =
          widget.tabIcons != null && index < widget.tabIcons!.length;

      if (hasIcon) {
        return Tab(
          icon: Icon(
            widget.tabIcons![index],
            size: 20,
          ),
          text: tab,
          iconMargin: const EdgeInsets.only(bottom: 4),
        );
      } else {
        return Tab(text: tab);
      }
    }).toList();
  }
}

/// Enum defining different tab bar variants
enum CustomTabBarVariant {
  /// Standard tab bar with underline indicator
  standard,

  /// Pill-style tab bar with rounded background indicator
  pills,

  /// Segmented control style with bordered container
  segmented,

  /// Minimal tab bar with subtle styling
  minimal,
}
