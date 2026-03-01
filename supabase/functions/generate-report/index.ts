// ============================================================
// AFRICAN CHINA BUSINESS CHALLENGE 2026
// EDGE FUNCTION: Génération rapport hebdomadaire
// ============================================================

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface RapportRequest {
  membre_id: string
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { membre_id }: RapportRequest = await req.json()

    // Vérifier que le membre est premium
    const { data: membre, error: errMembre } = await supabaseClient
      .from('membres_club')
      .select('*, pays_africains(*)')
      .eq('id', membre_id)
      .single()

    if (errMembre || !membre) {
      throw new Error('Membre non trouvé')
    }

    if (!['premium', 'enterprise'].includes(membre.niveau_abonnement)) {
      throw new Error('Fonctionnalité réservée aux membres Premium')
    }

    const dateDebut = new Date()
    dateDebut.setDate(dateDebut.getDate() - 7)
    const dateFin = new Date()

    // Nouveaux produits de la semaine dans les catégories d'intérêt
    let produitsQuery = supabaseClient
      .from('produits_afrique')
      .select('*')
      .gte('created_at', dateDebut.toISOString())
      .order('created_at', { ascending: false })
      .limit(10)

    if (membre.categories_interet && membre.categories_interet.length > 0) {
      produitsQuery = produitsQuery.in('categorie_id', membre.categories_interet)
    }

    const { data: nouveauxProduits } = await produitsQuery

    // Nouveaux matchs de la semaine
    const { data: nouveauxMatchs, error: errMatchs } = await supabaseClient
      .from('scores_matching')
      .select(`
        *,
        fournisseurs_chine (nom, score_fiabilite),
        produits_fournisseurs (nom, prix_usine)
      `)
      .eq('membre_id', membre_id)
      .gte('created_at', dateDebut.toISOString())
      .order('score_compatibilite', { ascending: false })
      .limit(5)

    // Meilleures opportunités (analyses avec bonnes marges)
    const { data: meilleuresOpportunites } = await supabaseClient
      .from('analyses_marges')
      .select(`
        *,
        produits_afrique (nom, prix_moyen),
        produits_fournisseurs (nom, prix_usine, fournisseurs_chine (nom))
      `)
      .gte('marge_brute_pourcentage', 20)
      .gte('created_at', dateDebut.toISOString())
      .order('marge_brute_pourcentage', { ascending: false })
      .limit(5)

    // Générer les recommandations
    const recommandations: string[] = []

    if (nouveauxMatchs && nouveauxMatchs.length > 0) {
      recommandations.push(`${nouveauxMatchs.length} nouveaux fournisseurs correspondent à votre profil cette semaine.`)
    }

    if (meilleuresOpportunites && meilleuresOpportunites.length > 0) {
      const meilleureMarge = meilleuresOpportunites[0]
      recommandations.push(`Opportunité à explorer: ${meilleureMarge.produits_afrique?.nom} avec une marge potentielle de ${meilleureMarge.marge_brute_pourcentage?.toFixed(1)}%`)
    }

    if (membre.experience_import === 'debutant') {
      recommandations.push('Conseil: Privilégiez les fournisseurs avec un score de fiabilité supérieur à 0.8 pour vos premières commandes.')
    }

    // Tendances du marché
    const tendances = {
      produits_populaires: nouveauxProduits?.slice(0, 3).map(p => p.nom) || [],
      prix_moyen_categorie: nouveauxProduits?.reduce((acc, p) => acc + (p.prix_moyen || 0), 0) / (nouveauxProduits?.length || 1),
      volume_matchs: nouveauxMatchs?.length || 0
    }

    // Créer le rapport
    const { data: rapport, error: errRapport } = await supabaseClient
      .from('rapports_hebdomadaires')
      .insert({
        membre_id,
        semaine_debut: dateDebut.toISOString().split('T')[0],
        semaine_fin: dateFin.toISOString().split('T')[0],
        nombre_nouveaux_produits: nouveauxProduits?.length || 0,
        nombre_nouveaux_matchs: nouveauxMatchs?.length || 0,
        meilleurs_produits: nouveauxProduits?.slice(0, 5) || [],
        tendances_marche: tendances,
        recommandations
      })
      .select()
      .single()

    if (errRapport) {
      throw new Error('Erreur lors de la création du rapport')
    }

    // Créer une notification
    await supabaseClient
      .from('notifications')
      .insert({
        user_id: membre.user_id,
        type: 'rapport',
        titre: 'Rapport Hebdomadaire Disponible',
        contenu: `Votre rapport du ${dateDebut.toLocaleDateString('fr-FR')} au ${dateFin.toLocaleDateString('fr-FR')} est prêt.`,
        data: { rapport_id: rapport.id }
      })

    return new Response(
      JSON.stringify({
        success: true,
        rapport: {
          id: rapport.id,
          periode: {
            debut: dateDebut.toISOString().split('T')[0],
            fin: dateFin.toISOString().split('T')[0]
          },
          statistiques: {
            nouveaux_produits: nouveauxProduits?.length || 0,
            nouveaux_matchs: nouveauxMatchs?.length || 0,
            opportunites_identifiees: meilleuresOpportunites?.length || 0
          },
          meilleurs_matchs: nouveauxMatchs?.slice(0, 3) || [],
          meilleures_opportunites: meilleuresOpportunites?.slice(0, 3) || [],
          recommandations,
          tendances
        }
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200
      }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400
      }
    )
  }
})
