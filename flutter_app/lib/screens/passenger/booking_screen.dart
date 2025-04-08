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
  final _searchController = TextEditingController();

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

  // Sample search locations
  final List<String> _recentLocations = [
    '65 Võ Văn Tần, Quận 3, TP.HCM',
    'Đại học Khoa học Tự nhiên, Quận 5, TP.HCM',
    'Chợ Bến Thành, Quận 1, TP.HCM',
  ];

  final List<String> _suggestedLocations = [
    'Nhà hát Thành phố, Quận 1, TP.HCM',
    'Công viên 23/9, Quận 1, TP.HCM',
    'Landmark 81, Quận Bình Thạnh, TP.HCM',
    'AEON Mall Tân Phú, Quận Tân Phú, TP.HCM',
    'Crescent Mall, Quận 7, TP.HCM',
  ];

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
    _searchController.dispose();
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDestinationSearchSheet(),
    );
  }

  Widget _buildDestinationSearchSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn điểm đến',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm địa điểm...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    autofocus: true,
                    onChanged: (value) {
                      // In a real app, you would filter locations based on search
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_recentLocations.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Gần đây',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    ...List.generate(
                      _recentLocations.length,
                      (index) => _buildSearchResultItem(
                        _recentLocations[index],
                        Icons.history,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _destinationController.text =
                                _recentLocations[index];
                            _showVehicleSelection = true;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(thickness: 1, height: 32),
                    ),
                  ],
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Đề xuất',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  ...List.generate(
                    _suggestedLocations.length,
                    (index) => _buildSearchResultItem(
                      _suggestedLocations[index],
                      Icons.location_on,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _destinationController.text =
                              _suggestedLocations[index];
                          _showVehicleSelection = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(
    String address,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
      title: Text(
        address,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      onTap:
          onTap ??
          () {
            Navigator.pop(context);
            setState(() {
              _destinationController.text = address;
              _showVehicleSelection = true;
            });
          },
    );
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
      backgroundColor: Colors.grey[50],
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
          _buildLocationInput(
            controller: _pickupController,
            icon: Icons.circle,
            iconColor: AppColors.primary,
            hintText: 'Điểm đón',
            isPickup: true,
            onTap: () {
              // Just display the current location since this is for demonstration
            },
          ),

          // Connector line
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Container(
                  width: 2,
                  height: 30,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              ],
            ),
          ),

          // Destination location
          _buildLocationInput(
            controller: _destinationController,
            icon: Icons.location_on,
            iconColor: AppColors.error,
            hintText: 'Nhập điểm đến',
            isPickup: false,
            onTap: _searchDestination,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInput({
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String hintText,
    required bool isPickup,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 10, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child:
                  isPickup
                      ? Text(
                        controller.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                      : TextField(
                        controller: controller,
                        readOnly: true,
                        onTap: onTap,
                        decoration: InputDecoration(
                          hintText: hintText,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
            ),
            if (isPickup)
              IconButton(
                icon: Icon(
                  Icons.my_location,
                  color: AppColors.primary,
                  size: 18,
                ),
                onPressed: () {
                  // Use current location
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Stack(
      children: [
        // Map placeholder
        Container(
          color: Colors.grey[200],
          child: Center(
            child: Icon(Icons.map, size: 100, color: Colors.grey[400]),
          ),
        ),

        // Overlay with message
        Center(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Bạn muốn đi đâu?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Nhập điểm đến để tìm xe',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _searchDestination,
                  child: Text('Chọn điểm đến'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleSelection() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        final vehicles = bookingProvider.availableVehicles;

        if (vehicles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.no_crash,
                    size: 40,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Không tìm thấy xe',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Không có xe nào trong khu vực của bạn',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.primary.withOpacity(0.2)
                                : AppColors.background.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          _getVehicleIcon(vehicle.type),
                          size: 36,
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
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
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '15 phút',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.route,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '5.2 km',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
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
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
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
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.payment_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phương thức thanh toán',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Tiền mặt',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Change payment method
                    },
                    child: Text(
                      'Thay đổi',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
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
