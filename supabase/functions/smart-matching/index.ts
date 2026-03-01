// ============================================================
// AFRICAN CHINA BUSINESS CHALLENGE 2026
// EDGE FUNCTION: Matching intelligent membre-fournisseur
// ============================================================

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface MatchingRequest {
  membre_id: string
  limit?: number
  seuil_minimum?: number
}

interface Match {
  fournisseur_id: string
  fournisseur_nom: string
  produit_id?: string
  produit_nom?: string
  score_total: number
  score_budget: number
  score_categorie: number
  score_experience: number
  raisons: string[]
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

    const { membre_id, limit = 20, seuil_minimum = 0.5 }: MatchingRequest = await req.json()

    // Récupérer le profil du membre
    const { data: membre, error: errMembre } = await supabaseClient
      .from('membres_club')
      .select('*')
      .eq('id', membre_id)
      .single()

    if (errMembre || !membre) {
      throw new Error('Membre non trouvé')
    }

    // Récupérer les fournisseurs actifs avec leurs produits
    const { data: fournisseurs, error: errFournisseurs } = await supabaseClient
      .from('fournisseurs_chine')
      .select(`
        *,
        produits_fournisseurs (*)
      `)
      .eq('actif', true)
      .eq('verifie', true)

    if (errFournisseurs) {
      throw new Error('Erreur lors de la récupération des fournisseurs')
    }

    const matches: Match[] = []

    for (const fournisseur of fournisseurs || []) {
      for (const produit of fournisseur.produits_fournisseurs || []) {
        if (!produit.actif) continue

        // Calcul des scores
        let scoreBudget = 0.5
        let scoreCategorie = 0.5
        let scoreExperience = 0.5
        const raisons: string[] = []

        // Score budget
        const coutTotal = produit.prix_usine * (produit.moq || 1)
        if (membre.budget_max && coutTotal <= membre.budget_max) {
          scoreBudget = 1.0
          raisons.push('Budget compatible')
        } else if (membre.budget_max && coutTotal <= membre.budget_max * 1.2) {
          scoreBudget = 0.7
          raisons.push('Budget légèrement dépassé (négociable)')
        } else if (membre.budget_max) {
          scoreBudget = 0.3
        }

        // Score catégorie
        if (membre.categories_interet && membre.categories_interet.includes(produit.categorie_id)) {
          scoreCategorie = 1.0
          raisons.push('Catégorie recherchée')
        }

        // Score expérience
        switch (membre.experience_import) {
          case 'expert':
            scoreExperience = 1.0
            break
          case 'intermediaire':
            scoreExperience = 0.7
            break
          case 'debutant':
            if (fournisseur.score_fiabilite >= 0.8) {
              scoreExperience = 0.8
              raisons.push('Fournisseur fiable (idéal débutant)')
            } else {
              scoreExperience = 0.4
            }
            break
        }

        // Bonus fournisseur vérifié
        if (fournisseur.verifie) {
          raisons.push('Fournisseur vérifié')
        }

        // Bonus bon score fiabilité
        if (fournisseur.score_fiabilite >= 0.9) {
          raisons.push('Excellent score de fiabilité')
        }

        // Score total pondéré
        let scoreTotal = (scoreBudget * 0.4) + (scoreCategorie * 0.35) + (scoreExperience * 0.25)

        // Bonus fiabilité
        if (fournisseur.score_fiabilite >= 0.9) {
          scoreTotal = Math.min(scoreTotal + 0.1, 1.0)
        }

        if (scoreTotal >= seuil_minimum) {
          matches.push({
            fournisseur_id: fournisseur.id,
            fournisseur_nom: fournisseur.nom,
            produit_id: produit.id,
            produit_nom: produit.nom,
            score_total: Math.round(scoreTotal * 100) / 100,
            score_budget: Math.round(scoreBudget * 100) / 100,
            score_categorie: Math.round(scoreCategorie * 100) / 100,
            score_experience: Math.round(scoreExperience * 100) / 100,
            raisons
          })
        }
      }
    }

    // Trier par score décroissant
    matches.sort((a, b) => b.score_total - a.score_total)
    const topMatches = matches.slice(0, limit)

    // Sauvegarder les matchs en base
    for (const match of topMatches) {
      await supabaseClient
        .from('scores_matching')
        .upsert({
          membre_id,
          fournisseur_id: match.fournisseur_id,
          produit_fournisseur_id: match.produit_id,
          score_compatibilite: match.score_total,
          score_budget: match.score_budget,
          score_categorie: match.score_categorie,
          score_experience: match.score_experience,
          raisons_match: match.raisons,
          statut: 'nouveau'
        }, {
          onConflict: 'membre_id,fournisseur_id,produit_fournisseur_id'
        })
    }

    return new Response(
      JSON.stringify({
        success: true,
        total_matches: matches.length,
        matches: topMatches
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
