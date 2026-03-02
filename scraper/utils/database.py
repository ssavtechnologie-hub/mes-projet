# ============================================================
# CONNEXION SUPABASE
# ============================================================

from supabase import create_client, Client
from config import SUPABASE_URL, SUPABASE_SERVICE_KEY
from typing import List, Dict, Optional
import logging

logger = logging.getLogger(__name__)

class Database:
    def __init__(self):
        self.client: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
    
    # ============================================================
    # PAYS
    # ============================================================
    def get_pays_by_code(self, code: str) -> Optional[Dict]:
        """Récupérer un pays par son code ISO"""
        result = self.client.table('pays_africains').select('*').eq('code_iso', code).execute()
        return result.data[0] if result.data else None
    
    def get_all_pays(self) -> List[Dict]:
        """Récupérer tous les pays"""
        result = self.client.table('pays_africains').select('*').execute()
        return result.data
    
    # ============================================================
    # CATÉGORIES
    # ============================================================
    def get_categorie_by_name(self, name: str) -> Optional[Dict]:
        """Récupérer une catégorie par son nom"""
        result = self.client.table('categories_produits').select('*').eq('nom', name).execute()
        return result.data[0] if result.data else None
    
    def create_categorie(self, name: str, description: str = None) -> Dict:
        """Créer une nouvelle catégorie"""
        data = {"nom": name, "description": description}
        result = self.client.table('categories_produits').insert(data).execute()
        return result.data[0]
    
    def get_or_create_categorie(self, name: str, description: str = None) -> Dict:
        """Récupérer ou créer une catégorie"""
        categorie = self.get_categorie_by_name(name)
        if not categorie:
            categorie = self.create_categorie(name, description)
        return categorie
    
    # ============================================================
    # PRODUITS AFRIQUE
    # ============================================================
    def insert_produit_afrique(self, produit: Dict) -> Optional[Dict]:
        """Insérer un nouveau produit africain"""
        try:
            result = self.client.table('produits_afrique').insert(produit).execute()
            return result.data[0] if result.data else None
        except Exception as e:
            logger.error(f"Erreur insertion produit: {e}")
            return None
    
    def insert_produits_batch(self, produits: List[Dict]) -> int:
        """Insérer plusieurs produits en batch"""
        try:
            result = self.client.table('produits_afrique').insert(produits).execute()
            return len(result.data) if result.data else 0
        except Exception as e:
            logger.error(f"Erreur insertion batch: {e}")
            return 0
    
    def update_produit_embedding(self, produit_id: str, embedding: List[float]) -> bool:
        """Mettre à jour l'embedding d'un produit"""
        try:
            self.client.table('produits_afrique').update({
                'embedding_vector': embedding
            }).eq('id', produit_id).execute()
            return True
        except Exception as e:
            logger.error(f"Erreur update embedding: {e}")
            return False
    
    def get_produits_without_embedding(self, limit: int = 100) -> List[Dict]:
        """Récupérer les produits sans embedding"""
        result = self.client.table('produits_afrique').select('*').is_('embedding_vector', 'null').limit(limit).execute()
        return result.data
    
    def get_all_produits(self) -> List[Dict]:
        """Récupérer tous les produits"""
        result = self.client.table('produits_afrique').select('*').execute()
        return result.data
    
    def search_similar_products(self, embedding: List[float], threshold: float = 0.85, limit: int = 10) -> List[Dict]:
        """Rechercher des produits similaires par embedding"""
        # Utilise la fonction RPC de Supabase pour la recherche vectorielle
        result = self.client.rpc('rechercher_produits_similaires', {
            'p_query_embedding': embedding,
            'p_limit': limit,
            'p_seuil_similarite': threshold
        }).execute()
        return result.data
    
    def check_product_exists(self, nom: str, pays_id: str) -> bool:
        """Vérifier si un produit existe déjà"""
        result = self.client.table('produits_afrique').select('id').eq('nom', nom).eq('pays_id', pays_id).execute()
        return len(result.data) > 0
    
    # ============================================================
    # STATISTIQUES
    # ============================================================
    def get_stats(self) -> Dict:
        """Récupérer les statistiques de la base"""
        produits = self.client.table('produits_afrique').select('id', count='exact').execute()
        pays = self.client.table('pays_africains').select('id', count='exact').execute()
        categories = self.client.table('categories_produits').select('id', count='exact').execute()
        
        return {
            'total_produits': produits.count,
            'total_pays': pays.count,
            'total_categories': categories.count
        }


# Instance globale
db = Database()
