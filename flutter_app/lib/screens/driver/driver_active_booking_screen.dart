import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app/utils/app_theme.dart';
import 'package:flutter_app/providers/booking_provider.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/widgets/loading_overlay.dart';

class DriverActiveBookingScreen extends StatefulWidget {
  const DriverActiveBookingScreen({Key? key}) : super(key: key);

  @override
  State<DriverActiveBookingScreen> createState() =>
      _DriverActiveBookingScreenState();
}

class _DriverActiveBookingScreenState extends State<DriverActiveBookingScreen> {
  late GoogleMapController _mapController;
  bool _isLoading = false;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    setState(() => _isLoading = true);

    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    await bookingProvider.fetchCurrentBooking();

    setState(() {
      _isLoading = false;
      _updateMapMarkers();
    });
  }

  void _updateMapMarkers() {
    final booking =
        Provider.of<BookingProvider>(context, listen: false).currentBooking;
    if (booking == null) return;

    // Add pickup marker
    final pickupMarker = Marker(
      markerId: const MarkerId('pickup'),
      position: LatLng(booking.pickup.lat, booking.pickup.lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
        title: 'Điểm đón',
        snippet: booking.pickup.address,
      ),
    );

    // Add destination marker
    final destinationMarker = Marker(
      markerId: const MarkerId('destination'),
      position: LatLng(booking.destination.lat, booking.destination.lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
        title: 'Điểm đến',
        snippet: booking.destination.address,
      ),
    );

    setState(() {
      _markers = {pickupMarker, destinationMarker};

      // Add route polyline
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(booking.pickup.lat, booking.pickup.lng),
            LatLng(booking.destination.lat, booking.destination.lng),
          ],
          color: AppColors.primary,
          width: 5,
        ),
      };
    });

    // Move camera to show all markers
    final bounds = LatLngBounds(
      southwest: _getMinLatLng([
        pickupMarker.position,
        destinationMarker.position,
      ]),
      northeast: _getMaxLatLng([
        pickupMarker.position,
        destinationMarker.position,
      ]),
    );

    _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
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

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMapMarkers();
  }

  Future<void> _updateBookingStatus(BookingStatus status) async {
    final booking =
        Provider.of<BookingProvider>(context, listen: false).currentBooking;
    if (booking == null) return;

    setState(() => _isLoading = true);

    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    final success = await bookingProvider.updateBookingStatus(
      booking.id,
      status,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật trạng thái thất bại. Vui lòng thử lại sau.'),
          backgroundColor: AppColors.error,
        ),
      );
    }

    if (status == BookingStatus.completed) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(
                  10.762622,
                  106.660172,
                ), // Default to Ho Chi Minh City
                zoom: 15,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),

            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            // Bottom card
            Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCard() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        final booking = bookingProvider.currentBooking;
        if (booking == null) {
          return const SizedBox();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStatusText(booking.bookingStatus),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'Khoảng cách: ${booking.distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${booking.price.toStringAsFixed(0)}đ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Route info
                Row(
                  children: [
                    Column(
                      children: [
                        Icon(Icons.circle, size: 12, color: AppColors.primary),
                        Container(
                          width: 2,
                          height: 30,
                          color: AppColors.primary,
                        ),
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppColors.error,
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.pickup.address,
                            style: TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            booking.destination.address,
                            style: TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Passenger info
                if (booking.user != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            booking.user!.name.substring(0, 1).toUpperCase(),
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
                                booking.user!.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                booking.user!.phone,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                            child: Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: 20,
                            ),
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
                            child: Icon(
                              Icons.message,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Action buttons
                _buildActionButton(booking.bookingStatus),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Từ chối',
                onPressed: () => _updateBookingStatus(BookingStatus.cancelled),
                isOutlined: true,
                backgroundColor: AppColors.error,
                textColor: AppColors.error,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: 'Chấp nhận',
                onPressed: () => _updateBookingStatus(BookingStatus.accepted),
                backgroundColor: AppColors.success,
              ),
            ),
          ],
        );
      case BookingStatus.accepted:
        return CustomButton(
          text: 'Đã đến điểm đón',
          onPressed: () => _updateBookingStatus(BookingStatus.arrived),
          backgroundColor: AppColors.primary,
        );
      case BookingStatus.arrived:
        return CustomButton(
          text: 'Bắt đầu chuyến đi',
          onPressed: () => _updateBookingStatus(BookingStatus.inProgress),
          backgroundColor: AppColors.primary,
        );
      case BookingStatus.inProgress:
        return CustomButton(
          text: 'Hoàn thành chuyến đi',
          onPressed: () => _updateBookingStatus(BookingStatus.completed),
          backgroundColor: AppColors.success,
        );
      case BookingStatus.completed:
      case BookingStatus.cancelled:
        return CustomButton(
          text: 'Đóng',
          onPressed: () => Navigator.of(context).pop(),
          backgroundColor: AppColors.primary,
        );
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Yêu cầu chuyến đi mới';
      case BookingStatus.accepted:
        return 'Đang đến đón khách';
      case BookingStatus.arrived:
        return 'Đã đến điểm đón';
      case BookingStatus.inProgress:
        return 'Đang trong chuyến đi';
      case BookingStatus.completed:
        return 'Chuyến đi đã hoàn thành';
      case BookingStatus.cancelled:
        return 'Chuyến đi đã hủy';
    }
  }
}
