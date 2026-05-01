class Customer {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String nationalID;
  final String status;
  final String? createdat; // 👈 جديد

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.nationalID,
    required this.status,
    this.createdat, // optional
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['customerID'] ?? 0,
      firstName: json['fname'] ?? '',
      lastName: json['lname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      nationalID: json['nationalID']?.toString() ?? '',
      status: json['status'] ?? 'ACTIVE',

      // 👇 هنا المهم
      createdat: json['created_at'] ?? json['Created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerID': id,
      'fname': firstName,
      'lname': lastName,
      'email': email,
      'phone': phone,
      'nationalID': nationalID,
      'status': status,

      // ❌ غالبًا مش بنبعتها في update
      // 'created_at': createdAt,
    };
  }
}