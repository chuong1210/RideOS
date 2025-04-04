import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app/utils/app_theme.dart';
import 'package:flutter_app/providers/booking_provider.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/widgets/loading_overlay.dart';

class ActiveBookingScreen extends StatefulWidget {
  const ActiveBookingScreen({Key? key}) : super(key: key);

  @override
  State<ActiveBookingScreen> createState() => _ActiveBookingScreenState();
}

class _ActiveBookingScreenState extends State<ActiveBookingScreen> {
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

    // Add driver marker if available
    final driverMarker =
        booking.vehicle != null
            ? Marker(
              markerId: const MarkerId('driver'),
              position: LatLng(booking.vehicle!.lat, booking.vehicle!.lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
              infoWindow: InfoWindow(
                title: 'Tài xế',
                snippet: booking.vehicle!.driverName,
              ),
            )
            : null;

    setState(() {
      _markers = {
        pickupMarker,
        destinationMarker,
        if (driverMarker != null) driverMarker,
      };

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
    LatLngBounds bounds;
    if (driverMarker != null) {
      bounds = LatLngBounds(
        southwest: _getMinLatLng([
          pickupMarker.position,
          destinationMarker.position,
          driverMarker.position,
        ]),
        northeast: _getMaxLatLng([
          pickupMarker.position,
          destinationMarker.position,
          driverMarker.position,
        ]),
      );
    } else {
      bounds = LatLngBounds(
        southwest: _getMinLatLng([
          pickupMarker.position,
          destinationMarker.position,
        ]),
        northeast: _getMaxLatLng([
          pickupMarker.position,
          destinationMarker.position,
        ]),
      );
    }

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

  Future<void> _cancelBooking() async {
    final booking =
        Provider.of<BookingProvider>(context, listen: false).currentBooking;
    if (booking == null) return;

    setState(() => _isLoading = true);

    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    final success = await bookingProvider.cancelBooking(booking.id);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hủy chuyến thất bại. Vui lòng thử lại sau.'),
          backgroundColor: AppColors.error,
        ),
      );
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
                          if (booking.vehicle != null)
                            Text(
                              '${booking.vehicle!.model ?? "Xe 4 chỗ"} • ${booking.vehicle!.licensePlate}',
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

                // Driver info
                if (booking.vehicle != null &&
                    booking.vehicle!.driverName != null)
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
                            booking.vehicle!.driverName!
                                .substring(0, 1)
                                .toUpperCase(),
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
                                booking.vehicle!.driverName!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (booking.vehicle!.driverRating != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      booking.vehicle!.driverRating!.toString(),
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Call driver
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
                            // Message driver
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
                if (booking.bookingStatus == BookingStatus.pending)
                  CustomButton(
                    text: 'Hủy chuyến',
                    onPressed: _cancelBooking,
                    backgroundColor: AppColors.error,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Đang tìm tài xế...';
      case BookingStatus.accepted:
        return 'Tài xế đang đến đón bạn';
      case BookingStatus.arrived:
        return 'Tài xế đã đến điểm đón';
      case BookingStatus.inProgress:
        return 'Đang trong chuyến đi';
      case BookingStatus.completed:
        return 'Chuyến đi đã hoàn thành';
      case BookingStatus.cancelled:
        return 'Chuyến đi đã hủy';
    }
  }
}
