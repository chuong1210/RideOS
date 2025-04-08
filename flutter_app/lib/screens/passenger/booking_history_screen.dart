import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/utils/app_theme.dart';
import 'package:flutter_app/providers/booking_provider.dart';
import 'package:flutter_app/models/booking_model.dart';
import 'package:flutter_app/screens/passenger/booking_details_screen.dart';
import 'package:flutter_app/widgets/loading_overlay.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
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
    await bookingProvider.fetchBookingHistory();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử chuyến đi'), elevation: 0),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: LoadingOverlay(
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
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,

        // isScrollable: true, // <--- ADD THIS LINE
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 16),
                SizedBox(width: 6),
                Text('Tất cả'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 9),
                SizedBox(width: 6),
                Text('Hoàn thành'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel, size: 13),
                SizedBox(width: 6),
                Text('Đã hủy'),
              ],
            ),
          ),
        ],
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
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
          return _buildEmptyState(filterStatus);
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

  Widget _buildEmptyState(BookingStatus? status) {
    String message;
    IconData icon;

    if (status == BookingStatus.completed) {
      message = 'Chưa có chuyến đi nào hoàn thành';
      icon = Icons.check_circle_outline;
    } else if (status == BookingStatus.cancelled) {
      message = 'Chưa có chuyến đi nào bị hủy';
      icon = Icons.cancel_outlined;
    } else {
      message = 'Chưa có lịch sử chuyến đi';
      icon = Icons.history;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 60, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          if (status == null)
            ElevatedButton.icon(
              onPressed: () {
                // Navigator.of(context).pop();
              },
              icon: Icon(Icons.directions_car),
              label: Text('Đặt xe ngay'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(BookingModel booking) {
    final dateFormat = DateFormat('dd/MM/yyyy, HH:mm');
    final formattedDate = dateFormat.format(booking.createdAt);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BookingDetailsScreen(bookingId: booking.id),
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
            _buildBookingHeader(booking, formattedDate),
            _buildBookingBody(booking),
            _buildBookingFooter(booking),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingHeader(BookingModel booking, String formattedDate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getStatusColor(booking.bookingStatus).withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getStatusColor(booking.bookingStatus).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(booking.bookingStatus),
              color: _getStatusColor(booking.bookingStatus),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getStatusText(booking.bookingStatus),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(booking.bookingStatus),
                  fontSize: 16,
                ),
              ),
              Text(
                formattedDate,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          Spacer(),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingBody(BookingModel booking) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: AppColors.primary.withOpacity(0.5),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Điểm đón',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.pickup.address,
                      style: TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Điểm đến',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.destination.address,
                      style: TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingFooter(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Icon(Icons.route, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${booking.distance.toStringAsFixed(1)} km',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${(booking.distance * 3).toInt()} phút',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${booking.price.toStringAsFixed(0)}đ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
        ],
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
        return Icons.location_on;
      case BookingStatus.inProgress:
        return Icons.navigation;
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
