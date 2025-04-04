import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/utils/app_theme.dart';
import 'package:flutter_app/providers/booking_provider.dart';
import 'package:flutter_app/widgets/loading_overlay.dart';

class AdminBookingManagementScreen extends StatefulWidget {
  const AdminBookingManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminBookingManagementScreen> createState() =>
      _AdminBookingManagementScreenState();
}

class _AdminBookingManagementScreenState
    extends State<AdminBookingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedFilter = 'Tất cả';

  final List<String> _filterOptions = [
    'Tất cả',
    'Đang chờ',
    'Đã nhận',
    'Đang di chuyển',
    'Hoàn thành',
    'Đã hủy',
  ];

  final List<Map<String, dynamic>> _bookings = [
    {
      'id': 'B001',
      'passenger': {'name': 'Nguyễn Văn A', 'phone': '0901234567'},
      'driver': {
        'name': 'Trần Văn B',
        'phone': '0901234568',
        'vehicle': 'Toyota Vios - 51A-12345',
      },
      'pickup': 'Quận 1, TP.HCM',
      'destination': 'Quận 7, TP.HCM',
      'distance': 8.5,
      'price': 120000,
      'status': 'Hoàn thành',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'paymentMethod': 'Tiền mặt',
      'isPaid': true,
    },
    {
      'id': 'B002',
      'passenger': {'name': 'Lê Thị C', 'phone': '0901234569'},
      'driver': {
        'name': 'Phạm Văn D',
        'phone': '0901234570',
        'vehicle': 'Honda City - 51A-23456',
      },
      'pickup': 'Quận 3, TP.HCM',
      'destination': 'Quận 10, TP.HCM',
      'distance': 5.2,
      'price': 75000,
      'status': 'Đang di chuyển',
      'date': DateTime.now().subtract(const Duration(minutes: 30)),
      'paymentMethod': 'Ví điện tử',
      'isPaid': false,
    },
    {
      'id': 'B003',
      'passenger': {'name': 'Hoàng Văn E', 'phone': '0901234571'},
      'driver': null,
      'pickup': 'Quận 5, TP.HCM',
      'destination': 'Quận 8, TP.HCM',
      'distance': 6.8,
      'price': 95000,
      'status': 'Đang chờ',
      'date': DateTime.now().subtract(const Duration(minutes: 5)),
      'paymentMethod': 'Tiền mặt',
      'isPaid': false,
    },
    {
      'id': 'B004',
      'passenger': {'name': 'Đỗ Văn G', 'phone': '0901234572'},
      'driver': {
        'name': 'Vũ Thị H',
        'phone': '0901234573',
        'vehicle': 'Kia Morning - 51A-45678',
      },
      'pickup': 'Quận 2, TP.HCM',
      'destination': 'Quận 9, TP.HCM',
      'distance': 12.3,
      'price': 180000,
      'status': 'Đã hủy',
      'date': DateTime.now().subtract(const Duration(hours: 1)),
      'paymentMethod': 'Tiền mặt',
      'isPaid': false,
    },
    {
      'id': 'B005',
      'passenger': {'name': 'Ngô Thị I', 'phone': '0901234574'},
      'driver': {
        'name': 'Lý Văn J',
        'phone': '0901234575',
        'vehicle': 'Hyundai Accent - 51A-56789',
      },
      'pickup': 'Quận 4, TP.HCM',
      'destination': 'Quận 6, TP.HCM',
      'distance': 7.5,
      'price': 105000,
      'status': 'Đã nhận',
      'date': DateTime.now().subtract(const Duration(minutes: 15)),
      'paymentMethod': 'Ví điện tử',
      'isPaid': true,
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

  List<Map<String, dynamic>> _getFilteredBookings() {
    List<Map<String, dynamic>> filtered = _bookings;

    if (_selectedFilter != 'Tất cả') {
      filtered =
          filtered
              .where((booking) => booking['status'] == _selectedFilter)
              .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((booking) {
            final passenger = booking['passenger']['name'].toLowerCase();
            final driver =
                booking['driver'] != null
                    ? booking['driver']['name'].toLowerCase()
                    : '';
            final id = booking['id'].toLowerCase();
            final pickup = booking['pickup'].toLowerCase();
            final destination = booking['destination'].toLowerCase();

            return passenger.contains(_searchQuery.toLowerCase()) ||
                driver.contains(_searchQuery.toLowerCase()) ||
                id.contains(_searchQuery.toLowerCase()) ||
                pickup.contains(_searchQuery.toLowerCase()) ||
                destination.contains(_searchQuery.toLowerCase());
          }).toList();
    }

    return filtered;
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    final dateFormat = DateFormat('dd/MM/yyyy, HH:mm');
    final formattedDate = dateFormat.format(booking['date']);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Chi tiết đơn đặt xe ${booking['id']}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Trạng thái:', booking['status']),
                  _buildDetailRow('Thời gian:', formattedDate),
                  _buildDetailRow('Hành khách:', booking['passenger']['name']),
                  _buildDetailRow(
                    'SĐT hành khách:',
                    booking['passenger']['phone'],
                  ),
                  if (booking['driver'] != null) ...[
                    _buildDetailRow('Tài xế:', booking['driver']['name']),
                    _buildDetailRow('SĐT tài xế:', booking['driver']['phone']),
                    _buildDetailRow('Xe:', booking['driver']['vehicle']),
                  ],
                  _buildDetailRow('Điểm đón:', booking['pickup']),
                  _buildDetailRow('Điểm đến:', booking['destination']),
                  _buildDetailRow('Khoảng cách:', '${booking['distance']} km'),
                  _buildDetailRow(
                    'Giá tiền:',
                    '${NumberFormat.decimalPattern().format(booking['price'])}đ',
                  ),
                  _buildDetailRow(
                    'Phương thức thanh toán:',
                    booking['paymentMethod'],
                  ),
                  _buildDetailRow(
                    'Trạng thái thanh toán:',
                    booking['isPaid'] ? 'Đã thanh toán' : 'Chưa thanh toán',
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
                  _showEditBookingDialog(booking);
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
            width: 150,
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

  void _showEditBookingDialog(Map<String, dynamic> booking) {
    String status = booking['status'];
    bool isPaid = booking['isPaid'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Chỉnh sửa đơn đặt xe ${booking['id']}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                                value: option,
                                child: Text(option),
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
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return SwitchListTile(
                        title: const Text('Đã thanh toán'),
                        value: isPaid,
                        onChanged: (value) {
                          setState(() {
                            isPaid = value;
                          });
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
                  // In a real app, we would update the booking data
                  setState(() {
                    booking['status'] = status;
                    booking['isPaid'] = isPaid;
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cập nhật đơn đặt xe thành công'),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đang chờ':
        return Colors.blue;
      case 'Đã nhận':
        return AppColors.primary;
      case 'Đang di chuyển':
        return AppColors.primary;
      case 'Hoàn thành':
        return AppColors.success;
      case 'Đã hủy':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý đơn đặt xe')),
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
                      hintText: 'Tìm kiếm đơn đặt xe...',
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
            Expanded(child: _buildBookingList()),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList() {
    final filteredBookings = _getFilteredBookings();

    return filteredBookings.isEmpty
        ? const Center(child: Text('Không tìm thấy đơn đặt xe nào'))
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredBookings.length,
          itemBuilder: (context, index) {
            final booking = filteredBookings[index];
            return _buildBookingCard(booking);
          },
        );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final dateFormat = DateFormat('dd/MM/yyyy, HH:mm');
    final formattedDate = dateFormat.format(booking['date']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
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
                      Icons.receipt,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              booking['id'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  booking['status'],
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                booking['status'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(booking['status']),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${NumberFormat.decimalPattern().format(booking['price'])}đ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Column(
                    children: [
                      Icon(Icons.circle, size: 12, color: AppColors.primary),
                      Container(width: 2, height: 30, color: AppColors.primary),
                      Icon(Icons.location_on, size: 12, color: AppColors.error),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking['pickup'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          booking['destination'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            booking['passenger']['name']
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hành khách',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                booking['passenger']['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (booking['driver'] != null)
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              booking['driver']['name']
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
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
                                  booking['driver']['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
