import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../models/business_model.dart';
import '../theme/app_theme.dart';
import '../widgets/business_card.dart';
import '../widgets/custom_button.dart' as widgets;
import 'business_details_screen.dart';
import 'add_business_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  int _selectedIndex = 0;
  final _scrollController = ScrollController();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Load businesses
    businessProvider.loadBusinesses();

    // Load user data if authenticated
    if (authProvider.isAuthenticated && authProvider.user != null) {
      userProvider.loadUserData(authProvider.user!.uid);

      // Load favorites after user data is loaded
      Future.delayed(const Duration(milliseconds: 500), () {
        if (userProvider.currentUser != null) {
          businessProvider.loadFavoriteBusinesses(
            userProvider.currentUser!.favorites,
          );
        }
      });
    }
  }

  void _onSearchChanged(String query) {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    businessProvider.setSearchQuery(query);
    setState(() {
      _isSearchExpanded = query.isNotEmpty;
    });
  }

  void _onCategorySelected(String category) {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    businessProvider.setCategory(category);
  }

  void _clearFilters() {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    businessProvider.clearFilters();
    _searchController.clear();
    setState(() {
      _isSearchExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: [_buildHomeTab(), _buildFavoritesTab(), _buildProfileTab()],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedIndex == 0
          ? Consumer2<AuthProvider, UserProvider>(
              builder: (context, authProvider, userProvider, child) {
                if (authProvider.isAuthenticated) {
                  return FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddBusinessScreen(),
                        ),
                      );
                    },
                    backgroundColor: AppTheme.primaryColor,
                    elevation: 4,
                    child: const Icon(Icons.add, color: Colors.white),
                  );
                }
                return const SizedBox.shrink();
              },
            )
          : null,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.favorite_outline,
                selectedIcon: Icons.favorite,
                label: 'Favorites',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'Profile',
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.grey600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryColor : AppTheme.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
      },
      color: AppTheme.primaryColor,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Discover',
                style: TextStyle(
                  color: AppTheme.grey900,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.grey100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isSearchExpanded
                        ? AppTheme.primaryColor.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search businesses...',
                    hintStyle: TextStyle(color: AppTheme.grey600, fontSize: 15),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppTheme.grey600,
                      size: 22,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            icon: Icon(
                              Icons.close,
                              color: AppTheme.grey600,
                              size: 20,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Categories
          SliverToBoxAdapter(
            child: Consumer<BusinessProvider>(
              builder: (context, businessProvider, child) {
                return SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: BusinessCategory.categories.length,
                    itemBuilder: (context, index) {
                      final category = BusinessCategory.categories[index];
                      final isSelected =
                          businessProvider.selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildCategoryChip(
                          category: category,
                          isSelected: isSelected,
                          onTap: () => _onCategorySelected(category),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Filter Clear Button
          SliverToBoxAdapter(
            child: Consumer<BusinessProvider>(
              builder: (context, businessProvider, child) {
                final hasFilters =
                    businessProvider.selectedCategory.isNotEmpty ||
                    businessProvider.selectedLocation.isNotEmpty ||
                    businessProvider.searchQuery.isNotEmpty;

                if (!hasFilters) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.filter_list,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Filters active',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _clearFilters,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Clear all',
                          style: TextStyle(
                            color: AppTheme.grey600,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Businesses List
          Consumer<BusinessProvider>(
            builder: (context, businessProvider, child) {
              if (businessProvider.isLoading) {
                return const SliverFillRemaining(
                  child: widgets.LoadingWidget(
                    message: 'Loading businesses...',
                  ),
                );
              }

              if (businessProvider.errorMessage != null) {
                return SliverFillRemaining(
                  child: widgets.AppErrorWidget(
                    message: businessProvider.errorMessage!,
                    onRetry: () => businessProvider.loadBusinesses(),
                  ),
                );
              }

              if (businessProvider.businesses.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.grey100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.business_outlined,
                              size: 40,
                              color: AppTheme.grey400,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No businesses found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.grey900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.grey600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final business = businessProvider.businesses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: BusinessCard(
                        business: business,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  BusinessDetailsScreen(business: business),
                            ),
                          );
                        },
                      ),
                    );
                  }, childCount: businessProvider.businesses.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.grey300,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.grey700,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return const FavoritesScreen();
  }

  Widget _buildProfileTab() {
    return const ProfileScreen();
  }
}
