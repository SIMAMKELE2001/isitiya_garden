/// Mirrors the `user_role` type in the database.
enum UserRole {
  farmer,
  buyer;

  static UserRole fromDb(String value) =>
      value == 'farmer' ? UserRole.farmer : UserRole.buyer;
}

/// One row of the `profiles` table.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.role,
    required this.fullName,
    required this.phone,
    this.communityId,
  });

  final String id;
  final UserRole role;
  final String fullName;
  final String phone;
  final int? communityId;

  /// "Nomsa Mbatha" becomes "Nomsa".
  String get firstName => fullName.trim().split(' ').first;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    role: UserRole.fromDb(json['role'] as String),
    fullName: json['full_name'] as String,
    phone: json['phone'] as String,
    communityId: json['community_id'] as int?,
  );
}

/// The buyer-only details: which buyer type they chose (FR18).
class BuyerDetails {
  const BuyerDetails({this.buyerTypeId, this.buyerTypeName});

  final int? buyerTypeId;
  final String? buyerTypeName;

  factory BuyerDetails.fromJson(Map<String, dynamic> json) {
    final type = json['buyer_types'] as Map<String, dynamic>?;
    return BuyerDetails(
      buyerTypeId: json['buyer_type_id'] as int?,
      buyerTypeName: type?['name'] as String?,
    );
  }
}

/// One row of a lookup table (communities, buyer_types): an id and a name.
class LookupItem {
  const LookupItem({required this.id, required this.name});

  final int id;
  final String name;

  factory LookupItem.fromJson(Map<String, dynamic> json) =>
      LookupItem(id: json['id'] as int, name: json['name'] as String);
}
