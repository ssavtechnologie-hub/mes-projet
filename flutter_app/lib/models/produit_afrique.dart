import 'package:equatable/equatable.dart';

/// Modèle Produit Afrique (Marché local)
class ProduitAfrique extends Equatable {
  final String id;
  final String nom;
  final String? description;
  final double prixMoyen;
  final double? prixMin;
  final double? prixMax;
  final String devise;
  final String? paysId;
  final String? paysNom;
  final String? categorieId;
  final String? categorieNom;
  final String? sourceDonnee;
  final String? engagementMarche;
  final int? volumeEstime;
  final DateTime derniereMiseAJour;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProduitAfrique({
    required this.id,
    required this.nom,
    this.description,
    required this.prixMoyen,
    this.prixMin,
    this.prixMax,
    this.devise = 'USD',
    this.paysId,
    this.paysNom,
    this.categorieId,
    this.categorieNom,
    this.sourceDonnee,
    this.engagementMarche,
    this.volumeEstime,
    required this.derniereMiseAJour,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProduitAfrique.fromJson(Map<String, dynamic> json) {
    return ProduitAfrique(
      id: json['id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String?,
      prixMoyen: (json['prix_moyen'] as num).toDouble(),
      prixMin: (json['prix_min'] as num?)?.toDouble(),
      prixMax: (json['prix_max'] as num?)?.toDouble(),
      devise: json['devise'] as String? ?? 'USD',
      paysId: json['pays_id'] as String?,
      paysNom: json['pays_africains']?['nom'] as String?,
      categorieId: json['categorie_id'] as String?,
      categorieNom: json['categories_produits']?['nom'] as String?,
      sourceDonnee: json['source_donnee'] as String?,
      engagementMarche: json['engagement_marche'] as String?,
      volumeEstime: json['volume_estime'] as int?,
      derniereMiseAJour: DateTime.parse(json['derniere_mise_a_jour'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  String get engagementLabel {
    switch (engagementMarche) {
      case 'fort':
        return 'Fort';
      case 'moyen':
        return 'Moyen';
      case 'faible':
      default:
        return 'Faible';
    }
  }

  String get prixRange {
    if (prixMin != null && prixMax != null) {
      return '\$${prixMin!.toStringAsFixed(2)} - \$${prixMax!.toStringAsFixed(2)}';
    }
    return '\$${prixMoyen.toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [
        id,
        nom,
        description,
        prixMoyen,
        prixMin,
        prixMax,
        devise,
        paysId,
        paysNom,
        categorieId,
        categorieNom,
        sourceDonnee,
        engagementMarche,
        volumeEstime,
        derniereMiseAJour,
        createdAt,
        updatedAt,
      ];
}
