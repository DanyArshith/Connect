import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../models/business_model.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart' as widgets;
import 'login_screen.dart';
import 'add_business_screen.dart';
import 'business_details_screen.dart';
import 'edit_business_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );

    if (authProvider.isAuthenticated && authProvider.user != null) {
      userProvider.loadUserData(authProvider.user!.uid);
      // Subscribe to user's businesses in real-time
      businessProvider.loadUserBusinesses(authProvider.user!.uid);
    }
  }

  Future<void> _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: AppTheme.grey600)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer2<AuthProvider, UserProvider>(
        builder: (context, authProvider, userProvider, child) {
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
                    'Profile',
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
              _buildContent(authProvider, userProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(AuthProvider authProvider, UserProvider userProvider) {
    // Check authentication first
    if (!authProvider.isAuthenticated) {
      return SliverFillRemaining(child: _buildSignInPrompt());
    }

    if (userProvider.isLoading) {
      return const SliverFillRemaining(
        child: widgets.LoadingWidget(message: 'Loading profile...'),
      );
    }

    if (userProvider.errorMessage != null) {
      return SliverFillRemaining(
        child: widgets.AppErrorWidget(
          message: userProvider.errorMessage!,
          onRetry: _loadUserData,
        ),
      );
    }

    if (userProvider.currentUser == null) {
      return const SliverFillRemaining(
        child: widgets.LoadingWidget(message: 'Loading profile...'),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(userProvider.currentUser!),
            const SizedBox(height: 20),
            _buildStatsCards(userProvider),
            const SizedBox(height: 16),
            _buildRoleSwitchCard(userProvider),
            const SizedBox(height: 16),
            if (userProvider.isBusinessOwner) ...[
              _buildBusinessOwnerDashboard(userProvider),
              const SizedBox(height: 16),
            ],
            _buildMyBusinessesSection(userProvider),
            _buildMenuSection(userProvider),
            const SizedBox(height: 16),
            _buildAboutCard(),
            const SizedBox(height: 24),
            _buildSignOutButton(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInPrompt() {
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
              child: Icon(
                Icons.person_outline,
                size: 48,
                color: AppTheme.grey400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sign in to view profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create an account or sign in to access your profile',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.grey600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            widgets.CustomButton(
              text: 'Sign In',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon: Icons.login,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.grey900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(fontSize: 14, color: AppTheme.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(UserProvider userProvider) {
    final user = userProvider.currentUser!;

    if (userProvider.isBusinessOwner) {
      // Business owner stats
      final stats = userProvider.businessOwnerStats;
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.business,
                  value: '${stats['totalBusinesses'] ?? 0}',
                  label: 'Businesses',
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  value: '${stats['totalFeedbacks'] ?? 0}',
                  label: 'Reviews',
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  value: '${stats['uniqueCustomers'] ?? 0}',
                  label: 'Customers',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.favorite,
                  value: '${user.favorites.length}',
                  label: 'Favorites',
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Customer stats
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.favorite,
              value: '${user.favorites.length}',
              label: 'Favorites',
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.calendar_today,
              value: _getMemberDuration(user.createdAt),
              label: 'Member',
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.grey900,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 13, color: AppTheme.grey600)),
        ],
      ),
    );
  }

  Widget _buildRoleSwitchCard(UserProvider userProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                userProvider.isBusinessOwner ? Icons.business : Icons.person,
                size: 20,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Role: ${userProvider.isBusinessOwner ? 'Business Owner' : 'Customer'}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.grey900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to switch roles',
                    style: TextStyle(fontSize: 13, color: AppTheme.grey600),
                  ),
                ],
              ),
            ),
            Switch(
              value: userProvider.isBusinessOwner,
              onChanged: (value) async {
                final newRole = value ? 'business_owner' : 'customer';
                await userProvider.updateUserRole(newRole);

                // Reload businesses after role switch
                if (value && userProvider.currentUser != null) {
                  final businessProvider = Provider.of<BusinessProvider>(
                    context,
                    listen: false,
                  );
                  businessProvider.loadUserBusinesses(
                    userProvider.currentUser!.id,
                  );
                }
              },
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessOwnerDashboard(UserProvider userProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.dashboard,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Business Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.grey900,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.grey200),
          _buildMenuItem(
            icon: Icons.add_business,
            title: 'Add New Business',
            subtitle: 'Create a new listing',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddBusinessScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMyBusinessesSection(UserProvider userProvider) {
    return Consumer<BusinessProvider>(
      builder: (context, businessProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.business_outlined,
                        size: 20,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'My Businesses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.grey900,
                      ),
                    ),
                    const Spacer(),
                    if (userProvider.isBusinessOwner)
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AddBusinessScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Add New',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (businessProvider.userBusinesses.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.business_outlined,
                        size: 48,
                        color: AppTheme.grey400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No businesses yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.grey700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start by adding your first business',
                        style: TextStyle(fontSize: 14, color: AppTheme.grey600),
                      ),
                      if (userProvider.isBusinessOwner) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddBusinessScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Add Your First Business',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: businessProvider.userBusinesses.length,
                  itemBuilder: (context, index) {
                    final business = businessProvider.userBusinesses[index];
                    return Column(
                      children: [
                        if (index > 0)
                          Divider(height: 1, color: AppTheme.grey200),
                        _buildBusinessItem(business),
                      ],
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBusinessItem(Business business) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BusinessDetailsScreen(business: business),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: business.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            business.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.business_outlined,
                                color: AppTheme.grey600,
                              );
                            },
                          ),
                        )
                      : Icon(Icons.business_outlined, color: AppTheme.grey600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.grey900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        business.category,
                        style: TextStyle(fontSize: 13, color: AppTheme.grey600),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            business.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.grey600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${business.reviewCount} reviews)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppTheme.grey600),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              EditBusinessScreen(business: business),
                        ),
                      );
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(business);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 18,
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            size: 18,
                            color: AppTheme.errorColor,
                          ),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(Business business) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Business'),
        content: Text(
          'Are you sure you want to delete "${business.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.grey600)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final businessProvider = Provider.of<BusinessProvider>(
                context,
                listen: false,
              );
              final success = await businessProvider.deleteBusiness(
                business.id,
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Business deleted successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(UserProvider userProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (!userProvider.isBusinessOwner) ...[
            _buildMenuItem(
              icon: Icons.store_outlined,
              title: 'Start Your Business',
              subtitle: 'List your business on LocalConnect',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddBusinessScreen(),
                  ),
                );
              },
            ),
            Divider(height: 1, color: AppTheme.grey200),
            _buildMenuItem(
              icon: Icons.business_center_outlined,
              title: 'Become Business Owner',
              subtitle: 'Switch to business owner mode',
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Switch to Business Owner'),
                    content: const Text(
                      'Do you want to switch to Business Owner mode? You can switch back anytime.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: AppTheme.grey600),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(
                          'Switch',
                          style: TextStyle(color: AppTheme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await userProvider.updateUserRole('business_owner');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Switched to Business Owner mode'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                }
              },
            ),
            Divider(height: 1, color: AppTheme.grey200),
          ],
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage your alerts',
            onTap: () {
              _showSettingsDialog();
            },
          ),
          Divider(height: 1, color: AppTheme.grey200),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App preferences',
            onTap: () {
              _showSettingsDialog();
            },
          ),
          Divider(height: 1, color: AppTheme.grey200),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get assistance',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('Help & Support'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'If you need help, please contact us:',
                        style: TextStyle(fontSize: 14, color: AppTheme.grey700),
                      ),
                      const SizedBox(height: 12),
                      Text('Email: support@localconnect.com'),
                      const SizedBox(height: 4),
                      Text('Phone: 1800-LOCAL-APP'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildSettingsOption(
              icon: Icons.notifications_active_outlined,
              title: 'Push Notifications',
              subtitle: 'Get alerts for new reviews',
              onTap: () {
                // TODO: Implement notification settings
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _buildSettingsOption(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Coming soon',
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppTheme.grey600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.grey400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.grey100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: AppTheme.grey700),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.grey900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: AppTheme.grey600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.grey400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'About LocalConnect',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.grey900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'LocalConnect helps you discover and connect with local businesses in your area. Support small businesses and find the services you need.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.grey600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return widgets.CustomButton(
      text: 'Sign Out',
      onPressed: _signOut,
      backgroundColor: AppTheme.errorColor,
      icon: Icons.logout,
    );
  }

  String _getMemberDuration(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays < 30) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo';
    } else {
      return '${(difference.inDays / 365).floor()}y';
    }
  }

  // ignore: unused_element
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
