/// Configuration Supabase
/// 
/// IMPORTANT: Remplacez ces valeurs par vos propres credentials Supabase
/// Obtenez-les depuis: https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api

class SupabaseConfig {
  // URL de votre projet Supabase
  static const String url = 'https://YOUR_PROJECT_ID.supabase.co';
  
  // Clé publique (anon key) - safe to use in client
  static const String anonKey = 'YOUR_ANON_KEY';
  
  // Clé service role (UNIQUEMENT pour les Edge Functions côté serveur)
  // NE PAS utiliser dans l'app Flutter
  static const String serviceRoleKey = 'YOUR_SERVICE_ROLE_KEY';
  
  // Configuration Storage
  static const String storageBucket = 'acbc-files';
  
  // Configuration Edge Functions
  static const String functionsUrl = '$url/functions/v1';
  
  // Endpoints Edge Functions
  static const String calculateMarginEndpoint = '$functionsUrl/calculate-margin';
  static const String smartMatchingEndpoint = '$functionsUrl/smart-matching';
  static const String sendWhatsappEndpoint = '$functionsUrl/send-whatsapp';
  static const String generateReportEndpoint = '$functionsUrl/generate-report';
}
