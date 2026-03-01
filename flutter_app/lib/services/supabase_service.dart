import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

/// Provider pour le client Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Service Supabase principal
class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  // ============================================================
  // AUTHENTIFICATION
  // ============================================================

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ============================================================
  // MEMBRES
  // ============================================================

  Future<Map<String, dynamic>?> getMembre(String userId) async {
    final response = await _client
        .from('membres_club')
        .select('*, pays_africains(*)')
        .eq('user_id', userId)
        .single();
    return response;
  }

  Future<Map<String, dynamic>> createMembre(Map<String, dynamic> data) async {
    final response = await _client
        .from('membres_club')
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateMembre(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from('membres_club')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> getMembreDashboardStats(String membreId) async {
    final response = await _client
        .rpc('get_membre_dashboard_stats', params: {'p_membre_id': membreId});
    return response as Map<String, dynamic>;
  }

  // ============================================================
  // PRODUITS AFRIQUE
  // ============================================================

  Future<List<Map<String, dynamic>>> getProduitsAfrique({
    String? paysId,
    String? categorieId,
    int limit = 50,
    int offset = 0,
  }) async {
    var query = _client
        .from('produits_afrique')
        .select('*, pays_africains(*), categories_produits(*)');

    if (paysId != null) {
      query = query.eq('pays_id', paysId);
    }
    if (categorieId != null) {
      query = query.eq('categorie_id', categorieId);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getProduitAfrique(String id) async {
    final response = await _client
        .from('produits_afrique')
        .select('*, pays_africains(*), categories_produits(*)')
        .eq('id', id)
        .single();
    return response;
  }

  // ============================================================
  // FOURNISSEURS
  // ============================================================

  Future<List<Map<String, dynamic>>> getFournisseurs({
    bool? verifie,
    int limit = 50,
    int offset = 0,
  }) async {
    var query = _client
        .from('fournisseurs_chine')
        .select('*')
        .eq('actif', true);

    if (verifie != null) {
      query = query.eq('verifie', verifie);
    }

    final response = await query
        .order('score_fiabilite', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getFournisseur(String id) async {
    final response = await _client
        .from('fournisseurs_chine')
        .select('*, produits_fournisseurs(*, categories_produits(*))')
        .eq('id', id)
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> getProduitsFournisseur(String fournisseurId) async {
    final response = await _client
        .from('produits_fournisseurs')
        .select('*, categories_produits(*)')
        .eq('fournisseur_id', fournisseurId)
        .eq('actif', true);
    return List<Map<String, dynamic>>.from(response);
  }

  // ============================================================
  // MATCHING
  // ============================================================

  Future<List<Map<String, dynamic>>> getMatchesMembre(String membreId) async {
    final response = await _client
        .from('scores_matching')
        .select('*, fournisseurs_chine(*), produits_fournisseurs(*)')
        .eq('membre_id', membreId)
        .order('score_compatibilite', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateMatchStatut(String matchId, String statut) async {
    await _client
        .from('scores_matching')
        .update({'statut': statut})
        .eq('id', matchId);
  }

  // ============================================================
  // ANALYSES DE MARGE
  // ============================================================

  Future<List<Map<String, dynamic>>> getAnalysesMembre({int limit = 50}) async {
    final response = await _client
        .from('analyses_marges')
        .select('*, produits_afrique(*), produits_fournisseurs(*, fournisseurs_chine(*))')
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  // ============================================================
  // MISES EN RELATION
  // ============================================================

  Future<Map<String, dynamic>> createMiseEnRelation(Map<String, dynamic> data) async {
    final response = await _client
        .from('mises_en_relation')
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> getMisesEnRelationMembre(String membreId) async {
    final response = await _client
        .from('mises_en_relation')
        .select('*, scores_matching(*), fournisseurs_chine(*)')
        .eq('membre_id', membreId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Future<List<Map<String, dynamic>>> getNotifications({bool? nonLues}) async {
    var query = _client
        .from('notifications')
        .select('*')
        .eq('user_id', currentUser!.id);

    if (nonLues == true) {
      query = query.eq('lu', false);
    }

    final response = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> markNotificationAsRead(String id) async {
    await _client
        .from('notifications')
        .update({'lu': true})
        .eq('id', id);
  }

  Future<int> getUnreadNotificationCount() async {
    final response = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', currentUser!.id)
        .eq('lu', false);
    return (response as List).length;
  }

  // ============================================================
  // DONNÉES DE RÉFÉRENCE
  // ============================================================

  Future<List<Map<String, dynamic>>> getPaysAfricains() async {
    final response = await _client
        .from('pays_africains')
        .select('*')
        .order('nom');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _client
        .from('categories_produits')
        .select('*')
        .order('nom');
    return List<Map<String, dynamic>>.from(response);
  }

  // ============================================================
  // EDGE FUNCTIONS
  // ============================================================

  Future<Map<String, dynamic>> calculateMargin({
    required String produitAfriqueId,
    required String produitFournisseurId,
    int quantite = 1,
    double? coutTransport,
    double? coutLogistique,
  }) async {
    final response = await _client.functions.invoke(
      'calculate-margin',
      body: {
        'produit_afrique_id': produitAfriqueId,
        'produit_fournisseur_id': produitFournisseurId,
        'quantite': quantite,
        'cout_transport': coutTransport ?? 0,
        'cout_logistique': coutLogistique ?? 0,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> runSmartMatching({
    required String membreId,
    int limit = 20,
    double seuilMinimum = 0.5,
  }) async {
    final response = await _client.functions.invoke(
      'smart-matching',
      body: {
        'membre_id': membreId,
        'limit': limit,
        'seuil_minimum': seuilMinimum,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> generateWeeklyReport(String membreId) async {
    final response = await _client.functions.invoke(
      'generate-report',
      body: {'membre_id': membreId},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendWhatsAppNotification({
    String? notificationId,
    String? membreId,
    required String type,
    String? message,
  }) async {
    final response = await _client.functions.invoke(
      'send-whatsapp',
      body: {
        'notification_id': notificationId,
        'membre_id': membreId,
        'type': type,
        'message': message,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}

/// Provider pour le service Supabase
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseService(client);
});
