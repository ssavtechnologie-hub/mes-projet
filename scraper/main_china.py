# ============================================================
# SCRAPER FOURNISSEURS CHINOIS - Point d'entrée
# ============================================================

import logging
import sys
from datetime import datetime
from typing import List, Dict

from scrapers.alibaba_scraper import AlibabaScraper
from scrapers.aliexpress_scraper import AliExpressScraper
from scrapers.china_1688_scraper import China1688Scraper
from scrapers.made_in_china_scraper import MadeInChinaScraper
from ai.embeddings import embedding_generator
from ai.clustering import product_clusterer
from utils.database import db
from utils.proxy_manager import proxy_manager
from utils.helpers import categorize_product

# Configuration logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler(f'scraper_china_{datetime.now().strftime("%Y%m%d")}.log')
    ]
)
logger = logging.getLogger(__name__)


def load_proxies():
    """Charger les proxies"""
    logger.info("=" * 60)
    logger.info("CHARGEMENT DES PROXIES")
    logger.info("=" * 60)
    
    # Charger des proxies gratuits (pour tester)
    proxy_manager.load_free_proxies()
    
    # Tester les proxies (optionnel, prend du temps)
    # proxy_manager.test_all_proxies()
    
    stats = proxy_manager.get_stats()
    logger.info(f"Proxies disponibles: {stats['total']}")
    
    return stats['total'] > 0


def run_china_scraping() -> List[Dict]:
    """Exécuter le scraping des sites chinois"""
    logger.info("=" * 60)
    logger.info("SCRAPING FOURNISSEURS CHINOIS")
    logger.info("=" * 60)
    
    all_products = []
    
    # Liste des scrapers chinois
    scrapers = [
        ("Alibaba", AlibabaScraper()),
        ("AliExpress", AliExpressScraper()),
        ("1688", China1688Scraper()),
        ("Made-in-China", MadeInChinaScraper()),
    ]
    
    for name, scraper in scrapers:
        try:
            logger.info(f"\n{'='*40}")
            logger.info(f"Démarrage: {name}")
            logger.info(f"{'='*40}")
            
            products = scraper.scrape()
            all_products.extend(products)
            
            logger.info(f"[{name}] {len(products)} produits récupérés")
            
        except Exception as e:
            logger.error(f"[{name}] Erreur: {e}")
    
    logger.info(f"\nTOTAL FOURNISSEURS: {len(all_products)} produits")
    return all_products


def save_suppliers_to_database(products: List[Dict]):
    """Sauvegarder les fournisseurs dans Supabase"""
    logger.info("=" * 60)
    logger.info("SAUVEGARDE DES FOURNISSEURS")
    logger.info("=" * 60)
    
    saved_fournisseurs = 0
    saved_produits = 0
    
    # Regrouper par fournisseur
    fournisseurs_map = {}
    
    for product in products:
        supplier_name = product.get('nom_fournisseur')
        if not supplier_name:
            supplier_name = f"Fournisseur {product.get('source', 'Inconnu')}"
        
        if supplier_name not in fournisseurs_map:
            fournisseurs_map[supplier_name] = {
                'info': {
                    'nom': supplier_name,
                    'source': product.get('source'),
                    'verifie': product.get('verifie', False),
                    'annees_experience': product.get('annees_experience', 0),
                    'score_fiabilite': product.get('score_fiabilite', 0.5),
                    'supplier_url': product.get('supplier_url'),
                },
                'produits': []
            }
        
        fournisseurs_map[supplier_name]['produits'].append(product)
    
    # Sauvegarder chaque fournisseur et ses produits
    for supplier_name, data in fournisseurs_map.items():
        try:
            # Créer le fournisseur
            fournisseur_data = {
                'nom': data['info']['nom'][:255],
                'nom_entreprise': data['info']['nom'][:255],
                'annees_experience': data['info'].get('annees_experience', 0),
                'score_fiabilite': data['info'].get('score_fiabilite', 0.5),
                'verifie': data['info'].get('verifie', False),
                'site_web': data['info'].get('supplier_url'),
                'actif': True
            }
            
            # Insérer le fournisseur
            result = db.client.table('fournisseurs_chine').insert(fournisseur_data).execute()
            
            if result.data:
                fournisseur_id = result.data[0]['id']
                saved_fournisseurs += 1
                
                # Insérer les produits du fournisseur
                for product in data['produits'][:20]:  # Limiter à 20 produits par fournisseur
                    try:
                        # Catégoriser
                        categorie_name = categorize_product(product.get('nom_produit', ''))
                        categorie = db.get_or_create_categorie(categorie_name)
                        
                        produit_data = {
                            'fournisseur_id': fournisseur_id,
                            'categorie_id': categorie['id'] if categorie else None,
                            'nom': product.get('nom_produit', '')[:255],
                            'prix_usine': product.get('prix_usine', 0),
                            'devise': 'USD',
                            'moq': product.get('moq', 1),
                            'images': [product.get('image_url')] if product.get('image_url') else [],
                            'actif': True
                        }
                        
                        db.client.table('produits_fournisseurs').insert(produit_data).execute()
                        saved_produits += 1
                        
                    except Exception as e:
                        logger.debug(f"Erreur produit: {e}")
                
        except Exception as e:
            logger.debug(f"Erreur fournisseur {supplier_name}: {e}")
    
    logger.info(f"Sauvegarde terminée: {saved_fournisseurs} fournisseurs, {saved_produits} produits")


def main():
    """Pipeline principal scraping Chine"""
    start_time = datetime.now()
    
    logger.info("=" * 60)
    logger.info("SCRAPER FOURNISSEURS CHINOIS")
    logger.info("Alibaba + AliExpress + 1688 + Made-in-China")
    logger.info(f"Démarrage: {start_time}")
    logger.info("=" * 60)
    
    try:
        # 1. Charger les proxies
        has_proxies = load_proxies()
        if not has_proxies:
            logger.warning("⚠️  Aucun proxy disponible - Scraping direct (risque de blocage)")
        
        # 2. Scraping
        products = run_china_scraping()
        
        if not products:
            logger.warning("Aucun produit récupéré. Arrêt.")
            return
        
        # 3. Sauvegarde en base
        save_suppliers_to_database(products)
        
        # Stats finales
        end_time = datetime.now()
        duration = end_time - start_time
        
        logger.info("=" * 60)
        logger.info("TERMINÉ")
        logger.info(f"Durée: {duration}")
        logger.info("=" * 60)
        
    except Exception as e:
        logger.error(f"ERREUR CRITIQUE: {e}")
        raise


if __name__ == "__main__":
    main()
