import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_theme.dart';
import 'package:flutter_app/widgets/loading_overlay.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _passengers = [
    {
      'id': 'P001',
      'name': 'Nguyễn Văn A',
      'email': 'nguyenvana@example.com',
      'phone': '0901234567',
      'trips': 15,
      'rating': 4.8,
      'status': 'Hoạt động',
    },
    {
      'id': 'P002',
      'name': 'Lê Thị B',
      'email': 'lethib@example.com',
      'phone': '0901234568',
      'trips': 8,
      'rating': 4.5,
      'status': 'Hoạt động',
    },
    {
      'id': 'P003',
      'name': 'Trần Văn C',
      'email': 'tranvanc@example.com',
      'phone': '0901234569',
      'trips': 20,
      'rating': 4.9,
      'status': 'Hoạt động',
    },
    {
      'id': 'P004',
      'name': 'Phạm Thị D',
      'email': 'phamthid@example.com',
      'phone': '0901234570',
      'trips': 5,
      'rating': 4.2,
      'status': 'Bị khóa',
    },
  ];

  final List<Map<String, dynamic>> _drivers = [
    {
      'id': 'D001',
      'name': 'Hoàng Văn E',
      'email': 'hoangvane@example.com',
      'phone': '0901234571',
      'trips': 150,
      'rating': 4.7,
      'vehicle': 'Toyota Vios - 51A-12345',
      'status': 'Hoạt động',
    },
    {
      'id': 'D002',
      'name': 'Ngô Thị F',
      'email': 'ngothif@example.com',
      'phone': '0901234572',
      'trips': 120,
      'rating': 4.6,
      'vehicle': 'Honda City - 51A-23456',
      'status': 'Hoạt động',
    },
    {
      'id': 'D003',
      'name': 'Đỗ Văn G',
      'email': 'dovang@example.com',
      'phone': '0901234573',
      'trips': 200,
      'rating': 4.9,
      'vehicle': 'Hyundai Accent - 51A-34567',
      'status': 'Hoạt động',
    },
    {
      'id': 'D004',
      'name': 'Vũ Thị H',
      'email': 'vuthih@example.com',
      'phone': '0901234574',
      'trips': 80,
      'rating': 4.3,
      'vehicle': 'Kia Morning - 51A-45678',
      'status': 'Bị khóa',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredPassengers() {
    if (_searchQuery.isEmpty) return _passengers;

    return _passengers.where((passenger) {
      return passenger['name'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          passenger['email'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          passenger['phone'].contains(_searchQuery);
    }).toList();
  }

  List<Map<String, dynamic>> _getFilteredDrivers() {
    if (_searchQuery.isEmpty) return _drivers;

    return _drivers.where((driver) {
      return driver['name'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          driver['email'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver['phone'].contains(_searchQuery) ||
          driver['vehicle'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _showUserDetails(Map<String, dynamic> user, bool isDriver) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Chi tiết ${isDriver ? 'tài xế' : 'hành khách'}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('ID:', user['id']),
                  _buildDetailRow('Họ tên:', user['name']),
                  _buildDetailRow('Email:', user['email']),
                  _buildDetailRow('Số điện thoại:', user['phone']),
                  _buildDetailRow('Số chuyến đi:', user['trips'].toString()),
                  _buildDetailRow('Đánh giá:', '${user['rating']} ⭐'),
                  if (isDriver) _buildDetailRow('Xe:', user['vehicle']),
                  _buildDetailRow('Trạng thái:', user['status']),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditUserDialog(user, isDriver);
                },
                child: const Text('Chỉnh sửa'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user, bool isDriver) {
    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);
    final phoneController = TextEditingController(text: user['phone']);
    final vehicleController =
        isDriver ? TextEditingController(text: user['vehicle']) : null;
    String status = user['status'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Chỉnh sửa ${isDriver ? 'tài xế' : 'hành khách'}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Họ tên'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                    ),
                  ),
                  if (isDriver) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: vehicleController,
                      decoration: const InputDecoration(labelText: 'Xe'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Hoạt động',
                            child: Text('Hoạt động'),
                          ),
                          DropdownMenuItem(
                            value: 'Bị khóa',
                            child: Text('Bị khóa'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              status = value;
                            });
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  // In a real app, we would update the user data
                  setState(() {
                    user['name'] = nameController.text;
                    user['email'] = emailController.text;
                    user['phone'] = phoneController.text;
                    if (isDriver) {
                      user['vehicle'] = vehicleController!.text;
                    }
                    user['status'] = status;
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cập nhật thông tin thành công'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
    );
  }

  void _showAddUserDialog(bool isDriver) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final vehicleController = isDriver ? TextEditingController() : null;
    String status = 'Hoạt động';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Thêm ${isDriver ? 'tài xế' : 'hành khách'} mới'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Họ tên'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                    ),
                  ),
                  if (isDriver) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: vehicleController,
                      decoration: const InputDecoration(labelText: 'Xe'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Hoạt động',
                            child: Text('Hoạt động'),
                          ),
                          DropdownMenuItem(
                            value: 'Bị khóa',
                            child: Text('Bị khóa'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              status = value;
                            });
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  // In a real app, we would add the user to the database
                  final newId =
                      isDriver
                          ? 'D${_drivers.length + 1}'.padLeft(4, '0')
                          : 'P${_passengers.length + 1}'.padLeft(4, '0');

                  final newUser = {
                    'id': newId,
                    'name': nameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'trips': 0,
                    'rating': 0.0,
                    'status': status,
                  };

                  if (isDriver) {
                    newUser['vehicle'] = vehicleController!.text;
                    setState(() {
                      _drivers.add(newUser);
                    });
                  } else {
                    setState(() {
                      _passengers.add(newUser);
                    });
                  }

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Thêm ${isDriver ? 'tài xế' : 'hành khách'} mới thành công',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Thêm'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> user, bool isDriver) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa ${isDriver ? 'tài xế' : 'hành khách'} ${user['name']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  // In a real app, we would delete the user from the database
                  setState(() {
                    if (isDriver) {
                      _drivers.removeWhere(
                        (driver) => driver['id'] == user['id'],
                      );
                    } else {
                      _passengers.removeWhere(
                        (passenger) => passenger['id'] == user['id'],
                      );
                    }
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Xóa ${isDriver ? 'tài xế' : 'hành khách'} thành công',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text(
                  'Xóa',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Hành khách'), Tab(text: 'Tài xế')],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm người dùng...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildPassengerList(), _buildDriverList()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddUserDialog(_tabController.index == 1);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPassengerList() {
    final filteredPassengers = _getFilteredPassengers();

    return filteredPassengers.isEmpty
        ? const Center(child: Text('Không tìm thấy hành khách nào'))
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredPassengers.length,
          itemBuilder: (context, index) {
            final passenger = filteredPassengers[index];
            return _buildUserCard(passenger, false);
          },
        );
  }

  Widget _buildDriverList() {
    final filteredDrivers = _getFilteredDrivers();

    return filteredDrivers.isEmpty
        ? const Center(child: Text('Không tìm thấy tài xế nào'))
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredDrivers.length,
          itemBuilder: (context, index) {
            final driver = filteredDrivers[index];
            return _buildUserCard(driver, true);
          },
        );
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isDriver) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            user['name'].substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              user['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color:
                    user['status'] == 'Hoạt động'
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                user['status'],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color:
                      user['status'] == 'Hoạt động'
                          ? AppColors.success
                          : AppColors.error,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user['email'],
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            Text(
              user['phone'],
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            if (isDriver)
              Text(
                user['vehicle'],
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  user['rating'].toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.directions_car, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '${user['trips']} chuyến',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => _showEditUserDialog(user, isDriver),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _showDeleteConfirmDialog(user, isDriver),
            ),
          ],
        ),
        onTap: () => _showUserDetails(user, isDriver),
      ),
    );
  }
}
