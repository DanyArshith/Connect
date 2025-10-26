import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/business_provider.dart';
import '../models/business_model.dart';
import '../theme/app_theme.dart';
// ignore: unused_import
import '../widgets/custom_button.dart' as widgets;
import 'edit_business_screen.dart';

class BusinessDetailsScreen extends StatefulWidget {
  final Business business;

  const BusinessDetailsScreen({super.key, required this.business});

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBusinessDetails();
    });
  }

  void _loadBusinessDetails() {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    businessProvider.getBusinessById(widget.business.id);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showSnackBar('Could not make phone call');
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Could not open WhatsApp');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero Image Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.grey900,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: AppTheme.grey900),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Consumer2<AuthProvider, UserProvider>(
                builder: (context, authProvider, userProvider, child) {
                  // Show edit button if user owns this business
                  if (authProvider.isAuthenticated &&
                      authProvider.user != null &&
                      widget.business.ownerId == authProvider.user!.uid) {
                    return Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditBusinessScreen(business: widget.business),
                            ),
                          );
                        },
                        icon: Icon(Icons.edit, color: AppTheme.grey900),
                      ),
                    );
                  }

                  // Show favorite button for other users
                  return Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        final isFavorite = userProvider.isFavoriteLocal(
                          widget.business.id,
                        );
                        return IconButton(
                          onPressed: () async {
                            await userProvider.toggleFavorite(
                              widget.business.id,
                            );
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : AppTheme.grey900,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: widget.business.imageUrl != null
                  ? Hero(
                      tag: 'business_image_${widget.business.id}',
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            widget.business.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                          ),
                          // Gradient overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 100,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildPlaceholderImage(),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.business.name,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.grey900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category & Location Row
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.category_outlined,
                            label: widget.business.category,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            icon: Icons.location_on_outlined,
                            label: widget.business.location,
                            color: AppTheme.grey700,
                          ),
                        ],
                      ),

                      // Rating
                      if (widget.business.rating > 0) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              widget.business.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.grey900,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${widget.business.reviewCount} reviews)',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.grey600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Contact Actions
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.phone_outlined,
                          label: 'Call',
                          color: AppTheme.primaryColor,
                          onPressed: () =>
                              _makePhoneCall(widget.business.contact),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.chat_bubble_outline,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          onPressed: () =>
                              _openWhatsApp(widget.business.contact),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Description
                if (widget.business.description.isNotEmpty) ...[
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.grey900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.business.description,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: AppTheme.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Feedback Section
                _buildFeedbackSection(),

                const SizedBox(height: 8),

                // Business Information
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Business Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.grey900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoItem(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: widget.business.contact,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        icon: Icons.category_outlined,
                        label: 'Category',
                        value: widget.business.category,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value: widget.business.location,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Listed on',
                        value: _formatDate(widget.business.createdAt),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppTheme.grey100,
      child: Center(
        child: Icon(Icons.business_outlined, size: 80, color: AppTheme.grey400),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.grey100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppTheme.grey700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.grey600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.grey900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildFeedbackSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Reviews & Ratings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.grey900,
                ),
              ),
              const Spacer(),
              Consumer<BusinessProvider>(
                builder: (context, businessProvider, child) {
                  return TextButton(
                    onPressed: () => _showFeedbackModal(),
                    child: Text(
                      'Add Review',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Display existing feedbacks
          Consumer<BusinessProvider>(
            builder: (context, businessProvider, child) {
              if (widget.business.feedbacks.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.star_outline,
                        size: 48,
                        color: AppTheme.grey400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No reviews yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.grey700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Be the first to review this business',
                        style: TextStyle(fontSize: 14, color: AppTheme.grey600),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: widget.business.feedbacks.take(3).map((feedback) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildFeedbackItem(feedback),
                  );
                }).toList(),
              );
            },
          ),

          // Show more button if there are more than 3 feedbacks
          if (widget.business.feedbacks.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: TextButton(
                  onPressed: () => _showAllFeedbacks(),
                  child: Text(
                    'View all ${widget.business.feedbacks.length} reviews',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedbackItem(Map<String, dynamic> feedback) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  feedback['userName']
                          ?.toString()
                          .substring(0, 1)
                          .toUpperCase() ??
                      'U',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback['userName'] ?? 'Anonymous',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.grey900,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (feedback['rating'] ?? 0).toInt()
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                _formatFeedbackDate(feedback['createdAt']),
                style: TextStyle(fontSize: 12, color: AppTheme.grey600),
              ),
            ],
          ),
          if (feedback['comment']?.toString().isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              feedback['comment'] ?? '',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.grey700,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFeedbackModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FeedbackModal(businessId: widget.business.id),
    );
  }

  void _showAllFeedbacks() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AllFeedbacksModal(business: widget.business),
    );
  }

  String _formatFeedbackDate(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return _formatDate(date);
    }
  }
}

class _FeedbackModal extends StatefulWidget {
  final String businessId;

  const _FeedbackModal({required this.businessId});

  @override
  State<_FeedbackModal> createState() => _FeedbackModalState();
}

class _FeedbackModalState extends State<_FeedbackModal> {
  final _commentController = TextEditingController();
  double _rating = 0.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please write a comment'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null && userProvider.currentUser != null) {
      final success = await businessProvider.addFeedback(
        widget.businessId,
        authProvider.user!.uid,
        userProvider.currentUser!.name,
        _commentController.text.trim(),
        _rating,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Write a Review',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.grey900,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: AppTheme.grey600),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.grey900,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _rating = (index + 1).toDouble()),
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  size: 32,
                  color: Colors.amber,
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          Text(
            'Comment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.grey900,
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your experience...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Submit Review',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllFeedbacksModal extends StatelessWidget {
  final Business business;

  const _AllFeedbacksModal({required this.business});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'All Reviews (${business.feedbacks.length})',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.grey900,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: AppTheme.grey600),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: ListView.builder(
              itemCount: business.feedbacks.length,
              itemBuilder: (context, index) {
                final feedback = business.feedbacks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildFeedbackItem(feedback),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackItem(Map<String, dynamic> feedback) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  feedback['userName']
                          ?.toString()
                          .substring(0, 1)
                          .toUpperCase() ??
                      'U',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback['userName'] ?? 'Anonymous',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.grey900,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (feedback['rating'] ?? 0).toInt()
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                _formatFeedbackDate(feedback['createdAt']),
                style: TextStyle(fontSize: 12, color: AppTheme.grey600),
              ),
            ],
          ),
          if (feedback['comment']?.toString().isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              feedback['comment'] ?? '',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.grey700,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatFeedbackDate(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
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
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}
