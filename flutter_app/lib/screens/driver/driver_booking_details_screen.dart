import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app/utils/app_theme.dart';
import 'package:flutter_app/providers/booking_provider.dart';
import 'package:flutter_app/models/booking_model.dart';
import 'package:flutter_app/widgets/loading_overlay.dart';
import 'package:flutter_app/widgets/custom_button.dart';

class DriverBookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const DriverBookingDetailsScreen({Key? key, required this.bookingId})
    : super(key: key);

  @override
  State<DriverBookingDetailsScreen> createState() =>
      _DriverBookingDetailsScreenState();
}

class _DriverBookingDetailsScreenState
    extends State<DriverBookingDetailsScreen> {
  late GoogleMapController _mapController;
  bool _isLoading = true;
  BookingModel? _booking;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    setState(() => _isLoading = true);

    // In a real app, we would fetch the specific booking by ID
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    await bookingProvider.fetchDriverBookings();

    final bookings = bookingProvider.bookingHistory;
    final booking = bookings.firstWhere(
      (b) => b.id == widget.bookingId,
      orElse: () => bookings.first, // Fallback for demo purposes
    );

    setState(() {
      _booking = booking;
      _isLoading = false;
      _updateMapMarkers();
    });
  }

  void _updateMapMarkers() {
    if (_booking == null) return;

    // Add pickup marker
    final pickupMarker = Marker(
      markerId: const MarkerId('pickup'),
      position: LatLng(_booking!.pickup.lat, _booking!.pickup.lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
        title: 'Điểm đón',
        snippet: _booking!.pickup.address,
      ),
    );

    // Add destination marker
    final destinationMarker = Marker(
      markerId: const MarkerId('destination'),
      position: LatLng(_booking!.destination.lat, _booking!.destination.lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
        title: 'Điểm đến',
        snippet: _booking!.destination.address,
      ),
    );

    setState(() {
      _markers = {pickupMarker, destinationMarker};

      // Add route polyline
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(_booking!.pickup.lat, _booking!.pickup.lng),
            LatLng(_booking!.destination.lat, _booking!.destination.lng),
          ],
          color: AppColors.primary,
          width: 5,
        ),
      };
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMapMarkers();

    if (_booking != null) {
      // Move camera to show all markers
      final bounds = LatLngBounds(
        southwest: _getMinLatLng([
          LatLng(_booking!.pickup.lat, _booking!.pickup.lng),
          LatLng(_booking!.destination.lat, _booking!.destination.lng),
        ]),
        northeast: _getMaxLatLng([
          LatLng(_booking!.pickup.lat, _booking!.pickup.lng),
          LatLng(_booking!.destination.lat, _booking!.destination.lng),
        ]),
      );

      _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }

  LatLng _getMinLatLng(List<LatLng> points) {
    double minLat = points
        .map((p) => p.latitude)
        .reduce((a, b) => a < b ? a : b);
    double minLng = points
        .map((p) => p.longitude)
        .reduce((a, b) => a < b ? a : b);
    return LatLng(minLat, minLng);
  }

  LatLng _getMaxLatLng(List<LatLng> points) {
    double maxLat = points
        .map((p) => p.latitude)
        .reduce((a, b) => a > b ? a : b);
    double maxLng = points
        .map((p) => p.longitude)
        .reduce((a, b) => a > b ? a : b);
    return LatLng(maxLat, maxLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết chuyến đi')),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child:
            _booking == null
                ? const Center(
                  child: Text('Không tìm thấy thông tin chuyến đi'),
                )
                : Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            _booking!.pickup.lat,
                            _booking!.pickup.lng,
                          ),
                          zoom: 15,
                        ),
                        markers: _markers,
                        polylines: _polylines,
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatusCard(),
                            const SizedBox(height: 16),
                            _buildRouteInfo(),
                            const SizedBox(height: 16),
                            _buildPassengerInfo(),
                            const SizedBox(height: 16),
                            _buildPaymentInfo(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final dateFormat = DateFormat('dd/MM/yyyy, HH:mm');
    final formattedDate = dateFormat.format(_booking!.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(_booking!.bookingStatus).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(_booking!.bookingStatus),
            color: _getStatusColor(_booking!.bookingStatus),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(_booking!.bookingStatus),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _getStatusColor(_booking!.bookingStatus),
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_booking!.price.toStringAsFixed(0)}đ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết hành trình',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      _booking!.pickup.address,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _booking!.destination.address,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                icon: Icons.route,
                label: 'Khoảng cách',
                value: '${_booking!.distance.toStringAsFixed(1)} km',
              ),
              _buildInfoItem(
                icon: Icons.access_time,
                label: 'Thời gian',
                value: '15 phút', // Simulated
              ),
              _buildInfoItem(
                icon: Icons.attach_money,
                label: 'Giá/km',
                value:
                    '${(_booking!.price / _booking!.distance).toStringAsFixed(0)}đ',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerInfo() {
    if (_booking!.user == null) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin hành khách',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                child: Text(
                  _booking!.user!.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _booking!.user!.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _booking!.user!.phone,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Call passenger
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.phone, color: Colors.white, size: 20),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Message passenger
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.message, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin thanh toán',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Phương thức thanh toán'),
              Row(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _booking!.paymentMethod == 'cash'
                        ? 'Tiền mặt'
                        : 'Ví điện tử',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trạng thái'),
              Text(
                _booking!.isPaid ? 'Đã thanh toán' : 'Chưa thanh toán',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _booking!.isPaid ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '${_booking!.price.toStringAsFixed(0)}đ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.blue;
      case BookingStatus.accepted:
        return AppColors.primary;
      case BookingStatus.arrived:
        return AppColors.primary;
      case BookingStatus.inProgress:
        return AppColors.primary;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.access_time;
      case BookingStatus.accepted:
        return Icons.directions_car;
      case BookingStatus.arrived:
        return Icons.directions_car;
      case BookingStatus.inProgress:
        return Icons.directions_car;
      case BookingStatus.completed:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Đang chờ';
      case BookingStatus.accepted:
        return 'Đã nhận';
      case BookingStatus.arrived:
        return 'Đã đến điểm đón';
      case BookingStatus.inProgress:
        return 'Đang di chuyển';
      case BookingStatus.completed:
        return 'Hoàn thành';
      case BookingStatus.cancelled:
        return 'Đã hủy';
    }
  }
}
