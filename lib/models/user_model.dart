class UserModel {
  final String id;
  final String name;
  final String mobileNumber;
  final String? photoUrl;
  final String farmName;
  final String village;
  final String district;
  final String state;
  final String preferredLanguage;

  const UserModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    this.photoUrl,
    required this.farmName,
    required this.village,
    required this.district,
    required this.state,
    this.preferredLanguage = 'en',
  });
}
