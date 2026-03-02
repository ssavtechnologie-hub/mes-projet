# ============================================================
# AFRICAN CHINA BUSINESS CHALLENGE 2026
# SCRAPER PRINCIPAL - Point d'entrée
# ============================================================

import logging
import sys
from datetime import datetime
from typing import List, Dict

from config import SITES_CONFIG, AI_CONFIG
from scrapers.jumia_scraper import JumiaScraper
from scrapers.coinafrique_scraper import CoinAfriqueScraper
from scrapers.expat_dakar_scraper import ExpatDakarScraper
from scrapers.jiji_scraper import JijiScraper
from scrapers.generic_scraper import GenericScraper
from ai.embeddings import embedding_generator
from ai.clustering import product_clusterer
from utils.database import db
from utils.helpers import categorize_product

# Configuration logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler(f'scraper_{datetime.now().strftime("%Y%m%d")}.log')
    ]
)
logger = logging.getLogger(__name__)


def get_scraper_for_site(site_key: str, site_config: Dict):
    """Retourner le bon scraper selon le site"""
    if 'jumia' in site_key:
        return JumiaScraper(site_config)
    elif 'coinafrique' in site_key:
        return CoinAfriqueScraper(site_config)
    elif 'expat' in site_key:
        return ExpatDakarScraper(site_config)
    elif 'jiji' in site_key:
        return JijiScraper(site_config)
    else:
        # Scraper générique pour les autres sites
        return GenericScraper(site_config)


def run_scraping() -> List[Dict]:
    """Exécuter le scraping sur tous les sites"""
    logger.info("=" * 60)
    logger.info("DÉMARRAGE DU SCRAPING")
    logger.info("=" * 60)
    
    all_products = []
    
    for site_key, site_config in SITES_CONFIG.items():
        if not site_config.get('enabled', True):
            logger.info(f"[{site_key}] Désactivé, skip...")
            continue
        
        scraper = get_scraper_for_site(site_key, site_config)
        
        try:
            products = scraper.scrape()
            all_products.extend(products)
            logger.info(f"[{site_key}] {len(products)} produits récupérés")
        except Exception as e:
            logger.error(f"[{site_key}] Erreur: {e}")
    
    logger.info(f"TOTAL: {len(all_products)} produits scrapés")
    return all_products


def generate_embeddings(products: List[Dict]) -> List[Dict]:
    """Générer les embeddings pour tous les produits"""
    logger.info("=" * 60)
    logger.info("GÉNÉRATION DES EMBEDDINGS")
    logger.info("=" * 60)
    
    texts = [p.get('nom', '') for p in products]
    
    embeddings = embedding_generator.generate_embeddings_batch(texts)
    
    for i, product in enumerate(products):
        product['embedding_vector'] = embeddings[i]
    
    logger.info(f"{len(embeddings)} embeddings générés")
    return products


def cluster_and_merge(products: List[Dict]) -> List[Dict]:
    """Regrouper et fusionner les produits similaires"""
    logger.info("=" * 60)
    logger.info("CLUSTERING ET FUSION")
    logger.info("=" * 60)
    
    merged_products, stats = product_clusterer.process_and_merge(products)
    
    logger.info(f"Résultat: {stats}")
    return merged_products


def save_to_database(products: List[Dict]):
    """Sauvegarder les produits dans Supabase"""
    logger.info("=" * 60)
    logger.info("SAUVEGARDE EN BASE DE DONNÉES")
    logger.info("=" * 60)
    
    # Récupérer les pays
    pays_map = {}
    for pays in db.get_all_pays():
        pays_map[pays['code_iso']] = pays['id']
    
    saved_count = 0
    skipped_count = 0
    
    for product in products:
        try:
            # Trouver le pays
            pays_code = product.get('pays_code', '')
            pays_id = pays_map.get(pays_code)
            
            if not pays_id:
                # Essayer avec le premier pays de la liste
                pays_list = product.get('pays_list', [])
                if pays_list:
                    for p in db.get_all_pays():
                        if p['nom'] in pays_list:
                            pays_id = p['id']
                            break
            
            # Catégoriser le produit
            categorie_name = categorize_product(product.get('nom', ''), product.get('description', ''))
            categorie = db.get_or_create_categorie(categorie_name)
            
            # Vérifier si le produit existe déjà
            if pays_id and db.check_product_exists(product['nom'], pays_id):
                skipped_count += 1
                continue
            
            # Préparer les données
            db_product = {
                'nom': product.get('nom', '')[:255],
                'description': product.get('description', ''),
                'prix_moyen': product.get('prix_moyen', 0),
                'prix_min': product.get('prix_min'),
                'prix_max': product.get('prix_max'),
                'devise': 'USD',
                'pays_id': pays_id,
                'categorie_id': categorie['id'] if categorie else None,
                'source_donnee': product.get('source_donnee', ''),
                'engagement_marche': product.get('engagement_marche', 'moyen'),
                'volume_estime': product.get('volume_estime'),
                'embedding_vector': product.get('embedding_vector')
            }
            
            # Insérer
            result = db.insert_produit_afrique(db_product)
            if result:
                saved_count += 1
            
        except Exception as e:
            logger.error(f"Erreur sauvegarde produit: {e}")
    
    logger.info(f"Sauvegarde terminée: {saved_count} insérés, {skipped_count} ignorés (doublons)")


def main():
    """Pipeline principal"""
    start_time = datetime.now()
    
    logger.info("=" * 60)
    logger.info("AFRICAN CHINA BUSINESS CHALLENGE - SCRAPER + IA")
    logger.info(f"Démarrage: {start_time}")
    logger.info("=" * 60)
    
    try:
        # 1. Scraping
        products = run_scraping()
        
        if not products:
            logger.warning("Aucun produit scrapé. Arrêt.")
            return
        
        # 2. Génération des embeddings
        products = generate_embeddings(products)
        
        # 3. Clustering et fusion
        merged_products = cluster_and_merge(products)
        
        # 4. Sauvegarde en base
        save_to_database(merged_products)
        
        # Stats finales
        end_time = datetime.now()
        duration = end_time - start_time
        
        logger.info("=" * 60)
        logger.info("TERMINÉ")
        logger.info(f"Durée: {duration}")
        logger.info(f"Produits finaux: {len(merged_products)}")
        
        # Afficher stats DB
        stats = db.get_stats()
        logger.info(f"Stats DB: {stats}")
        logger.info("=" * 60)
        
    except Exception as e:
        logger.error(f"ERREUR CRITIQUE: {e}")
        raise


if __name__ == "__main__":
    main()
