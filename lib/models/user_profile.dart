/// The person using the app. We never ask for a real name — everyone gets an
/// anonymous "butterfly handle" like "Gentle Firefly 27" so kindness never
/// becomes performative.
class UserProfile {
  const UserProfile({
    required this.handle,
    required this.interests,
    required this.joinedOn,
  });

  final String handle;
  final List<String> interests;
  final DateTime joinedOn;

  Map<String, dynamic> toJson() => {
        'handle': handle,
        'interests': interests,
        'joinedOn': joinedOn.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        handle: json['handle'] as String,
        interests: (json['interests'] as List).cast<String>(),
        joinedOn: DateTime.parse(json['joinedOn'] as String),
      );
}
