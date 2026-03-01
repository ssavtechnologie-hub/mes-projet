import 'package:equatable/equatable.dart';

/// Modèle Fournisseur Chinois
class FournisseurChine extends Equatable {
  final String id;
  final String nom;
  final String? nomEntreprise;
  final String? email;
  final String? telephone;
  final String? adresse;
  final String? ville;
  final String? province;
  final String? siteWeb;
  final int anneesExperience;
  final List<String> certifications;
  final double scoreFiabilite;
  final int nombreTransactions;
  final double tauxSatisfaction;
  final bool verifie;
  final bool actif;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProduitFournisseur>? produits;

  const FournisseurChine({
    required this.id,
    required this.nom,
    this.nomEntreprise,
    this.email,
    this.telephone,
    this.adresse,
    this.ville,
    this.province,
    this.siteWeb,
    this.anneesExperience = 0,
    this.certifications = const [],
    this.scoreFiabilite = 0,
    this.nombreTransactions = 0,
    this.tauxSatisfaction = 0,
    this.verifie = false,
    this.actif = true,
    required this.createdAt,
    required this.updatedAt,
    this.produits,
  });

  factory FournisseurChine.fromJson(Map<String, dynamic> json) {
    return FournisseurChine(
      id: json['id'] as String,
      nom: json['nom'] as String,
      nomEntreprise: json['nom_entreprise'] as String?,
      email: json['email'] as String?,
      telephone: json['telephone'] as String?,
      adresse: json['adresse'] as String?,
      ville: json['ville'] as String?,
      province: json['province'] as String?,
      siteWeb: json['site_web'] as String?,
      anneesExperience: json['annees_experience'] as int? ?? 0,
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      scoreFiabilite: (json['score_fiabilite'] as num?)?.toDouble() ?? 0,
      nombreTransactions: json['nombre_transactions'] as int? ?? 0,
      tauxSatisfaction: (json['taux_satisfaction'] as num?)?.toDouble() ?? 0,
      verifie: json['verifie'] as bool? ?? false,
      actif: json['actif'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      produits: json['produits_fournisseurs'] != null
          ? (json['produits_fournisseurs'] as List<dynamic>)
              .map((e) => ProduitFournisseur.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  String get fiabiliteLabel {
    if (scoreFiabilite >= 0.9) return 'Excellent';
    if (scoreFiabilite >= 0.8) return 'Très bon';
    if (scoreFiabilite >= 0.7) return 'Bon';
    if (scoreFiabilite >= 0.5) return 'Moyen';
    return 'À vérifier';
  }

  @override
  List<Object?> get props => [
        id,
        nom,
        nomEntreprise,
        email,
        telephone,
        adresse,
        ville,
        province,
        siteWeb,
        anneesExperience,
        certifications,
        scoreFiabilite,
        nombreTransactions,
        tauxSatisfaction,
        verifie,
        actif,
        createdAt,
        updatedAt,
        produits,
      ];
}

/// Modèle Produit Fournisseur
class ProduitFournisseur extends Equatable {
  final String id;
  final String fournisseurId;
  final String? categorieId;
  final String? categorieNom;
  final String nom;
  final String? description;
  final double prixUsine;
  final String devise;
  final int moq;
  final int? delaiProduction;
  final int? delaiLivraison;
  final double? poidsUnitaire;
  final String? dimensions;
  final List<String> images;
  final Map<String, dynamic>? specifications;
  final bool actif;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProduitFournisseur({
    required this.id,
    required this.fournisseurId,
    this.categorieId,
    this.categorieNom,
    required this.nom,
    this.description,
    required this.prixUsine,
    this.devise = 'USD',
    this.moq = 1,
    this.delaiProduction,
    this.delaiLivraison,
    this.poidsUnitaire,
    this.dimensions,
    this.images = const [],
    this.specifications,
    this.actif = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProduitFournisseur.fromJson(Map<String, dynamic> json) {
    return ProduitFournisseur(
      id: json['id'] as String,
      fournisseurId: json['fournisseur_id'] as String,
      categorieId: json['categorie_id'] as String?,
      categorieNom: json['categories_produits']?['nom'] as String?,
      nom: json['nom'] as String,
      description: json['description'] as String?,
      prixUsine: (json['prix_usine'] as num).toDouble(),
      devise: json['devise'] as String? ?? 'USD',
      moq: json['moq'] as int? ?? 1,
      delaiProduction: json['delai_production'] as int?,
      delaiLivraison: json['delai_livraison'] as int?,
      poidsUnitaire: (json['poids_unitaire'] as num?)?.toDouble(),
      dimensions: json['dimensions'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      specifications: json['specifications'] as Map<String, dynamic>?,
      actif: json['actif'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  int get delaiTotalEstime => (delaiProduction ?? 7) + (delaiLivraison ?? 30);

  @override
  List<Object?> get props => [
        id,
        fournisseurId,
        categorieId,
        categorieNom,
        nom,
        description,
        prixUsine,
        devise,
        moq,
        delaiProduction,
        delaiLivraison,
        poidsUnitaire,
        dimensions,
        images,
        specifications,
        actif,
        createdAt,
        updatedAt,
      ];
}
