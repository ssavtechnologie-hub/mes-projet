// ============================================================
// AFRICAN CHINA BUSINESS CHALLENGE 2026
// EDGE FUNCTION: Calcul des marges automatisé
// ============================================================

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface MargeRequest {
  produit_afrique_id: string
  produit_fournisseur_id: string
  quantite?: number
  cout_transport?: number
  cout_logistique?: number
}

interface MargeResponse {
  success: boolean
  data?: {
    prix_achat: number
    cout_transport: number
    cout_douane: number
    cout_logistique: number
    prix_revient_total: number
    prix_vente_estime: number
    marge_brute: number
    marge_brute_pourcentage: number
    marge_nette: number
    roi_estime: number
    risque_niveau: string
    recommandation: string
    volume_recommande: number
  }
  error?: string
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { produit_afrique_id, produit_fournisseur_id, quantite = 1, cout_transport = 0, cout_logistique = 0 }: MargeRequest = await req.json()

    // Récupérer le produit africain
    const { data: produitAfrique, error: errProduit } = await supabaseClient
      .from('produits_afrique')
      .select(`
        *,
        pays_africains (
          taux_douane_moyen,
          devise
        )
      `)
      .eq('id', produit_afrique_id)
      .single()

    if (errProduit || !produitAfrique) {
      throw new Error('Produit africain non trouvé')
    }

    // Récupérer le produit fournisseur
    const { data: produitFournisseur, error: errFournisseur } = await supabaseClient
      .from('produits_fournisseurs')
      .select('*')
      .eq('id', produit_fournisseur_id)
      .single()

    if (errFournisseur || !produitFournisseur) {
      throw new Error('Produit fournisseur non trouvé')
    }

    // Calculs
    const prixAchat = produitFournisseur.prix_usine * quantite
    const tauxDouane = produitAfrique.pays_africains?.taux_douane_moyen || 15
    const coutDouane = prixAchat * (tauxDouane / 100)
    
    // Estimation transport si non fourni
    const transportEstime = cout_transport > 0 ? cout_transport : prixAchat * 0.08
    const logistiqueEstime = cout_logistique > 0 ? cout_logistique : prixAchat * 0.03

    const prixRevientTotal = prixAchat + transportEstime + coutDouane + logistiqueEstime
    const prixVenteEstime = produitAfrique.prix_moyen * quantite

    const margeBrute = prixVenteEstime - prixRevientTotal
    const margeBrutePourcentage = (margeBrute / prixVenteEstime) * 100

    // Marge nette (après frais opérationnels estimés à 10%)
    const margeNette = margeBrute * 0.9
    const roiEstime = (margeNette / prixAchat) * 100

    // Niveau de risque
    let risqueNiveau: string
    let recommandation: string

    if (margeBrutePourcentage >= 30) {
      risqueNiveau = 'faible'
      recommandation = 'Excellent potentiel! Produit fortement recommandé avec une marge confortable.'
    } else if (margeBrutePourcentage >= 20) {
      risqueNiveau = 'faible'
      recommandation = 'Bon potentiel. Marge satisfaisante pour ce type de produit.'
    } else if (margeBrutePourcentage >= 15) {
      risqueNiveau = 'moyen'
      recommandation = 'Marge acceptable. Négociez le prix d\'achat ou augmentez les volumes.'
    } else if (margeBrutePourcentage >= 10) {
      risqueNiveau = 'moyen'
      recommandation = 'Marge serrée. Assurez-vous de maîtriser tous les coûts annexes.'
    } else {
      risqueNiveau = 'eleve'
      recommandation = 'Attention! Marge très faible. Recherchez des alternatives ou négociez fortement.'
    }

    // Volume recommandé pour optimiser les coûts
    const volumeRecommande = Math.max(produitFournisseur.moq || 1, Math.ceil(5000 / produitFournisseur.prix_usine))

    // Sauvegarder l'analyse
    const { data: analyse, error: errAnalyse } = await supabaseClient
      .from('analyses_marges')
      .insert({
        produit_afrique_id,
        produit_fournisseur_id,
        prix_achat: prixAchat,
        cout_transport: transportEstime,
        cout_douane: coutDouane,
        cout_logistique: logistiqueEstime,
        prix_revient_total: prixRevientTotal,
        prix_vente_estime: prixVenteEstime,
        marge_brute: margeBrute,
        marge_brute_pourcentage: margeBrutePourcentage,
        marge_nette: margeNette,
        marge_nette_pourcentage: (margeNette / prixVenteEstime) * 100,
        roi_estime: roiEstime,
        volume_recommande: volumeRecommande,
        risque_niveau: risqueNiveau,
        recommandation,
        details_calcul: {
          quantite,
          taux_douane: tauxDouane,
          prix_unitaire_achat: produitFournisseur.prix_usine,
          prix_unitaire_vente: produitAfrique.prix_moyen
        }
      })
      .select()
      .single()

    const response: MargeResponse = {
      success: true,
      data: {
        prix_achat: prixAchat,
        cout_transport: transportEstime,
        cout_douane: coutDouane,
        cout_logistique: logistiqueEstime,
        prix_revient_total: prixRevientTotal,
        prix_vente_estime: prixVenteEstime,
        marge_brute: margeBrute,
        marge_brute_pourcentage: Math.round(margeBrutePourcentage * 100) / 100,
        marge_nette: margeNette,
        roi_estime: Math.round(roiEstime * 100) / 100,
        risque_niveau: risqueNiveau,
        recommandation,
        volume_recommande: volumeRecommande
      }
    }

    return new Response(JSON.stringify(response), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200
    })

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
