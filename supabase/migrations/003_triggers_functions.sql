-- ============================================================
-- AFRICAN CHINA BUSINESS CHALLENGE 2026
-- TRIGGERS ET FONCTIONS AUTOMATISEES
-- ============================================================

-- ============================================================
-- FONCTION: Mise à jour automatique du timestamp updated_at
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Appliquer le trigger sur toutes les tables avec updated_at
CREATE TRIGGER update_pays_africains_updated_at
    BEFORE UPDATE ON pays_africains
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_produits_afrique_updated_at
    BEFORE UPDATE ON produits_afrique
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fournisseurs_chine_updated_at
    BEFORE UPDATE ON fournisseurs_chine
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_produits_fournisseurs_updated_at
    BEFORE UPDATE ON produits_fournisseurs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_membres_club_updated_at
    BEFORE UPDATE ON membres_club
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_analyses_marges_updated_at
    BEFORE UPDATE ON analyses_marges
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_scores_matching_updated_at
    BEFORE UPDATE ON scores_matching
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mises_en_relation_updated_at
    BEFORE UPDATE ON mises_en_relation
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at
    BEFORE UPDATE ON transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- FONCTION: Calcul automatique des marges
-- ============================================================

CREATE OR REPLACE FUNCTION calculer_marge_automatique()
RETURNS TRIGGER AS $$
DECLARE
    taux_douane DECIMAL;
    prix_vente DECIMAL;
BEGIN
    -- Récupérer le taux de douane du pays
    SELECT COALESCE(pa.taux_douane_moyen, 15) INTO taux_douane
    FROM produits_afrique paf
    JOIN pays_africains pa ON paf.pays_id = pa.id
    WHERE paf.id = NEW.produit_afrique_id;
    
    -- Récupérer le prix de vente estimé
    SELECT prix_moyen INTO prix_vente
    FROM produits_afrique
    WHERE id = NEW.produit_afrique_id;
    
    -- Calculer le coût douane si non fourni
    IF NEW.cout_douane IS NULL OR NEW.cout_douane = 0 THEN
        NEW.cout_douane := NEW.prix_achat * (taux_douane / 100);
    END IF;
    
    -- Calculer le prix de revient total
    NEW.prix_revient_total := NEW.prix_achat 
        + COALESCE(NEW.cout_transport, 0) 
        + COALESCE(NEW.cout_douane, 0) 
        + COALESCE(NEW.cout_logistique, 0) 
        + COALESCE(NEW.autres_frais, 0);
    
    -- Prix de vente estimé
    NEW.prix_vente_estime := COALESCE(prix_vente, NEW.prix_revient_total * 1.3);
    
    -- Calculer les marges
    NEW.marge_brute := NEW.prix_vente_estime - NEW.prix_revient_total;
    NEW.marge_brute_pourcentage := (NEW.marge_brute / NEW.prix_vente_estime) * 100;
    
    -- Marge nette (estimation avec 10% de frais opérationnels)
    NEW.marge_nette := NEW.marge_brute * 0.9;
    NEW.marge_nette_pourcentage := (NEW.marge_nette / NEW.prix_vente_estime) * 100;
    
    -- ROI estimé
    IF NEW.prix_achat > 0 THEN
        NEW.roi_estime := (NEW.marge_nette / NEW.prix_achat) * 100;
    END IF;
    
    -- Niveau de risque
    IF NEW.marge_brute_pourcentage >= 30 THEN
        NEW.risque_niveau := 'faible';
    ELSIF NEW.marge_brute_pourcentage >= 15 THEN
        NEW.risque_niveau := 'moyen';
    ELSE
        NEW.risque_niveau := 'eleve';
    END IF;
    
    -- Recommandation automatique
    IF NEW.marge_brute_pourcentage >= 25 THEN
        NEW.recommandation := 'Produit recommandé - Bonne marge potentielle';
    ELSIF NEW.marge_brute_pourcentage >= 15 THEN
        NEW.recommandation := 'Produit acceptable - Marge correcte, négocier le prix d''achat';
    ELSE
        NEW.recommandation := 'Attention - Marge faible, vérifier les coûts ou chercher alternatives';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_calcul_marge
    BEFORE INSERT OR UPDATE ON analyses_marges
    FOR EACH ROW EXECUTE FUNCTION calculer_marge_automatique();

-- ============================================================
-- FONCTION: Génération numéro transaction
-- ============================================================

CREATE OR REPLACE FUNCTION generer_numero_transaction()
RETURNS TRIGGER AS $$
BEGIN
    NEW.numero_transaction := 'ACBC-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || 
        LPAD(NEXTVAL('transaction_seq')::TEXT, 6, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE IF NOT EXISTS transaction_seq START 1;

CREATE TRIGGER trigger_numero_transaction
    BEFORE INSERT ON transactions
    FOR EACH ROW
    WHEN (NEW.numero_transaction IS NULL)
    EXECUTE FUNCTION generer_numero_transaction();

-- ============================================================
-- FONCTION: Calcul score de matching
-- ============================================================

CREATE OR REPLACE FUNCTION calculer_score_matching(
    p_membre_id UUID,
    p_fournisseur_id UUID,
    p_produit_id UUID DEFAULT NULL
)
RETURNS TABLE (
    score_total DECIMAL,
    score_budget DECIMAL,
    score_categorie DECIMAL,
    score_experience DECIMAL,
    raisons TEXT[]
) AS $$
DECLARE
    v_membre membres_club%ROWTYPE;
    v_fournisseur fournisseurs_chine%ROWTYPE;
    v_produit produits_fournisseurs%ROWTYPE;
    v_score_budget DECIMAL := 0;
    v_score_categorie DECIMAL := 0;
    v_score_experience DECIMAL := 0;
    v_score_total DECIMAL := 0;
    v_raisons TEXT[] := ARRAY[]::TEXT[];
BEGIN
    -- Récupérer les données du membre
    SELECT * INTO v_membre FROM membres_club WHERE id = p_membre_id;
    
    -- Récupérer les données du fournisseur
    SELECT * INTO v_fournisseur FROM fournisseurs_chine WHERE id = p_fournisseur_id;
    
    -- Récupérer le produit si spécifié
    IF p_produit_id IS NOT NULL THEN
        SELECT * INTO v_produit FROM produits_fournisseurs WHERE id = p_produit_id;
    END IF;
    
    -- Score budget (0-1)
    IF v_produit.prix_usine IS NOT NULL AND v_membre.budget_min IS NOT NULL THEN
        IF v_produit.prix_usine * COALESCE(v_produit.moq, 1) <= v_membre.budget_max THEN
            v_score_budget := 1.0;
            v_raisons := array_append(v_raisons, 'Budget compatible');
        ELSIF v_produit.prix_usine * COALESCE(v_produit.moq, 1) <= v_membre.budget_max * 1.2 THEN
            v_score_budget := 0.7;
            v_raisons := array_append(v_raisons, 'Budget légèrement dépassé');
        ELSE
            v_score_budget := 0.3;
            v_raisons := array_append(v_raisons, 'Budget insuffisant');
        END IF;
    ELSE
        v_score_budget := 0.5;
    END IF;
    
    -- Score catégorie (0-1)
    IF v_produit.categorie_id IS NOT NULL AND v_membre.categories_interet IS NOT NULL THEN
        IF v_produit.categorie_id = ANY(v_membre.categories_interet) THEN
            v_score_categorie := 1.0;
            v_raisons := array_append(v_raisons, 'Catégorie d''intérêt');
        ELSE
            v_score_categorie := 0.3;
        END IF;
    ELSE
        v_score_categorie := 0.5;
    END IF;
    
    -- Score expérience (0-1)
    CASE v_membre.experience_import
        WHEN 'expert' THEN
            v_score_experience := 1.0;
            v_raisons := array_append(v_raisons, 'Importateur expérimenté');
        WHEN 'intermediaire' THEN
            v_score_experience := 0.7;
        WHEN 'debutant' THEN
            -- Favoriser les fournisseurs avec bon score de fiabilité pour débutants
            IF v_fournisseur.score_fiabilite >= 0.8 THEN
                v_score_experience := 0.8;
                v_raisons := array_append(v_raisons, 'Fournisseur fiable pour débutant');
            ELSE
                v_score_experience := 0.4;
            END IF;
        ELSE
            v_score_experience := 0.5;
    END CASE;
    
    -- Bonus fournisseur vérifié
    IF v_fournisseur.verifie THEN
        v_raisons := array_append(v_raisons, 'Fournisseur vérifié');
    END IF;
    
    -- Calcul score total pondéré
    v_score_total := (v_score_budget * 0.4) + (v_score_categorie * 0.35) + (v_score_experience * 0.25);
    
    -- Bonus si fournisseur très fiable
    IF v_fournisseur.score_fiabilite >= 0.9 THEN
        v_score_total := LEAST(v_score_total + 0.1, 1.0);
    END IF;
    
    RETURN QUERY SELECT v_score_total, v_score_budget, v_score_categorie, v_score_experience, v_raisons;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- FONCTION: Créer notification
-- ============================================================

CREATE OR REPLACE FUNCTION creer_notification(
    p_user_id UUID,
    p_type VARCHAR,
    p_titre VARCHAR,
    p_contenu TEXT,
    p_data JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_notification_id UUID;
BEGIN
    INSERT INTO notifications (user_id, type, titre, contenu, data)
    VALUES (p_user_id, p_type, p_titre, p_contenu, p_data)
    RETURNING id INTO v_notification_id;
    
    RETURN v_notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- TRIGGER: Notification nouveau match
-- ============================================================

CREATE OR REPLACE FUNCTION notify_nouveau_match()
RETURNS TRIGGER AS $$
DECLARE
    v_user_id UUID;
    v_fournisseur_nom VARCHAR;
BEGIN
    -- Récupérer l'user_id du membre
    SELECT user_id INTO v_user_id
    FROM membres_club WHERE id = NEW.membre_id;
    
    -- Récupérer le nom du fournisseur
    SELECT nom INTO v_fournisseur_nom
    FROM fournisseurs_chine WHERE id = NEW.fournisseur_id;
    
    -- Créer notification si score élevé
    IF NEW.score_compatibilite >= 0.7 THEN
        PERFORM creer_notification(
            v_user_id,
            'match',
            'Nouveau match qualifié!',
            'Un fournisseur correspondant à vos critères a été trouvé: ' || v_fournisseur_nom,
            jsonb_build_object(
                'matching_id', NEW.id,
                'fournisseur_id', NEW.fournisseur_id,
                'score', NEW.score_compatibilite
            )
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_notify_match
    AFTER INSERT ON scores_matching
    FOR EACH ROW EXECUTE FUNCTION notify_nouveau_match();

-- ============================================================
-- TRIGGER: Log d'activité automatique
-- ============================================================

CREATE OR REPLACE FUNCTION log_activite_membre()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO logs_activite (user_id, action, entite, entite_id, details)
        VALUES (
            auth.uid(),
            'creation',
            TG_TABLE_NAME,
            NEW.id,
            jsonb_build_object('operation', TG_OP)
        );
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO logs_activite (user_id, action, entite, entite_id, details)
        VALUES (
            auth.uid(),
            'modification',
            TG_TABLE_NAME,
            NEW.id,
            jsonb_build_object('operation', TG_OP)
        );
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO logs_activite (user_id, action, entite, entite_id, details)
        VALUES (
            auth.uid(),
            'suppression',
            TG_TABLE_NAME,
            OLD.id,
            jsonb_build_object('operation', TG_OP)
        );
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Appliquer sur les tables importantes
CREATE TRIGGER log_mises_en_relation
    AFTER INSERT OR UPDATE OR DELETE ON mises_en_relation
    FOR EACH ROW EXECUTE FUNCTION log_activite_membre();

CREATE TRIGGER log_transactions
    AFTER INSERT OR UPDATE OR DELETE ON transactions
    FOR EACH ROW EXECUTE FUNCTION log_activite_membre();

-- ============================================================
-- FONCTION: Mise à jour score activité membre
-- ============================================================

CREATE OR REPLACE FUNCTION update_score_activite_membre()
RETURNS TRIGGER AS $$
DECLARE
    v_score DECIMAL;
    v_nb_relations INTEGER;
    v_nb_transactions INTEGER;
BEGIN
    -- Compter les mises en relation
    SELECT COUNT(*) INTO v_nb_relations
    FROM mises_en_relation
    WHERE membre_id = NEW.membre_id
    AND created_at > NOW() - INTERVAL '30 days';
    
    -- Compter les transactions
    SELECT COUNT(*) INTO v_nb_transactions
    FROM transactions
    WHERE membre_id = NEW.membre_id
    AND statut IN ('paye', 'expedie', 'livre');
    
    -- Calculer le score (0-1)
    v_score := LEAST(
        (v_nb_relations * 0.1) + (v_nb_transactions * 0.3),
        1.0
    );
    
    -- Mettre à jour le membre
    UPDATE membres_club
    SET score_activite = v_score,
        nombre_imports_realises = v_nb_transactions
    WHERE id = NEW.membre_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_update_score_membre
    AFTER INSERT ON transactions
    FOR EACH ROW EXECUTE FUNCTION update_score_activite_membre();

-- ============================================================
-- FONCTION: Recherche produits similaires (vectorielle)
-- ============================================================

CREATE OR REPLACE FUNCTION rechercher_produits_similaires(
    p_query_embedding vector(384),
    p_limit INTEGER DEFAULT 10,
    p_seuil_similarite DECIMAL DEFAULT 0.5
)
RETURNS TABLE (
    id UUID,
    nom VARCHAR,
    prix_moyen DECIMAL,
    pays_nom VARCHAR,
    similarite DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pa.id,
        pa.nom,
        pa.prix_moyen,
        pays.nom AS pays_nom,
        (1 - (pa.embedding_vector <=> p_query_embedding))::DECIMAL AS similarite
    FROM produits_afrique pa
    LEFT JOIN pays_africains pays ON pa.pays_id = pays.id
    WHERE pa.embedding_vector IS NOT NULL
    AND (1 - (pa.embedding_vector <=> p_query_embedding)) >= p_seuil_similarite
    ORDER BY pa.embedding_vector <=> p_query_embedding
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- FONCTION: Statistiques dashboard membre
-- ============================================================

CREATE OR REPLACE FUNCTION get_membre_dashboard_stats(p_membre_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_stats JSONB;
BEGIN
    SELECT jsonb_build_object(
        'total_matchs', (
            SELECT COUNT(*) FROM scores_matching WHERE membre_id = p_membre_id
        ),
        'matchs_qualifies', (
            SELECT COUNT(*) FROM scores_matching 
            WHERE membre_id = p_membre_id AND score_compatibilite >= 0.7
        ),
        'relations_en_cours', (
            SELECT COUNT(*) FROM mises_en_relation 
            WHERE membre_id = p_membre_id AND statut IN ('en_attente', 'accepte', 'en_cours')
        ),
        'transactions_total', (
            SELECT COUNT(*) FROM transactions WHERE membre_id = p_membre_id
        ),
        'montant_total_transactions', (
            SELECT COALESCE(SUM(montant_total), 0) FROM transactions 
            WHERE membre_id = p_membre_id AND statut IN ('paye', 'expedie', 'livre')
        ),
        'notifications_non_lues', (
            SELECT COUNT(*) FROM notifications n
            JOIN membres_club m ON n.user_id = m.user_id
            WHERE m.id = p_membre_id AND n.lu = FALSE
        )
    ) INTO v_stats;
    
    RETURN v_stats;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
