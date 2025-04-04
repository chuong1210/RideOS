class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  
  ApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });
  
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }
}

