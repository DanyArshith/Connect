import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/business_provider.dart';
import '../models/business_model.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart' as widgets;
import '../services/firebase_service.dart';

class EditBusinessScreen extends StatefulWidget {
  final Business business;

  const EditBusinessScreen({super.key, required this.business});

  @override
  State<EditBusinessScreen> createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends State<EditBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedCategory = '';
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _nameController.text = widget.business.name;
    _descriptionController.text = widget.business.description;
    _locationController.text = widget.business.location;
    _contactController.text = widget.business.contact;
    _selectedCategory = widget.business.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Show source selection
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.camera_alt, color: AppTheme.primaryColor),
                ),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    }
  }

  Future<void> _updateBusiness() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory.isEmpty) {
      _showSnackBar('Please select a category');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = widget.business.imageUrl;

      if (_selectedImage != null) {
        final userId = FirebaseService.currentUser?.uid ?? '';
        final imagePath =
            'business_images/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await FirebaseService.uploadImage(
          _selectedImage!,
          imagePath,
        );
      }

      final updatedBusiness = widget.business.copyWith(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        contact: _contactController.text.trim(),
        imageUrl: imageUrl,
      );

      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      final success = await businessProvider.updateBusiness(
        widget.business.id,
        updatedBusiness,
      );

      if (success) {
        _showSnackBar('Business updated successfully!', isError: false);
        Navigator.of(context).pop();
      } else {
        _showSnackBar(
          businessProvider.errorMessage ?? 'Failed to update business',
        );
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
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
      appBar: AppBar(
        title: const Text('Edit Business'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.grey900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const widgets.LoadingWidget(message: 'Updating business...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Text
                    Text(
                      'Edit Business Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.grey900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Update your business information',
                      style: TextStyle(fontSize: 14, color: AppTheme.grey600),
                    ),

                    const SizedBox(height: 32),

                    // Image Selection
                    _buildImagePicker(),

                    const SizedBox(height: 24),

                    // Business Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Business Name',
                      icon: Icons.business_outlined,
                      hint: 'Enter your business name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter business name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Category Dropdown
                    _buildCategoryDropdown(),

                    const SizedBox(height: 16),

                    // Location
                    _buildTextField(
                      controller: _locationController,
                      label: 'Location',
                      icon: Icons.location_on_outlined,
                      hint: 'City or area',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Contact
                    _buildTextField(
                      controller: _contactController,
                      label: 'Contact Number',
                      icon: Icons.phone_outlined,
                      hint: 'Enter phone number',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter contact number';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Description
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      icon: Icons.description_outlined,
                      hint: 'Tell us about your business',
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Update Button
                    widgets.CustomButton(
                      text: 'Update Business',
                      onPressed: _updateBusiness,
                      isLoading: _isLoading,
                      icon: Icons.check,
                    ),

                    const SizedBox(height: 12),

                    // Cancel Button
                    widgets.CustomButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
                      isOutlined: true,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Business Image',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey900,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(Optional)',
              style: TextStyle(fontSize: 13, color: AppTheme.grey600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: _selectedImage != null || widget.business.imageUrl != null
                  ? Colors.black
                  : AppTheme.grey100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    _selectedImage != null || widget.business.imageUrl != null
                    ? Colors.transparent
                    : AppTheme.grey300,
                width: 1.5,
              ),
            ),
            child: _selectedImage != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _selectedImage = null),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppTheme.grey900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : widget.business.imageUrl != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.business.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _selectedImage = null),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppTheme.grey900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : _buildPlaceholderImage(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add_photo_alternate_outlined,
            size: 32,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Add Business Image',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to select from gallery or camera',
          style: TextStyle(fontSize: 13, color: AppTheme.grey600),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedCategory.isEmpty ? null : _selectedCategory,
          decoration: InputDecoration(
            labelText: 'Category',
            hintText: 'Select a category',
            hintStyle: TextStyle(color: AppTheme.grey500),
            prefixIcon: Icon(
              Icons.category_outlined,
              size: 20,
              color: AppTheme.grey600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.errorColor, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: BusinessCategory.categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Row(
                children: [
                  Text(
                    BusinessCategory.categoryIcons[category] ?? '🏢',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(category, style: const TextStyle(fontSize: 15)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value ?? '';
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
          icon: Icon(Icons.keyboard_arrow_down, color: AppTheme.grey600),
          dropdownColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.grey500),
        labelStyle: TextStyle(color: AppTheme.grey600, fontSize: 14),
        prefixIcon: Icon(icon, size: 20, color: AppTheme.grey600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.errorColor, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 16 : 16,
        ),
        alignLabelWithHint: maxLines > 1,
      ),
      validator: validator,
    );
  }
}
