class AppConstants {
  static const String appName = 'Premade';
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Paginated queries
  static const int pageSize = 10;

  // Games
  static const List<String> supportedGames = ['League of Legends', 'Valorant'];

  // Validation
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int minPasswordLength = 6;
  static const int minBioLength = 10;
  static const int maxBioLength = 500;
}
