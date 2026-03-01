// ============================================================
// AFRICAN CHINA BUSINESS CHALLENGE 2026
// EDGE FUNCTION: Envoi notifications WhatsApp
// ============================================================

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface WhatsAppRequest {
  notification_id?: string
  membre_id?: string
  type: 'match' | 'rapport' | 'alerte' | 'custom'
  message?: string
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

    const WHATSAPP_API_URL = Deno.env.get('WHATSAPP_API_URL')
    const WHATSAPP_TOKEN = Deno.env.get('WHATSAPP_TOKEN')
    const WHATSAPP_PHONE_ID = Deno.env.get('WHATSAPP_PHONE_ID')

    if (!WHATSAPP_API_URL || !WHATSAPP_TOKEN) {
      throw new Error('Configuration WhatsApp manquante')
    }

    const { notification_id, membre_id, type, message }: WhatsAppRequest = await req.json()

    let phoneNumber: string | null = null
    let messageContent: string = ''
    let notificationToUpdate: string | null = null

    if (notification_id) {
      // Récupérer la notification et le membre associé
      const { data: notification, error } = await supabaseClient
        .from('notifications')
        .select(`
          *,
          membres_club!inner (
            whatsapp,
            nom_complet
          )
        `)
        .eq('id', notification_id)
        .single()

      if (error || !notification) {
        throw new Error('Notification non trouvée')
      }

      phoneNumber = notification.membres_club.whatsapp
      messageContent = `🔔 *${notification.titre}*\n\n${notification.contenu}`
      notificationToUpdate = notification_id

    } else if (membre_id) {
      // Récupérer le membre directement
      const { data: membre, error } = await supabaseClient
        .from('membres_club')
        .select('whatsapp, nom_complet')
        .eq('id', membre_id)
        .single()

      if (error || !membre) {
        throw new Error('Membre non trouvé')
      }

      phoneNumber = membre.whatsapp
      
      // Message selon le type
      switch (type) {
        case 'match':
          messageContent = `🎯 *Nouveau Match Trouvé!*\n\nBonjour ${membre.nom_complet},\n\nNous avons trouvé de nouveaux fournisseurs correspondant à vos critères.\n\nConnectez-vous pour les découvrir!`
          break
        case 'rapport':
          messageContent = `📊 *Rapport Hebdomadaire Disponible*\n\nBonjour ${membre.nom_complet},\n\nVotre rapport d'analyse de marché est prêt.\n\nConsultez-le dans votre espace membre.`
          break
        case 'alerte':
          messageContent = `⚠️ *Alerte Importante*\n\n${message || 'Vous avez une notification importante.'}`
          break
        case 'custom':
          messageContent = message || 'Message de African China Business Challenge'
          break
      }
    }

    if (!phoneNumber) {
      throw new Error('Numéro WhatsApp non disponible')
    }

    // Formater le numéro (enlever les espaces et le +)
    const formattedPhone = phoneNumber.replace(/[\s+]/g, '')

    // Envoyer via WhatsApp Business API
    const whatsappResponse = await fetch(`${WHATSAPP_API_URL}/${WHATSAPP_PHONE_ID}/messages`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${WHATSAPP_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        messaging_product: 'whatsapp',
        to: formattedPhone,
        type: 'text',
        text: {
          preview_url: false,
          body: messageContent
        }
      })
    })

    const whatsappResult = await whatsappResponse.json()

    if (!whatsappResponse.ok) {
      throw new Error(`WhatsApp API Error: ${JSON.stringify(whatsappResult)}`)
    }

    // Mettre à jour la notification si applicable
    if (notificationToUpdate) {
      await supabaseClient
        .from('notifications')
        .update({
          envoye_whatsapp: true,
          date_envoi_whatsapp: new Date().toISOString()
        })
        .eq('id', notificationToUpdate)
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Message WhatsApp envoyé',
        whatsapp_response: whatsappResult
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
