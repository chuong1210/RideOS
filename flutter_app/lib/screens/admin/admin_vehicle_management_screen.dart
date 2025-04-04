import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_theme.dart';
import 'package:flutter_app/widgets/loading_overlay.dart';

class AdminVehicleManagementScreen extends StatefulWidget {
  const AdminVehicleManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminVehicleManagementScreen> createState() =>
      _AdminVehicleManagementScreenState();
}

class _AdminVehicleManagementScreenState
    extends State<AdminVehicleManagementScreen> {
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedFilter = 'Tất cả';

  final List<String> _filterOptions = [
    'Tất cả',
    'Hoạt động',
    'Bảo trì',
    'Không hoạt động',
  ];

  final List<Map<String, dynamic>> _vehicles = [
    {
      'id': 'V001',
      'type': 'Sedan',
      'model': 'Toyota Vios',
      'licensePlate': '51A-12345',
      'driver': 'Trần Văn B',
      'driverId': 'D001',
      'color': 'Trắng',
      'year': 2020,
      'status': 'Hoạt động',
      'lastMaintenance': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': 'V002',
      'type': 'Sedan',
      'model': 'Honda City',
      'licensePlate': '51A-23456',
      'driver': 'Phạm Văn D',
      'driverId': 'D002',
      'color': 'Đen',
      'year': 2021,
      'status': 'Hoạt động',
      'lastMaintenance': DateTime.now().subtract(const Duration(days: 15)),
    },
    {
      'id': 'V003',
      'type': 'Sedan',
      'model': 'Hyundai Accent',
      'licensePlate': '51A-34567',
      'driver': 'Đỗ Văn G',
      'driverId': 'D003',
      'color': 'Xanh',
      'year': 2019,
      'status': 'Bảo trì',
      'lastMaintenance': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': 'V004',
      'type': 'Hatchback',
      'model': 'Kia Morning',
      'licensePlate': '51A-45678',
      'driver': 'Vũ Thị H',
      'driverId': 'D004',
      'color': 'Đỏ',
      'year': 2018,
      'status': 'Không hoạt động',
      'lastMaintenance': DateTime.now().subtract(const Duration(days: 60)),
    },
    {
      'id': 'V005',
      'type': 'SUV',
      'model': 'Ford Everest',
      'licensePlate': '51A-56789',
      'driver': null,
      'driverId': null,
      'color': 'Bạc',
      'year': 2022,
      'status': 'Hoạt động',
      'lastMaintenance': DateTime.now().subtract(const Duration(days: 10)),
    },
  ];

  List<Map<String, dynamic>> _getFilteredVehicles() {
    List<Map<String, dynamic>> filtered = _vehicles;

    if (_selectedFilter != 'Tất cả') {
      filtered =
          filtered
              .where((vehicle) => vehicle['status'] == _selectedFilter)
              .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((vehicle) {
            final model = vehicle['model'].toLowerCase();
            final licensePlate = vehicle['licensePlate'].toLowerCase();
            final driver =
                vehicle['driver'] != null
                    ? vehicle['driver'].toLowerCase()
                    : '';
            final id = vehicle['id'].toLowerCase();
            final type = vehicle['type'].toLowerCase();

            return model.contains(_searchQuery.toLowerCase()) ||
                licensePlate.contains(_searchQuery.toLowerCase()) ||
                driver.contains(_searchQuery.toLowerCase()) ||
                id.contains(_searchQuery.toLowerCase()) ||
                type.contains(_searchQuery.toLowerCase());
          }).toList();
    }

    return filtered;
  }

  void _showVehicleDetails(Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Chi tiết xe ${vehicle['licensePlate']}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('ID:', vehicle['id']),
                  _buildDetailRow('Loại xe:', vehicle['type']),
                  _buildDetailRow('Mẫu xe:', vehicle['model']),
                  _buildDetailRow('Biển số:', vehicle['licensePlate']),
                  _buildDetailRow('Màu sắc:', vehicle['color']),
                  _buildDetailRow('Năm sản xuất:', vehicle['year'].toString()),
                  _buildDetailRow(
                    'Tài xế:',
                    vehicle['driver'] ?? 'Chưa phân công',
                  ),
                  _buildDetailRow('Trạng thái:', vehicle['status']),
                  _buildDetailRow(
                    'Bảo trì gần nhất:',
                    '${vehicle['lastMaintenance'].day}/${vehicle['lastMaintenance'].month}/${vehicle['lastMaintenance'].year}',
                  ),
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
                  _showEditVehicleDialog(vehicle);
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
            width: 120,
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

  void _showEditVehicleDialog(Map<String, dynamic> vehicle) {
    final modelController = TextEditingController(text: vehicle['model']);
    final licensePlateController = TextEditingController(
      text: vehicle['licensePlate'],
    );
    final colorController = TextEditingController(text: vehicle['color']);
    final yearController = TextEditingController(
      text: vehicle['year'].toString(),
    );
    final driverController = TextEditingController(
      text: vehicle['driver'] ?? '',
    );
    String status = vehicle['status'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Chỉnh sửa xe ${vehicle['licensePlate']}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: modelController,
                    decoration: const InputDecoration(labelText: 'Mẫu xe'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: licensePlateController,
                    decoration: const InputDecoration(labelText: 'Biển số'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: colorController,
                    decoration: const InputDecoration(labelText: 'Màu sắc'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: yearController,
                    decoration: const InputDecoration(
                      labelText: 'Năm sản xuất',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: driverController,
                    decoration: const InputDecoration(
                      labelText: 'Tài xế',
                      hintText: 'Để trống nếu chưa phân công',
                    ),
                  ),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                        ),
                        items:
                            _filterOptions.map((option) {
                              return DropdownMenuItem(
                                value:
                                    option == 'Tất cả' ? 'Hoạt động' : option,
                                child: Text(
                                  option == 'Tất cả' ? 'Hoạt động' : option,
                                ),
                              );
                            }).toList(),
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
                  // In a real app, we would update the vehicle data
                  setState(() {
                    vehicle['model'] = modelController.text;
                    vehicle['licensePlate'] = licensePlateController.text;
                    vehicle['color'] = colorController.text;
                    vehicle['year'] =
                        int.tryParse(yearController.text) ?? vehicle['year'];
                    vehicle['driver'] =
                        driverController.text.isEmpty
                            ? null
                            : driverController.text;
                    vehicle['status'] = status;
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cập nhật thông tin xe thành công'),
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

  void _showAddVehicleDialog() {
    final typeController = TextEditingController();
    final modelController = TextEditingController();
    final licensePlateController = TextEditingController();
    final colorController = TextEditingController();
    final yearController = TextEditingController();
    final driverController = TextEditingController();
    String status = 'Hoạt động';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thêm xe mới'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: typeController,
                    decoration: const InputDecoration(
                      labelText: 'Loại xe',
                      hintText: 'Sedan, SUV, Hatchback...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: modelController,
                    decoration: const InputDecoration(labelText: 'Mẫu xe'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: licensePlateController,
                    decoration: const InputDecoration(labelText: 'Biển số'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: colorController,
                    decoration: const InputDecoration(labelText: 'Màu sắc'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: yearController,
                    decoration: const InputDecoration(
                      labelText: 'Năm sản xuất',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: driverController,
                    decoration: const InputDecoration(
                      labelText: 'Tài xế',
                      hintText: 'Để trống nếu chưa phân công',
                    ),
                  ),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                        ),
                        items:
                            _filterOptions
                                .where((option) => option != 'Tất cả')
                                .map((option) {
                                  return DropdownMenuItem(
                                    value: option,
                                    child: Text(option),
                                  );
                                })
                                .toList(),
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
                  // In a real app, we would add the vehicle to the database
                  final newId = 'V${_vehicles.length + 1}'.padLeft(4, '0');

                  final newVehicle = {
                    'id': newId,
                    'type': typeController.text,
                    'model': modelController.text,
                    'licensePlate': licensePlateController.text,
                    'driver':
                        driverController.text.isEmpty
                            ? null
                            : driverController.text,
                    'driverId': null,
                    'color': colorController.text,
                    'year':
                        int.tryParse(yearController.text) ??
                        DateTime.now().year,
                    'status': status,
                    'lastMaintenance': DateTime.now(),
                  };

                  setState(() {
                    _vehicles.add(newVehicle);
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thêm xe mới thành công'),
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

  void _showDeleteConfirmDialog(Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa xe ${vehicle['licensePlate']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  // In a real app, we would delete the vehicle from the database
                  setState(() {
                    _vehicles.removeWhere((v) => v['id'] == vehicle['id']);
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Xóa xe thành công'),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Hoạt động':
        return AppColors.success;
      case 'Bảo trì':
        return Colors.orange;
      case 'Không hoạt động':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý xe')),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm xe...',
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
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _filterOptions.map((option) {
                            final isSelected = _selectedFilter == option;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(option),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = option;
                                  });
                                },
                                backgroundColor: Colors.grey[200],
                                selectedColor: AppColors.primary.withOpacity(
                                  0.2,
                                ),
                                checkmarkColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildVehicleList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVehicleDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVehicleList() {
    final filteredVehicles = _getFilteredVehicles();

    return filteredVehicles.isEmpty
        ? const Center(child: Text('Không tìm thấy xe nào'))
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredVehicles.length,
          itemBuilder: (context, index) {
            final vehicle = filteredVehicles[index];
            return _buildVehicleCard(vehicle);
          },
        );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showVehicleDetails(vehicle),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle['model'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          vehicle['licensePlate'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        vehicle['status'],
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      vehicle['status'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(vehicle['status']),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Loại xe',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          vehicle['type'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Màu sắc',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          vehicle['color'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Năm sản xuất',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          vehicle['year'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tài xế',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          vehicle['driver'] ?? 'Chưa phân công',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color:
                                vehicle['driver'] == null ? Colors.grey : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary),
                        onPressed: () => _showEditVehicleDialog(vehicle),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => _showDeleteConfirmDialog(vehicle),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
