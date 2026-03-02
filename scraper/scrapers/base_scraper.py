# ============================================================
# SCRAPER DE BASE (Classe abstraite)
# ============================================================

import requests
from bs4 import BeautifulSoup
from abc import ABC, abstractmethod
from typing import List, Dict, Optional
from fake_useragent import UserAgent
import time
import logging
import random

from config import SCRAPING_CONFIG

logger = logging.getLogger(__name__)

class BaseScraper(ABC):
    """Classe de base pour tous les scrapers"""
    
    def __init__(self, site_config: Dict):
        self.site_name = site_config.get('name', 'Unknown')
        self.base_url = site_config.get('base_url', '')
        self.country = site_config.get('country', '')
        self.country_code = site_config.get('country_code', '')
        self.currency = site_config.get('currency', 'USD')
        self.enabled = site_config.get('enabled', True)
        
        self.session = requests.Session()
        self.ua = UserAgent()
        self.products = []
        
        # Configuration
        self.delay = SCRAPING_CONFIG.get('delay_between_requests', 2)
        self.timeout = SCRAPING_CONFIG.get('timeout', 30)
        self.max_retries = SCRAPING_CONFIG.get('retry_count', 3)
        self.max_products = SCRAPING_CONFIG.get('max_products_per_site', 500)
    
    def get_headers(self) -> Dict:
        """Générer des headers avec User-Agent aléatoire"""
        return {
            'User-Agent': self.ua.random,
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
        }
    
    def fetch_page(self, url: str) -> Optional[BeautifulSoup]:
        """Récupérer et parser une page"""
        for attempt in range(self.max_retries):
            try:
                logger.info(f"[{self.site_name}] Fetching: {url}")
                
                response = self.session.get(
                    url,
                    headers=self.get_headers(),
                    timeout=self.timeout
                )
                response.raise_for_status()
                
                # Délai aléatoire pour éviter le blocage
                time.sleep(self.delay + random.uniform(0, 1))
                
                return BeautifulSoup(response.content, 'lxml')
                
            except requests.RequestException as e:
                logger.warning(f"[{self.site_name}] Tentative {attempt + 1}/{self.max_retries} échouée: {e}")
                time.sleep(self.delay * (attempt + 1))
        
        logger.error(f"[{self.site_name}] Échec après {self.max_retries} tentatives: {url}")
        return None
    
    @abstractmethod
    def get_category_urls(self) -> List[str]:
        """Retourner les URLs des catégories à scraper"""
        pass
    
    @abstractmethod
    def parse_product_list(self, soup: BeautifulSoup) -> List[Dict]:
        """Parser la liste des produits d'une page"""
        pass
    
    @abstractmethod
    def parse_product_details(self, soup: BeautifulSoup, url: str) -> Optional[Dict]:
        """Parser les détails d'un produit"""
        pass
    
    def get_next_page_url(self, soup: BeautifulSoup, current_url: str) -> Optional[str]:
        """Trouver l'URL de la page suivante (à surcharger si nécessaire)"""
        return None
    
    def scrape(self) -> List[Dict]:
        """Méthode principale de scraping"""
        if not self.enabled:
            logger.info(f"[{self.site_name}] Scraper désactivé")
            return []
        
        logger.info(f"[{self.site_name}] Démarrage du scraping...")
        self.products = []
        
        category_urls = self.get_category_urls()
        
        for cat_url in category_urls:
            if len(self.products) >= self.max_products:
                break
            
            self._scrape_category(cat_url)
        
        logger.info(f"[{self.site_name}] Scraping terminé. {len(self.products)} produits récupérés.")
        return self.products
    
    def _scrape_category(self, url: str):
        """Scraper une catégorie entière"""
        page_num = 1
        max_pages = SCRAPING_CONFIG.get('max_pages_per_category', 10)
        
        while url and page_num <= max_pages:
            if len(self.products) >= self.max_products:
                break
            
            soup = self.fetch_page(url)
            if not soup:
                break
            
            products = self.parse_product_list(soup)
            
            for product in products:
                if len(self.products) >= self.max_products:
                    break
                
                # Ajouter les métadonnées
                product['source_donnee'] = self.site_name
                product['pays'] = self.country
                product['pays_code'] = self.country_code
                product['devise_origine'] = self.currency
                
                self.products.append(product)
            
            logger.info(f"[{self.site_name}] Page {page_num}: {len(products)} produits")
            
            # Page suivante
            url = self.get_next_page_url(soup, url)
            page_num += 1
