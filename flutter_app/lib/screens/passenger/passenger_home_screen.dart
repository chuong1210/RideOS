import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_app/utils/app_theme.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/booking_provider.dart';
import 'package:flutter_app/screens/passenger/booking_screen.dart';
import 'package:flutter_app/screens/passenger/passenger_profile_screen.dart';
import 'package:flutter_app/screens/passenger/booking_history_screen.dart';
import 'package:flutter_app/screens/passenger/active_booking_screen.dart';
import 'package:flutter_app/widgets/loading_overlay.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({Key? key}) : super(key: key);

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final Location _location = Location();
  late GoogleMapController _mapController;

  int _currentIndex = 0;
  bool _isLoading = true;
  bool _hasActiveBooking = false;

  LatLng _currentPosition = const LatLng(
    10.762622,
    106.660172,
  ); // Default to Ho Chi Minh City
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _checkActiveBooking();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() => _isLoading = false);
        return;
      }
    }

    final locationData = await _location.getLocation();
    setState(() {
      _currentPosition = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
      _markers = {
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: _currentPosition,
          infoWindow: const InfoWindow(title: 'Vị trí hiện tại'),
        ),
      };
      _isLoading = false;
    });

    _location.onLocationChanged.listen((LocationData locationData) {
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
          _updateMarkers();
        });
      }
    });
  }

  void _updateMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: _currentPosition,
        infoWindow: const InfoWindow(title: 'Vị trí hiện tại'),
      ),
    };
  }

  Future<void> _checkActiveBooking() async {
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    await bookingProvider.fetchCurrentBooking();

    if (mounted) {
      setState(() {
        _hasActiveBooking = bookingProvider.currentBooking != null;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _navigateToBookingScreen() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => BookingScreen(currentPosition: _currentPosition),
          ),
        )
        .then((_) => _checkActiveBooking());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildMapScreen(),
            const BookingHistoryScreen(),
            const PassengerProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }

  Widget _buildMapScreen() {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _currentPosition,
            zoom: 15,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          markers: _markers,
          zoomControlsEnabled: false,
        ),

        // App bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.5), Colors.transparent],
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào,',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return Text(
                            authProvider.currentUser?.name ?? 'Người dùng',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Notification screen
                  },
                  icon: Icon(Icons.notifications_outlined, color: Colors.white),
                ),
              ],
            ),
          ),
        ),

        // Bottom card
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child:
                _hasActiveBooking
                    ? _buildActiveBookingCard()
                    : _buildBookingCard(),
          ),
        ),

        // My location button
        Positioned(
          right: 16,
          bottom: _hasActiveBooking ? 200 : 160,
          child: FloatingActionButton(
            onPressed: () {
              _mapController.animateCamera(
                CameraUpdate.newLatLng(_currentPosition),
              );
            },
            backgroundColor: Colors.white,
            mini: true,
            child: Icon(Icons.my_location, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Bạn muốn đi đâu?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _navigateToBookingScreen,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Nhập điểm đến...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickDestinationButton(
                icon: Icons.home_outlined,
                label: 'Nhà',
                onTap: _navigateToBookingScreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickDestinationButton(
                icon: Icons.work_outline,
                label: 'Công ty',
                onTap: _navigateToBookingScreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickDestinationButton(
                icon: Icons.star_outline,
                label: 'Yêu thích',
                onTap: _navigateToBookingScreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickDestinationButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBookingCard() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        final booking = bookingProvider.currentBooking;
        if (booking == null) return const SizedBox();

        return InkWell(
          onTap: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (_) => const ActiveBookingScreen(),
                  ),
                )
                .then((_) => _checkActiveBooking());
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
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
                            'Chuyến đi đang hoạt động',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            _getStatusText(booking.bookingStatus),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
