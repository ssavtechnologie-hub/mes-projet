-- ============================================================
-- AFRICAN CHINA BUSINESS CHALLENGE 2026
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================

-- Activer RLS sur toutes les tables
ALTER TABLE pays_africains ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories_produits ENABLE ROW LEVEL SECURITY;
ALTER TABLE produits_afrique ENABLE ROW LEVEL SECURITY;
ALTER TABLE fournisseurs_chine ENABLE ROW LEVEL SECURITY;
ALTER TABLE produits_fournisseurs ENABLE ROW LEVEL SECURITY;
ALTER TABLE membres_club ENABLE ROW LEVEL SECURITY;
ALTER TABLE analyses_marges ENABLE ROW LEVEL SECURITY;
ALTER TABLE scores_matching ENABLE ROW LEVEL SECURITY;
ALTER TABLE mises_en_relation ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE rapports_hebdomadaires ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE logs_activite ENABLE ROW LEVEL SECURITY;
ALTER TABLE parametres_systeme ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- FONCTIONS HELPER
-- ============================================================

-- Fonction pour vérifier si l'utilisateur est admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM auth.users
        WHERE id = auth.uid()
        AND raw_user_meta_data->>'role' = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour vérifier si l'utilisateur est un membre premium
CREATE OR REPLACE FUNCTION is_premium_member()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM membres_club
        WHERE user_id = auth.uid()
        AND niveau_abonnement IN ('premium', 'enterprise')
        AND actif = TRUE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour obtenir l'ID membre de l'utilisateur connecté
CREATE OR REPLACE FUNCTION get_membre_id()
RETURNS UUID AS $$
BEGIN
    RETURN (
        SELECT id FROM membres_club
        WHERE user_id = auth.uid()
        LIMIT 1
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- POLICIES - PAYS AFRICAINS (lecture publique)
-- ============================================================

CREATE POLICY "Lecture publique pays" ON pays_africains
    FOR SELECT USING (true);

CREATE POLICY "Admin peut modifier pays" ON pays_africains
    FOR ALL USING (is_admin());

-- ============================================================
-- POLICIES - CATEGORIES PRODUITS (lecture publique)
-- ============================================================

CREATE POLICY "Lecture publique categories" ON categories_produits
    FOR SELECT USING (true);

CREATE POLICY "Admin peut modifier categories" ON categories_produits
    FOR ALL USING (is_admin());

-- ============================================================
-- POLICIES - PRODUITS AFRIQUE
-- ============================================================

-- Tous les utilisateurs authentifiés peuvent voir les produits
CREATE POLICY "Membres peuvent voir produits afrique" ON produits_afrique
    FOR SELECT USING (auth.uid() IS NOT NULL);

-- Seuls les admins peuvent modifier
CREATE POLICY "Admin peut modifier produits afrique" ON produits_afrique
    FOR ALL USING (is_admin());

-- ============================================================
-- POLICIES - FOURNISSEURS CHINE
-- ============================================================

-- Les membres peuvent voir les fournisseurs vérifiés et actifs
CREATE POLICY "Membres peuvent voir fournisseurs" ON fournisseurs_chine
    FOR SELECT USING (
        auth.uid() IS NOT NULL 
        AND verifie = TRUE 
        AND actif = TRUE
    );

-- Admin peut tout voir et modifier
CREATE POLICY "Admin gestion fournisseurs" ON fournisseurs_chine
    FOR ALL USING (is_admin());

-- ============================================================
-- POLICIES - PRODUITS FOURNISSEURS
-- ============================================================

-- Membres peuvent voir les produits des fournisseurs actifs
CREATE POLICY "Membres peuvent voir produits fournisseurs" ON produits_fournisseurs
    FOR SELECT USING (
        auth.uid() IS NOT NULL
        AND actif = TRUE
        AND EXISTS (
            SELECT 1 FROM fournisseurs_chine
            WHERE id = produits_fournisseurs.fournisseur_id
            AND actif = TRUE
        )
    );

-- Admin peut tout gérer
CREATE POLICY "Admin gestion produits fournisseurs" ON produits_fournisseurs
    FOR ALL USING (is_admin());

-- ============================================================
-- POLICIES - MEMBRES CLUB
-- ============================================================

-- Un membre peut voir et modifier son propre profil
CREATE POLICY "Membre peut voir son profil" ON membres_club
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Membre peut modifier son profil" ON membres_club
    FOR UPDATE USING (user_id = auth.uid());

-- Un membre peut créer son profil
CREATE POLICY "Utilisateur peut creer profil" ON membres_club
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Admin peut tout voir
CREATE POLICY "Admin voit tous membres" ON membres_club
    FOR SELECT USING (is_admin());

CREATE POLICY "Admin gestion membres" ON membres_club
    FOR ALL USING (is_admin());

-- ============================================================
-- POLICIES - ANALYSES MARGES
-- ============================================================

-- Membres gratuits: accès limité
CREATE POLICY "Membres gratuits analyses limitees" ON analyses_marges
    FOR SELECT USING (
        auth.uid() IS NOT NULL
        AND NOT is_premium_member()
        AND created_at > NOW() - INTERVAL '7 days'
    );

-- Membres premium: accès complet
CREATE POLICY "Membres premium toutes analyses" ON analyses_marges
    FOR SELECT USING (is_premium_member());

-- Admin peut tout gérer
CREATE POLICY "Admin gestion analyses" ON analyses_marges
    FOR ALL USING (is_admin());

-- ============================================================
-- POLICIES - SCORES MATCHING
-- ============================================================

-- Membre peut voir ses propres matchs
CREATE POLICY "Membre voit ses matchs" ON scores_matching
    FOR SELECT USING (membre_id = get_membre_id());

-- Membre peut mettre à jour le statut de ses matchs
CREATE POLICY "Membre update statut match" ON scores_matching
    FOR UPDATE USING (membre_id = get_membre_id())
    WITH CHECK (membre_id = get_membre_id());

-- Admin peut tout gérer
CREATE POLICY "Admin gestion matchs" ON scores_matching
    FOR ALL USING (is_admin());

-- ============================================================
-- POLICIES - MISES EN RELATION
-- ============================================================

-- Membre peut voir ses mises en relation
CREATE POLICY "Membre voit ses relations" ON mises_en_relation
    FOR SELECT USING (membre_id = get_membre_id());

-- Membre peut créer une mise en relation
CREATE POLICY "Membre peut creer relation" ON mises_en_relation
    FOR INSERT WITH CHECK (membre_id = get_membre_id());

-- Membre peut modifier ses relations
CREATE POLICY "Membre peut modifier relation" ON mises_en_relation
    FOR UPDATE USING (membre_id = get_membre_id());

-- Admin peut tout gérer
CREATE POLICY "Admin gestion relations" ON mises_en_relation
    FOR ALL USING (is_admin());

-- ============================================================
-- POLICIES - NOTIFICATIONS
-- ============================================================

-- Utilisateur voit ses notifications
CREATE POLICY "User voit ses notifications" ON notifications
    FOR SELECT USING (user_id = auth.uid());

-- Utilisateur peut marquer comme lu
CREATE POLICY "User update notifications" ON notifications
    FOR UPDATE USING (user_id = auth.uid());

-- Système peut créer des notifications (via service role)
CREATE POLICY "Admin cree notifications" ON notifications
    FOR INSERT WITH CHECK (is_admin());

-- ============================================================
-- POLICIES - RAPPORTS HEBDOMADAIRES
-- ============================================================

-- Membre premium peut voir ses rapports
CREATE POLICY "Premium voit ses rapports" ON rapports_hebdomadaires
    FOR SELECT USING (
        membre_id = get_membre_id()
        AND is_premium_member()
    );

-- Admin peut tout gérer
CREATE POLICY "Admin gestion rapports" ON rapports_hebdomadaires
    FOR ALL USING (is_admin());

-- ============================================================
-- POLICIES - TRANSACTIONS
-- ============================================================

-- Membre peut voir ses transactions
CREATE POLICY "Membre voit ses transactions" ON transactions
    FOR SELECT USING (membre_id = get_membre_id());

-- Admin peut tout gérer
CREATE POLICY "Admin gestion transactions" ON transactions
    FOR ALL USING (is_admin());

-- ============================================================
-- POLICIES - LOGS ACTIVITE
-- ============================================================

-- Utilisateur peut voir ses propres logs
CREATE POLICY "User voit ses logs" ON logs_activite
    FOR SELECT USING (user_id = auth.uid());

-- Admin peut tout voir
CREATE POLICY "Admin voit tous logs" ON logs_activite
    FOR SELECT USING (is_admin());

-- Insertion automatique (via triggers)
CREATE POLICY "Systeme insert logs" ON logs_activite
    FOR INSERT WITH CHECK (true);

-- ============================================================
-- POLICIES - PARAMETRES SYSTEME
-- ============================================================

-- Lecture publique des paramètres
CREATE POLICY "Lecture publique parametres" ON parametres_systeme
    FOR SELECT USING (true);

-- Seul admin peut modifier
CREATE POLICY "Admin modifie parametres" ON parametres_systeme
    FOR ALL USING (is_admin());
