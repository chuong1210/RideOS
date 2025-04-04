import 'package:flutter_app/models/user_model.dart';
import 'package:flutter_app/models/vehicle_model.dart';
import 'package:flutter_app/providers/booking_provider.dart';

class LocationPoint {
  final double lat;
  final double lng;
  final String address;

  LocationPoint({required this.lat, required this.lng, required this.address});

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      lat: json['lat'].toDouble(),
      lng: json['lng'].toDouble(),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng, 'address': address};
  }
}

class BookingModel {
  final String id;
  final String userId;
  final String? vehicleId;
  final LocationPoint pickup;
  final LocationPoint destination;
  final double distance;
  final double price;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final UserModel? user;
  final VehicleModel? vehicle;
  final String? paymentMethod;
  final bool isPaid;

  BookingModel({
    required this.id,
    required this.userId,
    this.vehicleId,
    required this.pickup,
    required this.destination,
    required this.distance,
    required this.price,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.user,
    this.vehicle,
    this.paymentMethod,
    required this.isPaid,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      userId: json['userId'],
      vehicleId: json['vehicleId'],
      pickup: LocationPoint.fromJson(json['pickup']),
      destination: LocationPoint.fromJson(json['destination']),
      distance: json['distance'].toDouble(),
      price: json['price'].toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      vehicle:
          json['vehicle'] != null
              ? VehicleModel.fromJson(json['vehicle'])
              : null,
      paymentMethod: json['paymentMethod'],
      isPaid: json['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'pickup': pickup.toJson(),
      'destination': destination.toJson(),
      'distance': distance,
      'price': price,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'user': user?.toJson(),
      'vehicle': vehicle?.toJson(),
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
    };
  }

  BookingStatus get bookingStatus {
    switch (status) {
      case 'pending':
        return BookingStatus.pending;
      case 'accepted':
        return BookingStatus.accepted;
      case 'arrived':
        return BookingStatus.arrived;
      case 'inProgress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}
