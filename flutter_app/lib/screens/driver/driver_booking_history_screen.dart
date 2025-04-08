import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/utils/app_theme.dart';
import 'package:flutter_app/providers/booking_provider.dart';
import 'package:flutter_app/models/booking_model.dart';
import 'package:flutter_app/screens/driver/driver_booking_details_screen.dart';
import 'package:flutter_app/widgets/loading_overlay.dart';

class DriverBookingHistoryScreen extends StatefulWidget {
  const DriverBookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<DriverBookingHistoryScreen> createState() =>
      _DriverBookingHistoryScreenState();
}

class _DriverBookingHistoryScreenState extends State<DriverBookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookingHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookingHistory() async {
    setState(() => _isLoading = true);

    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    await bookingProvider.fetchDriverBookings();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử chuyến đi'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Container(
            color: Colors.blue,
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              labelPadding: EdgeInsets.symmetric(horizontal: 10),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Text(
                    'Tất cả',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Hoàn thành',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Đã hủy',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: RefreshIndicator(
          onRefresh: _loadBookingHistory,
          color: AppColors.primary,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(null),
              _buildBookingList(BookingStatus.completed),
              _buildBookingList(BookingStatus.cancelled),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList(BookingStatus? filterStatus) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        final bookings = bookingProvider.bookingHistory;

        // Filter bookings if needed
        final filteredBookings =
            filterStatus != null
                ? bookings
                    .where((booking) => booking.bookingStatus == filterStatus)
                    .toList()
                : bookings;

        if (filteredBookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    filterStatus == BookingStatus.cancelled
                        ? Icons.cancel
                        : Icons.history,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  filterStatus == BookingStatus.cancelled
                      ? 'Chưa có chuyến đi nào bị hủy'
                      : filterStatus == BookingStatus.completed
                      ? 'Chưa có chuyến đi nào hoàn thành'
                      : 'Không có chuyến đi nào',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Các chuyến đi của bạn sẽ hiển thị ở đây',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredBookings.length,
          itemBuilder: (context, index) {
            final booking = filteredBookings[index];
            return _buildBookingItem(booking);
          },
        );
      },
    );
  }

  Widget _buildBookingItem(BookingModel booking) {
    final dateFormat = DateFormat('dd/MM/yyyy, HH:mm');
    final formattedDate = dateFormat.format(booking.createdAt);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DriverBookingDetailsScreen(bookingId: booking.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(booking.bookingStatus).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(booking.bookingStatus),
                    color: _getStatusColor(booking.bookingStatus),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(booking.bookingStatus),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(booking.bookingStatus),
                    ),
                  ),
                  const Spacer(),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: AppColors.primary,
                          ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${booking.distance.toStringAsFixed(1)} km',
                        style: TextStyle(color: AppColors.textSecondary),
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
                ],
              ),
            ),
          ],
        ),
      ),
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
