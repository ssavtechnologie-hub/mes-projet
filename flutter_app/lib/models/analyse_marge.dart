import 'package:equatable/equatable.dart';

/// Modèle Analyse de Marge
class AnalyseMarge extends Equatable {
  final String id;
  final String produitAfriqueId;
  final String produitFournisseurId;
  final double prixAchat;
  final double coutTransport;
  final double coutDouane;
  final double coutLogistique;
  final double autresFrais;
  final double prixRevientTotal;
  final double prixVenteEstime;
  final double margeBrute;
  final double margeBrutePourcentage;
  final double margeNette;
  final double margeNettePourcentage;
  final double roiEstime;
  final int volumeRecommande;
  final String risqueNiveau;
  final String? recommandation;
  final Map<String, dynamic>? detailsCalcul;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations
  final String? produitAfriqueNom;
  final double? produitAfriquePrix;
  final String? produitFournisseurNom;
  final double? produitFournisseurPrix;
  final String? fournisseurNom;

  const AnalyseMarge({
    required this.id,
    required this.produitAfriqueId,
    required this.produitFournisseurId,
    required this.prixAchat,
    this.coutTransport = 0,
    this.coutDouane = 0,
    this.coutLogistique = 0,
    this.autresFrais = 0,
    required this.prixRevientTotal,
    required this.prixVenteEstime,
    required this.margeBrute,
    required this.margeBrutePourcentage,
    required this.margeNette,
    required this.margeNettePourcentage,
    required this.roiEstime,
    this.volumeRecommande = 1,
    required this.risqueNiveau,
    this.recommandation,
    this.detailsCalcul,
    required this.createdAt,
    required this.updatedAt,
    this.produitAfriqueNom,
    this.produitAfriquePrix,
    this.produitFournisseurNom,
    this.produitFournisseurPrix,
    this.fournisseurNom,
  });

  factory AnalyseMarge.fromJson(Map<String, dynamic> json) {
    return AnalyseMarge(
      id: json['id'] as String,
      produitAfriqueId: json['produit_afrique_id'] as String,
      produitFournisseurId: json['produit_fournisseur_id'] as String,
      prixAchat: (json['prix_achat'] as num).toDouble(),
      coutTransport: (json['cout_transport'] as num?)?.toDouble() ?? 0,
      coutDouane: (json['cout_douane'] as num?)?.toDouble() ?? 0,
      coutLogistique: (json['cout_logistique'] as num?)?.toDouble() ?? 0,
      autresFrais: (json['autres_frais'] as num?)?.toDouble() ?? 0,
      prixRevientTotal: (json['prix_revient_total'] as num).toDouble(),
      prixVenteEstime: (json['prix_vente_estime'] as num).toDouble(),
      margeBrute: (json['marge_brute'] as num).toDouble(),
      margeBrutePourcentage: (json['marge_brute_pourcentage'] as num).toDouble(),
      margeNette: (json['marge_nette'] as num).toDouble(),
      margeNettePourcentage: (json['marge_nette_pourcentage'] as num).toDouble(),
      roiEstime: (json['roi_estime'] as num).toDouble(),
      volumeRecommande: json['volume_recommande'] as int? ?? 1,
      risqueNiveau: json['risque_niveau'] as String,
      recommandation: json['recommandation'] as String?,
      detailsCalcul: json['details_calcul'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      produitAfriqueNom: json['produits_afrique']?['nom'] as String?,
      produitAfriquePrix: (json['produits_afrique']?['prix_moyen'] as num?)?.toDouble(),
      produitFournisseurNom: json['produits_fournisseurs']?['nom'] as String?,
      produitFournisseurPrix: (json['produits_fournisseurs']?['prix_usine'] as num?)?.toDouble(),
      fournisseurNom: json['produits_fournisseurs']?['fournisseurs_chine']?['nom'] as String?,
    );
  }

  /// Factory pour créer depuis la réponse de l'Edge Function
  factory AnalyseMarge.fromEdgeFunctionResponse(Map<String, dynamic> json) {
    return AnalyseMarge(
      id: '', // Sera assigné par Supabase
      produitAfriqueId: json['produit_afrique_id'] ?? '',
      produitFournisseurId: json['produit_fournisseur_id'] ?? '',
      prixAchat: (json['prix_achat'] as num).toDouble(),
      coutTransport: (json['cout_transport'] as num?)?.toDouble() ?? 0,
      coutDouane: (json['cout_douane'] as num?)?.toDouble() ?? 0,
      coutLogistique: (json['cout_logistique'] as num?)?.toDouble() ?? 0,
      autresFrais: 0,
      prixRevientTotal: (json['prix_revient_total'] as num).toDouble(),
      prixVenteEstime: (json['prix_vente_estime'] as num).toDouble(),
      margeBrute: (json['marge_brute'] as num).toDouble(),
      margeBrutePourcentage: (json['marge_brute_pourcentage'] as num).toDouble(),
      margeNette: (json['marge_nette'] as num).toDouble(),
      margeNettePourcentage: 0, // Calculé côté serveur
      roiEstime: (json['roi_estime'] as num).toDouble(),
      volumeRecommande: json['volume_recommande'] as int? ?? 1,
      risqueNiveau: json['risque_niveau'] as String,
      recommandation: json['recommandation'] as String?,
      detailsCalcul: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String get risqueLabel {
    switch (risqueNiveau) {
      case 'faible':
        return 'Faible';
      case 'moyen':
        return 'Moyen';
      case 'eleve':
        return 'Élevé';
      default:
        return risqueNiveau;
    }
  }

  bool get isRentable => margeBrutePourcentage >= 15;
  bool get isHighlyRentable => margeBrutePourcentage >= 25;

  @override
  List<Object?> get props => [
        id,
        produitAfriqueId,
        produitFournisseurId,
        prixAchat,
        coutTransport,
        coutDouane,
        coutLogistique,
        autresFrais,
        prixRevientTotal,
        prixVenteEstime,
        margeBrute,
        margeBrutePourcentage,
        margeNette,
        margeNettePourcentage,
        roiEstime,
        volumeRecommande,
        risqueNiveau,
        recommandation,
        detailsCalcul,
        createdAt,
        updatedAt,
      ];
}
