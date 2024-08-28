class ProfileInfo {
  final String userId;  // Add this field
  final String name;
  final String studentId;
  final String contactNumber;
  final String email;
  final String address;

  ProfileInfo({
    required this.userId,  // Initialize the userId
    required this.name,
    required this.studentId,
    required this.contactNumber,
    required this.email,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,  // Include userId in the map
      'name': name,
      'studentId': studentId,
      'contactNumber': contactNumber,
      'email': email,
      'address': address,
    };
  }

  // Factory method to create a ProfileInfo object from Firestore snapshot
  factory ProfileInfo.fromDocumentSnapshot(Map<String, dynamic> doc) {
    return ProfileInfo(
      userId: doc['userId'] ?? '',  // Initialize userId from the document
      name: doc['name'] ?? '',
      studentId: doc['studentId'] ?? '',
      contactNumber: doc['contactNumber'] ?? '',
      email: doc['email'] ?? '',
      address: doc['address'] ?? '',
    );
  }
}
