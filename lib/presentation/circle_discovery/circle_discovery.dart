import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/app_menu_drawer.dart';
import './widgets/circle_card_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/filter_modal_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/sort_button_widget.dart';

class CircleDiscovery extends ConsumerStatefulWidget {
  const CircleDiscovery({super.key});

  @override
  ConsumerState<CircleDiscovery> createState() => _CircleDiscoveryState();
}

class _CircleDiscoveryState extends ConsumerState<CircleDiscovery>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription? _authSubscription;
  StreamSubscription? _circlesSubscription;

  // ⬇️ --- 新規: モード管理用の変数 --- ⬇️
  bool _isSelectionMode = false;
  String? _sourceCircleId;
  // ⬆️ ---------------------------- ⬆️

  String _currentSort = 'Relevance';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isLoadingMore = false;

  Map<String, dynamic> _activeFilters = {
    'universities': <String>[],
    'activityTypes': <String>[],
    'skills': <String>[],
    'minMembers': 0,
    'maxMembers': 100,
  };

  final List<String> _tabs = [
    'All',
    'Sports',
    'Culture',
    'Arts',
    'Academic',
    'Other'
  ];

  List<CircleModel> _allCircles = [];
  List<CircleModel> _filteredCircles = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _scrollController.addListener(_onScroll);
    _tabController.addListener(_onTabChanged);
    
    _setupAuthListener();
  }

  // ⬇️ --- 新規: 画面遷移引数の取得 (didChangeDependencies) --- ⬇️
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _isSelectionMode = args['isSelectionMode'] ?? false;
        _sourceCircleId = args['sourceCircleId'];
      });
    }
  }
  // ⬆️ ----------------------------------------------------- ⬆️

  void _setupAuthListener() {
    final authService = ref.read(firebaseAuthServiceProvider);
    _authSubscription = authService.authStateChanges.listen((user) {
      if (user != null) {
        _loadCircles();
      }
    });
  }

  void _loadCircles() {
    _circlesSubscription?.cancel();

    final firestoreService = ref.read(firestoreServiceProvider);
    _circlesSubscription = firestoreService.getCirclesStream().listen(
      (circles) {
        if (mounted) {
          setState(() {
            _allCircles = circles;
            _filteredCircles = List.from(_allCircles);
            _applyFiltersAndSearch();
          });
        }
      },
      onError: (error) {
        print("CircleDiscovery Error: $error");
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _circlesSubscription?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreCircles();
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _filterByTab(_tabs[_tabController.index]);
    }
  }

  void _filterByTab(String tab) {
    setState(() {
      if (tab == 'All') {
        _filteredCircles = List.from(_allCircles);
      } else {
        _filteredCircles = _allCircles.where((circle) {
          return circle.category.toLowerCase() == tab.toLowerCase();
        }).toList();
      }
      _applyFiltersAndSearch();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFiltersAndSearch();
    });
  }

  void _onSortChanged(String sortOption) {
    setState(() {
      _currentSort = sortOption;
      _sortCircles();
    });
  }

  void _onFiltersChanged(Map<String, dynamic> filters) {
    setState(() {
      _activeFilters = filters;
      _applyFiltersAndSearch();
    });
  }

  void _applyFiltersAndSearch() {
    List<CircleModel> filtered = List.from(_filteredCircles);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((circle) {
        final name = circle.circleName.toLowerCase();
        final description = circle.description.toLowerCase();
        final university = circle.universityName.toLowerCase();
        final query = _searchQuery.toLowerCase();

        return name.contains(query) ||
            description.contains(query) ||
            university.contains(query);
      }).toList();
    }

    if ((_activeFilters['universities'] as List).isNotEmpty) {
      filtered = filtered.where((circle) {
        return (_activeFilters['universities'] as List)
            .contains(circle.universityName);
      }).toList();
    }

    if ((_activeFilters['activityTypes'] as List).isNotEmpty) {
      filtered = filtered.where((circle) {
        return (_activeFilters['activityTypes'] as List)
            .contains(circle.category);
      }).toList();
    }

    if ((_activeFilters['skills'] as List).isNotEmpty) {
      filtered = filtered.where((circle) {
        return (_activeFilters['skills'] as List)
            .any((skill) => circle.socialMediaLinks.contains(skill));
      }).toList();
    }

    final minMembers = _activeFilters['minMembers'] as int;
    final maxMembers = _activeFilters['maxMembers'] as int;
    filtered = filtered.where((circle) {
      return circle.memberCount >= minMembers &&
          circle.memberCount <= maxMembers;
    }).toList();

    // ⬇️ 選択モードの場合、自分自身（sourceCircleId）はリストから除外する ⬇️
    if (_isSelectionMode && _sourceCircleId != null) {
      filtered = filtered.where((c) => c.id != _sourceCircleId).toList();
    }
    // ⬆️ ------------------------------------------------------- ⬆️

    setState(() {
      _filteredCircles = filtered;
      _sortCircles();
    });
  }

  void _sortCircles() {
    switch (_currentSort) {
      case 'Distance':
        _filteredCircles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Member Count':
        _filteredCircles.sort((a, b) => b.memberCount.compareTo(a.memberCount));
        break;
      case 'Activity Level':
        _filteredCircles.sort((a, b) => b.isVerified ? 1 : -1);
        break;
      case 'Recently Active':
        _filteredCircles.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      default: 
        break;
    }
  }

  Future<void> _loadMoreCircles() async {
    if (_isLoadingMore) return;
    setState(() { _isLoadingMore = true; });
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _isLoadingMore = false; });
  }

  Future<void> _refreshCircles() async {
    setState(() { _isLoading = true; });
    _loadCircles();
    setState(() { _isLoading = false; });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModalWidget(
        currentFilters: _activeFilters,
        onFiltersChanged: _onFiltersChanged,
      ),
    );
  }

  void _onVoiceSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice search activated'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<Widget> _buildActiveFilterChips() {
    List<Widget> chips = [];
    for (String university in _activeFilters['universities'] as List<String>) {
      chips.add(FilterChipWidget(label: university, isSelected: true, onRemove: () { setState(() { (_activeFilters['universities'] as List<String>).remove(university); _applyFiltersAndSearch(); }); },),);
    }
    for (String type in _activeFilters['activityTypes'] as List<String>) {
      chips.add(FilterChipWidget(label: type, isSelected: true, onRemove: () { setState(() { (_activeFilters['activityTypes'] as List<String>).remove(type); _applyFiltersAndSearch(); }); },),);
    }
    for (String skill in _activeFilters['skills'] as List<String>) {
      chips.add(FilterChipWidget(label: skill, isSelected: true, onRemove: () { setState(() { (_activeFilters['skills'] as List<String>).remove(skill); _applyFiltersAndSearch(); }); },),);
    }
    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorScheme.surface,
      
      // 選択モードならドロワーは無効化
      endDrawer: _isSelectionMode ? null : const AppMenuDrawer(),
      
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              // ⬇️ タイトルを変更 ⬇️
              title: Text(
                _isSelectionMode ? 'リクエスト送信先を選択' : 'Circle Discovery',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              floating: true,
              pinned: true,
              snap: true,
              elevation: 0,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              actions: [
                // 選択モードならメニューボタンは非表示
                if (!_isSelectionMode)
                  IconButton(
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer(); 
                    },
                    icon: CustomIconWidget(
                      iconName: 'menu', 
                      color: colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(31.h), 
                child: Container(
                  color: colorScheme.surface,
                  child: Column(
                    children: [
                      // ... (SearchBar, TabBar など変更なし) ...
                      SearchBarWidget(controller: _searchController, onChanged: _onSearchChanged, onVoiceSearch: _onVoiceSearch, hintText: 'Search circles in Japanese or English...',),
                      Container(margin: EdgeInsets.symmetric(horizontal: 4.w), child: TabBar(controller: _tabController, isScrollable: true, indicatorColor: colorScheme.primary, labelColor: colorScheme.primary, unselectedLabelColor: colorScheme.onSurfaceVariant, tabs: _tabs.map((tab) => Tab(text: tab)).toList(),),),
                      SizedBox(height: 1.h),
                      SizedBox(height: 6.h, child: Row(children: [Expanded(child: ListView(scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal: 4.w), children: [..._buildActiveFilterChips(), if (_buildActiveFilterChips().isEmpty) FilterChipWidget(label: 'All Circles', count: _filteredCircles.length, isSelected: false,),],),), Padding(padding: EdgeInsets.only(right: 4.w), child: SortButtonWidget(currentSort: _currentSort, onSortChanged: _onSortChanged,),),],),),
                      SizedBox(height: 1.h),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: _refreshCircles,
          child: _filteredCircles.isEmpty
              ? EmptyStateWidget(
                  title: 'No circles found',
                  description: 'Try adjusting your filters or search terms.',
                  actionText: 'Adjust Filters',
                  onActionPressed: _showFilterModal,
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  itemCount: _filteredCircles.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _filteredCircles.length) {
                      return Container(padding: EdgeInsets.all(4.w), child: const Center(child: CircularProgressIndicator()),);
                    }

                    final circle = _filteredCircles[index];
                    return CircleCardWidget(
                      circleData: circle,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/circle-profile',
                          arguments: {
                            'circleId': circle.id,
                            // ⬇️ モード情報を引き継ぐ ⬇️
                            'isSelectionMode': _isSelectionMode,
                            'sourceCircleId': _sourceCircleId,
                          },
                        );
                      },
                      onLongPress: () {
                        if (!_isSelectionMode) { // 選択モード中は無効化
                          _showQuickActions(context, circle);
                        }
                      },
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterModal,
        child: CustomIconWidget(
          iconName: 'tune',
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context, CircleModel circle) {
     // ... (変更なし) ...
     final theme = Theme.of(context);
     final colorScheme = theme.colorScheme;
     showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (context) => Container(decoration: BoxDecoration(color: colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 40, height: 4, margin: EdgeInsets.symmetric(vertical: 2.h), decoration: BoxDecoration(color: colorScheme.outline, borderRadius: BorderRadius.circular(2),),), ListTile(leading: CustomIconWidget(iconName: 'favorite_border', color: colorScheme.onSurface, size: 24,), title: const Text('Save to Favorites'), onTap: () {Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${circle.circleName} saved to favorites')),);},), ListTile(leading: CustomIconWidget(iconName: 'share', color: colorScheme.onSurface, size: 24,), title: const Text('Share Circle'), onTap: () {Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Circle shared')),);},), ListTile(leading: CustomIconWidget(iconName: 'search', color: colorScheme.onSurface, size: 24,), title: const Text('Find Similar Circles'), onTap: () {Navigator.pop(context);},), SizedBox(height: 2.h),],),),);
  }
}