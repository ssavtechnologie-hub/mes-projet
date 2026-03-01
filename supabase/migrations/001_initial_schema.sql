-- ============================================================
-- AFRICAN CHINA BUSINESS CHALLENGE 2026
-- SCHEMA SUPABASE COMPLET
-- ============================================================

-- Extension pour les vecteurs (similarité IA)
CREATE EXTENSION IF NOT EXISTS vector;

-- ============================================================
-- TABLES PRINCIPALES
-- ============================================================

-- Table des pays africains
CREATE TABLE pays_africains (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom VARCHAR(100) NOT NULL UNIQUE,
    code_iso VARCHAR(3) NOT NULL UNIQUE,
    devise VARCHAR(10) DEFAULT 'USD',
    taux_douane_moyen DECIMAL(5,2) DEFAULT 15.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des catégories de produits
CREATE TABLE categories_produits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES categories_produits(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des produits sur les marchés africains
CREATE TABLE produits_afrique (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom VARCHAR(255) NOT NULL,
    description TEXT,
    prix_moyen DECIMAL(12,2) NOT NULL,
    prix_min DECIMAL(12,2),
    prix_max DECIMAL(12,2),
    devise VARCHAR(10) DEFAULT 'USD',
    pays_id UUID REFERENCES pays_africains(id) ON DELETE CASCADE,
    categorie_id UUID REFERENCES categories_produits(id),
    source_donnee VARCHAR(100),
    engagement_marche VARCHAR(50), -- faible, moyen, fort
    volume_estime INTEGER,
    embedding_vector vector(384), -- Pour similarité sémantique
    derniere_mise_a_jour TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des fournisseurs chinois
CREATE TABLE fournisseurs_chine (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom VARCHAR(255) NOT NULL,
    nom_entreprise VARCHAR(255),
    email VARCHAR(255),
    telephone VARCHAR(50),
    adresse TEXT,
    ville VARCHAR(100),
    province VARCHAR(100),
    site_web VARCHAR(255),
    annees_experience INTEGER DEFAULT 0,
    certifications TEXT[],
    score_fiabilite DECIMAL(3,2) DEFAULT 0.00, -- 0 à 1
    nombre_transactions INTEGER DEFAULT 0,
    taux_satisfaction DECIMAL(3,2) DEFAULT 0.00,
    verifie BOOLEAN DEFAULT FALSE,
    actif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des produits fournisseurs (catalogue)
CREATE TABLE produits_fournisseurs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fournisseur_id UUID REFERENCES fournisseurs_chine(id) ON DELETE CASCADE,
    categorie_id UUID REFERENCES categories_produits(id),
    nom VARCHAR(255) NOT NULL,
    description TEXT,
    prix_usine DECIMAL(12,2) NOT NULL,
    devise VARCHAR(10) DEFAULT 'USD',
    moq INTEGER DEFAULT 1, -- Minimum Order Quantity
    delai_production INTEGER, -- en jours
    delai_livraison INTEGER, -- en jours
    poids_unitaire DECIMAL(10,3), -- en kg
    dimensions VARCHAR(100),
    images TEXT[],
    specifications JSONB,
    embedding_vector vector(384),
    actif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des membres du club (importateurs)
CREATE TABLE membres_club (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    nom_complet VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    telephone VARCHAR(50),
    whatsapp VARCHAR(50),
    pays_id UUID REFERENCES pays_africains(id),
    ville VARCHAR(100),
    nom_entreprise VARCHAR(255),
    type_entreprise VARCHAR(100), -- SARL, SA, Individuel, etc.
    numero_registre VARCHAR(100),
    budget_mensuel DECIMAL(15,2),
    budget_min DECIMAL(15,2),
    budget_max DECIMAL(15,2),
    devise_budget VARCHAR(10) DEFAULT 'USD',
    categories_interet UUID[], -- IDs des catégories
    experience_import VARCHAR(50), -- debutant, intermediaire, expert
    volume_mensuel_estime INTEGER,
    nombre_imports_realises INTEGER DEFAULT 0,
    score_activite DECIMAL(3,2) DEFAULT 0.00,
    niveau_abonnement VARCHAR(50) DEFAULT 'gratuit', -- gratuit, premium, enterprise
    date_abonnement TIMESTAMPTZ,
    verifie BOOLEAN DEFAULT FALSE,
    actif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des analyses de marges
CREATE TABLE analyses_marges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    produit_afrique_id UUID REFERENCES produits_afrique(id) ON DELETE CASCADE,
    produit_fournisseur_id UUID REFERENCES produits_fournisseurs(id) ON DELETE CASCADE,
    prix_achat DECIMAL(12,2) NOT NULL,
    cout_transport DECIMAL(12,2) DEFAULT 0,
    cout_douane DECIMAL(12,2) DEFAULT 0,
    cout_logistique DECIMAL(12,2) DEFAULT 0,
    autres_frais DECIMAL(12,2) DEFAULT 0,
    prix_revient_total DECIMAL(12,2),
    prix_vente_estime DECIMAL(12,2),
    marge_brute DECIMAL(12,2),
    marge_brute_pourcentage DECIMAL(5,2),
    marge_nette DECIMAL(12,2),
    marge_nette_pourcentage DECIMAL(5,2),
    roi_estime DECIMAL(5,2),
    volume_recommande INTEGER,
    risque_niveau VARCHAR(20), -- faible, moyen, eleve
    recommandation TEXT,
    details_calcul JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des scores de matching
CREATE TABLE scores_matching (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    membre_id UUID REFERENCES membres_club(id) ON DELETE CASCADE,
    fournisseur_id UUID REFERENCES fournisseurs_chine(id) ON DELETE CASCADE,
    produit_fournisseur_id UUID REFERENCES produits_fournisseurs(id),
    score_compatibilite DECIMAL(3,2) NOT NULL, -- 0 à 1
    score_budget DECIMAL(3,2),
    score_categorie DECIMAL(3,2),
    score_experience DECIMAL(3,2),
    score_localisation DECIMAL(3,2),
    raisons_match TEXT[],
    priorite INTEGER DEFAULT 0,
    statut VARCHAR(50) DEFAULT 'nouveau', -- nouveau, vu, contacte, en_cours, conclu, annule
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(membre_id, fournisseur_id, produit_fournisseur_id)
);

-- Table des mises en relation
CREATE TABLE mises_en_relation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    matching_id UUID REFERENCES scores_matching(id) ON DELETE CASCADE,
    membre_id UUID REFERENCES membres_club(id) ON DELETE CASCADE,
    fournisseur_id UUID REFERENCES fournisseurs_chine(id) ON DELETE CASCADE,
    type_relation VARCHAR(50), -- demande_devis, negociation, commande
    statut VARCHAR(50) DEFAULT 'en_attente', -- en_attente, accepte, refuse, en_cours, conclu, annule
    message_initial TEXT,
    quantite_demandee INTEGER,
    budget_indique DECIMAL(15,2),
    date_contact TIMESTAMPTZ DEFAULT NOW(),
    date_reponse TIMESTAMPTZ,
    notes TEXT,
    commission_prevue DECIMAL(12,2),
    commission_payee DECIMAL(12,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- match, message, alerte, rapport
    titre VARCHAR(255) NOT NULL,
    contenu TEXT,
    data JSONB,
    lu BOOLEAN DEFAULT FALSE,
    envoye_whatsapp BOOLEAN DEFAULT FALSE,
    date_envoi_whatsapp TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des rapports hebdomadaires
CREATE TABLE rapports_hebdomadaires (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    membre_id UUID REFERENCES membres_club(id) ON DELETE CASCADE,
    semaine_debut DATE NOT NULL,
    semaine_fin DATE NOT NULL,
    nombre_nouveaux_produits INTEGER DEFAULT 0,
    nombre_nouveaux_matchs INTEGER DEFAULT 0,
    meilleurs_produits JSONB,
    tendances_marche JSONB,
    recommandations TEXT[],
    envoye BOOLEAN DEFAULT FALSE,
    date_envoi TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des transactions/commandes
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mise_en_relation_id UUID REFERENCES mises_en_relation(id),
    membre_id UUID REFERENCES membres_club(id) ON DELETE CASCADE,
    fournisseur_id UUID REFERENCES fournisseurs_chine(id) ON DELETE CASCADE,
    numero_transaction VARCHAR(50) UNIQUE,
    montant_total DECIMAL(15,2) NOT NULL,
    devise VARCHAR(10) DEFAULT 'USD',
    quantite INTEGER,
    statut VARCHAR(50) DEFAULT 'en_attente', -- en_attente, paye, expedie, livre, annule
    commission_plateforme DECIMAL(12,2),
    taux_commission DECIMAL(5,2),
    date_paiement TIMESTAMPTZ,
    date_expedition TIMESTAMPTZ,
    date_livraison TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table de logs d'activité
CREATE TABLE logs_activite (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id),
    action VARCHAR(100) NOT NULL,
    entite VARCHAR(100),
    entite_id UUID,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des paramètres système
CREATE TABLE parametres_systeme (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cle VARCHAR(100) UNIQUE NOT NULL,
    valeur TEXT,
    type VARCHAR(50), -- string, number, boolean, json
    description TEXT,
    modifiable BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- INDEX POUR PERFORMANCE
-- ============================================================

CREATE INDEX idx_produits_afrique_pays ON produits_afrique(pays_id);
CREATE INDEX idx_produits_afrique_categorie ON produits_afrique(categorie_id);
CREATE INDEX idx_produits_afrique_embedding ON produits_afrique USING ivfflat (embedding_vector vector_cosine_ops);

CREATE INDEX idx_produits_fournisseurs_fournisseur ON produits_fournisseurs(fournisseur_id);
CREATE INDEX idx_produits_fournisseurs_categorie ON produits_fournisseurs(categorie_id);
CREATE INDEX idx_produits_fournisseurs_embedding ON produits_fournisseurs USING ivfflat (embedding_vector vector_cosine_ops);

CREATE INDEX idx_membres_club_pays ON membres_club(pays_id);
CREATE INDEX idx_membres_club_user ON membres_club(user_id);
CREATE INDEX idx_membres_club_niveau ON membres_club(niveau_abonnement);

CREATE INDEX idx_scores_matching_membre ON scores_matching(membre_id);
CREATE INDEX idx_scores_matching_fournisseur ON scores_matching(fournisseur_id);
CREATE INDEX idx_scores_matching_score ON scores_matching(score_compatibilite DESC);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_lu ON notifications(user_id, lu);

CREATE INDEX idx_transactions_membre ON transactions(membre_id);
CREATE INDEX idx_transactions_fournisseur ON transactions(fournisseur_id);

CREATE INDEX idx_logs_activite_user ON logs_activite(user_id);
CREATE INDEX idx_logs_activite_action ON logs_activite(action);

-- ============================================================
-- INSERTION DONNEES INITIALES
-- ============================================================

-- Pays africains
INSERT INTO pays_africains (nom, code_iso, devise, taux_douane_moyen) VALUES
('Sénégal', 'SEN', 'XOF', 18.00),
('Côte d''Ivoire', 'CIV', 'XOF', 17.50),
('Cameroun', 'CMR', 'XAF', 20.00),
('Nigeria', 'NGA', 'NGN', 15.00),
('Ghana', 'GHA', 'GHS', 12.50),
('Kenya', 'KEN', 'KES', 16.00),
('Tanzanie', 'TZA', 'TZS', 18.00),
('Afrique du Sud', 'ZAF', 'ZAR', 10.00),
('Maroc', 'MAR', 'MAD', 25.00),
('Égypte', 'EGY', 'EGP', 14.00),
('RD Congo', 'COD', 'CDF', 20.00),
('Éthiopie', 'ETH', 'ETB', 22.00),
('Algérie', 'DZA', 'DZD', 30.00),
('Tunisie', 'TUN', 'TND', 20.00),
('Mali', 'MLI', 'XOF', 18.00),
('Burkina Faso', 'BFA', 'XOF', 18.00),
('Niger', 'NER', 'XOF', 18.00),
('Bénin', 'BEN', 'XOF', 18.00),
('Togo', 'TGO', 'XOF', 18.00),
('Guinée', 'GIN', 'GNF', 15.00);

-- Catégories de produits
INSERT INTO categories_produits (nom, description) VALUES
('Électronique', 'Appareils électroniques, gadgets, accessoires'),
('Textile & Habillement', 'Vêtements, tissus, accessoires mode'),
('Équipements Industriels', 'Machines, outils, équipements de production'),
('Automobile', 'Pièces détachées, accessoires auto'),
('Cosmétiques & Beauté', 'Produits de beauté, soins personnels'),
('Alimentation', 'Produits alimentaires, boissons'),
('Électroménager', 'Appareils ménagers, cuisine'),
('Matériaux Construction', 'Matériaux de construction, quincaillerie'),
('Mobilier', 'Meubles, décoration intérieure'),
('Santé & Médical', 'Équipements médicaux, produits de santé'),
('Jouets & Loisirs', 'Jouets, jeux, articles de loisirs'),
('Sport & Fitness', 'Équipements sportifs, vêtements de sport'),
('Agriculture', 'Équipements agricoles, semences, engrais'),
('Emballage', 'Matériaux d''emballage, conteneurs'),
('Énergie Solaire', 'Panneaux solaires, batteries, onduleurs');

-- Paramètres système
INSERT INTO parametres_systeme (cle, valeur, type, description) VALUES
('commission_min', '3', 'number', 'Commission minimum en pourcentage'),
('commission_max', '7', 'number', 'Commission maximum en pourcentage'),
('seuil_matching_min', '0.6', 'number', 'Score minimum pour un matching'),
('delai_rapport_hebdo', '7', 'number', 'Délai en jours pour rapport hebdomadaire'),
('whatsapp_actif', 'true', 'boolean', 'Activation des notifications WhatsApp'),
('embedding_model', 'sentence-transformers/all-MiniLM-L6-v2', 'string', 'Modèle pour embeddings'),
('max_matchs_jour', '50', 'number', 'Nombre maximum de matchs par jour par membre');
