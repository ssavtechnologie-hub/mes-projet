import 'package:equatable/equatable.dart';

/// Modèle Membre du Club (Importateur)
class MembreClub extends Equatable {
  final String id;
  final String? userId;
  final String nomComplet;
  final String email;
  final String? telephone;
  final String? whatsapp;
  final String? paysId;
  final String? paysNom;
  final String? ville;
  final String? nomEntreprise;
  final String? typeEntreprise;
  final String? numeroRegistre;
  final double? budgetMensuel;
  final double? budgetMin;
  final double? budgetMax;
  final String deviseBudget;
  final List<String> categoriesInteret;
  final String experienceImport;
  final int? volumeMensuelEstime;
  final int nombreImportsRealises;
  final double scoreActivite;
  final String niveauAbonnement;
  final DateTime? dateAbonnement;
  final bool verifie;
  final bool actif;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MembreClub({
    required this.id,
    this.userId,
    required this.nomComplet,
    required this.email,
    this.telephone,
    this.whatsapp,
    this.paysId,
    this.paysNom,
    this.ville,
    this.nomEntreprise,
    this.typeEntreprise,
    this.numeroRegistre,
    this.budgetMensuel,
    this.budgetMin,
    this.budgetMax,
    this.deviseBudget = 'USD',
    this.categoriesInteret = const [],
    this.experienceImport = 'debutant',
    this.volumeMensuelEstime,
    this.nombreImportsRealises = 0,
    this.scoreActivite = 0,
    this.niveauAbonnement = 'gratuit',
    this.dateAbonnement,
    this.verifie = false,
    this.actif = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MembreClub.fromJson(Map<String, dynamic> json) {
    return MembreClub(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      nomComplet: json['nom_complet'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      paysId: json['pays_id'] as String?,
      paysNom: json['pays_africains']?['nom'] as String?,
      ville: json['ville'] as String?,
      nomEntreprise: json['nom_entreprise'] as String?,
      typeEntreprise: json['type_entreprise'] as String?,
      numeroRegistre: json['numero_registre'] as String?,
      budgetMensuel: (json['budget_mensuel'] as num?)?.toDouble(),
      budgetMin: (json['budget_min'] as num?)?.toDouble(),
      budgetMax: (json['budget_max'] as num?)?.toDouble(),
      deviseBudget: json['devise_budget'] as String? ?? 'USD',
      categoriesInteret: (json['categories_interet'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      experienceImport: json['experience_import'] as String? ?? 'debutant',
      volumeMensuelEstime: json['volume_mensuel_estime'] as int?,
      nombreImportsRealises: json['nombre_imports_realises'] as int? ?? 0,
      scoreActivite: (json['score_activite'] as num?)?.toDouble() ?? 0,
      niveauAbonnement: json['niveau_abonnement'] as String? ?? 'gratuit',
      dateAbonnement: json['date_abonnement'] != null
          ? DateTime.parse(json['date_abonnement'] as String)
          : null,
      verifie: json['verifie'] as bool? ?? false,
      actif: json['actif'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nom_complet': nomComplet,
      'email': email,
      'telephone': telephone,
      'whatsapp': whatsapp,
      'pays_id': paysId,
      'ville': ville,
      'nom_entreprise': nomEntreprise,
      'type_entreprise': typeEntreprise,
      'numero_registre': numeroRegistre,
      'budget_mensuel': budgetMensuel,
      'budget_min': budgetMin,
      'budget_max': budgetMax,
      'devise_budget': deviseBudget,
      'categories_interet': categoriesInteret,
      'experience_import': experienceImport,
      'volume_mensuel_estime': volumeMensuelEstime,
      'nombre_imports_realises': nombreImportsRealises,
      'score_activite': scoreActivite,
      'niveau_abonnement': niveauAbonnement,
      'date_abonnement': dateAbonnement?.toIso8601String(),
      'verifie': verifie,
      'actif': actif,
    };
  }

  MembreClub copyWith({
    String? id,
    String? userId,
    String? nomComplet,
    String? email,
    String? telephone,
    String? whatsapp,
    String? paysId,
    String? paysNom,
    String? ville,
    String? nomEntreprise,
    String? typeEntreprise,
    String? numeroRegistre,
    double? budgetMensuel,
    double? budgetMin,
    double? budgetMax,
    String? deviseBudget,
    List<String>? categoriesInteret,
    String? experienceImport,
    int? volumeMensuelEstime,
    int? nombreImportsRealises,
    double? scoreActivite,
    String? niveauAbonnement,
    DateTime? dateAbonnement,
    bool? verifie,
    bool? actif,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MembreClub(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nomComplet: nomComplet ?? this.nomComplet,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      whatsapp: whatsapp ?? this.whatsapp,
      paysId: paysId ?? this.paysId,
      paysNom: paysNom ?? this.paysNom,
      ville: ville ?? this.ville,
      nomEntreprise: nomEntreprise ?? this.nomEntreprise,
      typeEntreprise: typeEntreprise ?? this.typeEntreprise,
      numeroRegistre: numeroRegistre ?? this.numeroRegistre,
      budgetMensuel: budgetMensuel ?? this.budgetMensuel,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      deviseBudget: deviseBudget ?? this.deviseBudget,
      categoriesInteret: categoriesInteret ?? this.categoriesInteret,
      experienceImport: experienceImport ?? this.experienceImport,
      volumeMensuelEstime: volumeMensuelEstime ?? this.volumeMensuelEstime,
      nombreImportsRealises: nombreImportsRealises ?? this.nombreImportsRealises,
      scoreActivite: scoreActivite ?? this.scoreActivite,
      niveauAbonnement: niveauAbonnement ?? this.niveauAbonnement,
      dateAbonnement: dateAbonnement ?? this.dateAbonnement,
      verifie: verifie ?? this.verifie,
      actif: actif ?? this.actif,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPremium => niveauAbonnement == 'premium' || niveauAbonnement == 'enterprise';

  String get experienceLabel {
    switch (experienceImport) {
      case 'expert':
        return 'Expert';
      case 'intermediaire':
        return 'Intermédiaire';
      case 'debutant':
      default:
        return 'Débutant';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        nomComplet,
        email,
        telephone,
        whatsapp,
        paysId,
        paysNom,
        ville,
        nomEntreprise,
        typeEntreprise,
        numeroRegistre,
        budgetMensuel,
        budgetMin,
        budgetMax,
        deviseBudget,
        categoriesInteret,
        experienceImport,
        volumeMensuelEstime,
        nombreImportsRealises,
        scoreActivite,
        niveauAbonnement,
        dateAbonnement,
        verifie,
        actif,
        createdAt,
        updatedAt,
      ];
}
