class VehicleModel {
  final String id;
  final String type;
  final String licensePlate;
  final String? driverId;
  final String? driverName;
  final double? driverRating;
  final double pricePerKm;
  final double lat;
  final double lng;
  final String status;
  final String? model;
  final String? color;
  final String? photo;
  
  VehicleModel({
    required this.id,
    required this.type,
    required this.licensePlate,
    this.driverId,
    this.driverName,
    this.driverRating,
    required this.pricePerKm,
    required this.lat,
    required this.lng,
    required this.status,
    this.model,
    this.color,
    this.photo,
  });
  
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      type: json['type'],
      licensePlate: json['licensePlate'],
      driverId: json['driverId'],
      driverName: json['driverName'],
      driverRating: json['driverRating']?.toDouble(),
      pricePerKm: json['pricePerKm'].toDouble(),
      lat: json['lat'].toDouble(),
      lng: json['lng'].toDouble(),
      status: json['status'],
      model: json['model'],
      color: json['color'],
      photo: json['photo'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'licensePlate': licensePlate,
      'driverId': driverId,
      'driverName': driverName,
      'driverRating': driverRating,
      'pricePerKm': pricePerKm,
      'lat': lat,
      'lng': lng,
      'status': status,
      'model': model,
      'color': color,
      'photo': photo,
    };
  }
}

