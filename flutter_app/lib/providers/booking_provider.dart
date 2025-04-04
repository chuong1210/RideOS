import 'package:flutter/material.dart';
import 'package:flutter_app/models/booking_model.dart';
import 'package:flutter_app/models/vehicle_model.dart';
import 'package:flutter_app/services/api_service.dart';

enum BookingStatus {
  pending,
  accepted,
  arrived,
  inProgress,
  completed,
  cancelled,
}

class BookingProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<BookingModel> _bookingHistory = [];
  List<VehicleModel> _availableVehicles = [];
  BookingModel? _currentBooking;
  bool _isLoading = false;

  List<BookingModel> get bookingHistory => _bookingHistory;
  List<VehicleModel> get availableVehicles => _availableVehicles;
  BookingModel? get currentBooking => _currentBooking;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchAvailableVehicles(double lat, double lng) async {
    setLoading(true);
    try {
      final response = await _apiService.get(
        'vehicles/available?lat=$lat&lng=$lng',
      );

      if (response.success) {
        _availableVehicles =
            (response.data as List)
                .map((item) => VehicleModel.fromJson(item))
                .toList();
      }
    } catch (e) {
      // Handle error
    } finally {
      setLoading(false);
    }
  }

  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    setLoading(true);
    try {
      final response = await _apiService.post('bookings', bookingData);

      if (response.success) {
        _currentBooking = BookingModel.fromJson(response.data);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    setLoading(true);
    try {
      final response = await _apiService.put('bookings/$bookingId/cancel', {});

      if (response.success) {
        if (_currentBooking?.id == bookingId) {
          _currentBooking = null;
        }
        await fetchBookingHistory();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchBookingHistory() async {
    setLoading(true);
    try {
      final response = await _apiService.get('bookings/history');

      if (response.success) {
        _bookingHistory =
            (response.data as List)
                .map((item) => BookingModel.fromJson(item))
                .toList();
      }
    } catch (e) {
      // Handle error
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchCurrentBooking() async {
    setLoading(true);
    try {
      final response = await _apiService.get('bookings/current');

      if (response.success && response.data != null) {
        _currentBooking = BookingModel.fromJson(response.data);
      } else {
        _currentBooking = null;
      }
    } catch (e) {
      _currentBooking = null;
    } finally {
      setLoading(false);
    }
  }

  // Driver methods
  Future<bool> acceptBooking(String bookingId) async {
    setLoading(true);
    try {
      final response = await _apiService.put('bookings/$bookingId/accept', {});

      if (response.success) {
        _currentBooking = BookingModel.fromJson(response.data);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    setLoading(true);
    try {
      final response = await _apiService.put('bookings/$bookingId/status', {
        'status': status.toString().split('.').last,
      });

      if (response.success) {
        _currentBooking = BookingModel.fromJson(response.data);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchDriverBookings() async {
    setLoading(true);
    try {
      final response = await _apiService.get('driver/bookings');

      if (response.success) {
        _bookingHistory =
            (response.data as List)
                .map((item) => BookingModel.fromJson(item))
                .toList();
      }
    } catch (e) {
      // Handle error
    } finally {
      setLoading(false);
    }
  }
}
