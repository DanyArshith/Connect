import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/business_card.dart';
import '../widgets/custom_button.dart' as widgets;
import 'business_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  void _loadFavorites() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );

    if (authProvider.isAuthenticated && authProvider.user != null) {
      // Load user data first
      userProvider.loadUserData(authProvider.user!.uid);

      // Load favorites directly from the separate collection
      businessProvider.loadUserFavorites(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer2<UserProvider, BusinessProvider>(
        builder: (context, userProvider, businessProvider, child) {
          return CustomScrollView(
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
                    'Favorites',
                    style: TextStyle(
                      color: AppTheme.grey900,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),

              // Content
              _buildContent(userProvider, businessProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(
    UserProvider userProvider,
    BusinessProvider businessProvider,
  ) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check authentication first
        if (!authProvider.isAuthenticated) {
          return SliverFillRemaining(
            child: _buildEmptyState(
              icon: Icons.favorite_border,
              title: 'Sign in to view favorites',
              subtitle:
                  'Create an account or sign in to save your favorite businesses',
            ),
          );
        }

        if (businessProvider.isLoading) {
          return const SliverFillRemaining(
            child: widgets.LoadingWidget(message: 'Loading favorites...'),
          );
        }

        if (businessProvider.errorMessage != null) {
          return SliverFillRemaining(
            child: widgets.AppErrorWidget(
              message: businessProvider.errorMessage!,
              onRetry: _loadFavorites,
            ),
          );
        }

        if (businessProvider.favoriteBusinesses.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(
              icon: Icons.favorite_border,
              title: 'No favorites yet',
              subtitle: 'Start exploring and add businesses to your favorites',
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final business = businessProvider.favoriteBusinesses[index];
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
            }, childCount: businessProvider.favoriteBusinesses.length),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppTheme.grey400),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.grey600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
