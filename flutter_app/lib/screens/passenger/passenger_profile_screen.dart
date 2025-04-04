import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_app/utils/app_theme.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/screens/auth/login_screen.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/widgets/loading_overlay.dart';
import 'package:flutter_app/models/user_model.dart';

class PassengerProfileScreen extends StatefulWidget {
  const PassengerProfileScreen({Key? key}) : super(key: key);

  @override
  State<PassengerProfileScreen> createState() => _PassengerProfileScreenState();
}

class _PassengerProfileScreenState extends State<PassengerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _emailController.text = user.email;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateProfile({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      // Avatar would be uploaded separately in a real app
    });

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thông tin thành công'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thông tin thất bại. Vui lòng thử lại sau.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    setState(() => _isLoading = false);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final user = authProvider.currentUser;
            if (user == null) {
              return const Center(
                child: Text('Không tìm thấy thông tin người dùng'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile header
                  GestureDetector(
                    onTap: _isEditing ? _pickImage : null,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          backgroundImage:
                              _imageFile != null
                                  ? FileImage(_imageFile!) as ImageProvider
                                  : user.avatar != null
                                  ? NetworkImage(user.avatar!) as ImageProvider
                                  : null,
                          child:
                              user.avatar == null && _imageFile == null
                                  ? Text(
                                    user.name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  )
                                  : null,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User info
                  if (_isEditing) _buildEditForm() else _buildProfileInfo(user),

                  const SizedBox(height: 32),

                  // Action buttons
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Hủy',
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _loadUserData();
                                _imageFile = null;
                              });
                            },
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: 'Lưu',
                            onPressed: _updateProfile,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.history,
                          title: 'Lịch sử chuyến đi',
                          onTap: () {
                            // Navigate to trip history
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.payment,
                          title: 'Phương thức thanh toán',
                          onTap: () {
                            // Navigate to payment methods
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.location_on_outlined,
                          title: 'Địa điểm đã lưu',
                          onTap: () {
                            // Navigate to saved locations
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.help_outline,
                          title: 'Trợ giúp & Hỗ trợ',
                          onTap: () {
                            // Navigate to help & support
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.settings_outlined,
                          title: 'Cài đặt',
                          onTap: () {
                            // Navigate to settings
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Đăng xuất',
                          onPressed: _logout,
                          backgroundColor: AppColors.error,
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileInfo(UserModel user) {
    return Column(
      children: [
        Text(
          user.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          user.email,
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          user.phone,
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem(
              value: user.totalTrips?.toString() ?? '0',
              label: 'Chuyến đi',
            ),
            Container(
              height: 30,
              width: 1,
              color: Colors.grey[300],
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            _buildStatItem(
              value:
                  user.rating != null ? user.rating!.toStringAsFixed(1) : 'N/A',
              label: 'Đánh giá',
              isRating: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    bool isRating = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (isRating && value != 'N/A')
              const Icon(Icons.star, color: Colors.amber, size: 18),
          ],
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập họ và tên';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }
              if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                return 'Số điện thoại không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
