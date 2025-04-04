import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app/utils/app_theme.dart';
import 'package:flutter_app/providers/booking_provider.dart';
import 'package:flutter_app/models/vehicle_model.dart';
import 'package:flutter_app/screens/passenger/active_booking_screen.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/widgets/loading_overlay.dart';

class BookingScreen extends StatefulWidget {
  final LatLng currentPosition;

  const BookingScreen({Key? key, required this.currentPosition})
    : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();

  bool _isLoading = false;
  bool _showVehicleSelection = false;
  VehicleModel? _selectedVehicle;

  // Simulated data
  final _pickupLocation = LocationPoint(
    lat: 10.762622,
    lng: 106.660172,
    address: '227 Nguyễn Văn Cừ, Quận 5, TP.HCM',
  );

  final _destinationLocation = LocationPoint(
    lat: 10.773831,
    lng: 106.704287,
    address: '65 Võ Văn Tần, Quận 3, TP.HCM',
  );

  @override
  void initState() {
    super.initState();
    _pickupController.text = _pickupLocation.address;
    _loadAvailableVehicles();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableVehicles() async {
    setState(() => _isLoading = true);

    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    await bookingProvider.fetchAvailableVehicles(
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
    );

    setState(() => _isLoading = false);
  }

  void _searchDestination() {
    // Simulate destination search
    setState(() {
      _destinationController.text = _destinationLocation.address;
      _showVehicleSelection = true;
    });
  }

  Future<void> _createBooking() async {
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn loại xe'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    final success = await bookingProvider.createBooking({
      'vehicleId': _selectedVehicle!.id,
      'pickup': {
        'lat': _pickupLocation.lat,
        'lng': _pickupLocation.lng,
        'address': _pickupLocation.address,
      },
      'destination': {
        'lat': _destinationLocation.lat,
        'lng': _destinationLocation.lng,
        'address': _destinationLocation.address,
      },
      'distance': 5.2, // Simulated distance in km
      'price': _selectedVehicle!.pricePerKm * 5.2, // Simulated price
      'paymentMethod': 'cash',
    });

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ActiveBookingScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt xe thất bại. Vui lòng thử lại sau.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Đặt xe',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            _buildLocationInputs(),
            Expanded(
              child:
                  _showVehicleSelection
                      ? _buildVehicleSelection()
                      : _buildEmptyState(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _showVehicleSelection ? _buildBottomBar() : null,
    );
  }

  Widget _buildLocationInputs() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Pickup location
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, size: 12, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _pickupController,
                    decoration: InputDecoration(
                      hintText: 'Điểm đón',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    readOnly: true,
                  ),
                ),
              ],
            ),
          ),

          // Connector line
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: [
                Container(width: 2, height: 30, color: AppColors.primary),
              ],
            ),
          ),

          // Destination location
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      hintText: 'Điểm đến',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onTap: _searchDestination,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nhập điểm đến để bắt đầu',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSelection() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        final vehicles = bookingProvider.availableVehicles;

        if (vehicles.isEmpty) {
          return Center(
            child: Text(
              'Không tìm thấy xe trong khu vực của bạn',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            final isSelected = _selectedVehicle?.id == vehicle.id;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedVehicle = vehicle;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          _getVehicleIcon(vehicle.type),
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getVehicleTypeName(vehicle.type),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '5.2 km • 15 phút',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(vehicle.pricePerKm * 5.2).toStringAsFixed(0)}đ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${vehicle.pricePerKm.toStringAsFixed(0)}đ/km',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.payment_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Tiền mặt', style: TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Change payment method
                  },
                  child: Text(
                    'Thay đổi',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(text: 'Đặt xe', onPressed: _createBooking),
          ],
        ),
      ),
    );
  }

  IconData _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bike':
        return Icons.motorcycle;
      case 'car':
        return Icons.directions_car;
      case 'premium':
        return Icons.directions_car;
      default:
        return Icons.directions_car;
    }
  }

  String _getVehicleTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'bike':
        return 'Xe máy';
      case 'car':
        return 'Xe 4 chỗ';
      case 'premium':
        return 'Xe cao cấp';
      default:
        return 'Xe 4 chỗ';
    }
  }
}

class LocationPoint {
  final double lat;
  final double lng;
  final String address;

  LocationPoint({required this.lat, required this.lng, required this.address});
}
