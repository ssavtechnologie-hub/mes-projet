# ============================================================
# MODULE CLUSTERING - Regroupement de produits similaires
# ============================================================

from sklearn.cluster import DBSCAN, KMeans
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np
from typing import List, Dict, Tuple
import logging

from config import AI_CONFIG

logger = logging.getLogger(__name__)

class ProductClusterer:
    """Regroupement intelligent de produits similaires"""
    
    def __init__(self):
        self.similarity_threshold = AI_CONFIG.get('similarity_threshold', 0.85)
        self.min_samples = AI_CONFIG.get('clustering_min_samples', 2)
    
    def cluster_products_dbscan(self, products: List[Dict]) -> Dict[int, List[Dict]]:
        """
        Regrouper les produits similaires avec DBSCAN
        
        Retourne un dictionnaire {cluster_id: [liste de produits]}
        cluster_id = -1 pour les produits non regroupés
        """
        if not products:
            return {}
        
        # Extraire les embeddings
        embeddings = []
        valid_products = []
        
        for product in products:
            if product.get('embedding_vector'):
                embeddings.append(product['embedding_vector'])
                valid_products.append(product)
        
        if len(embeddings) < 2:
            return {0: valid_products}
        
        logger.info(f"Clustering de {len(embeddings)} produits...")
        
        # Convertir en array numpy
        X = np.array(embeddings)
        
        # Calculer la matrice de distance (1 - similarité cosinus)
        similarity_matrix = cosine_similarity(X)
        distance_matrix = 1 - similarity_matrix
        
        # DBSCAN avec distance précalculée
        eps = 1 - self.similarity_threshold  # Convertir seuil de similarité en distance
        clustering = DBSCAN(eps=eps, min_samples=self.min_samples, metric='precomputed')
        labels = clustering.fit_predict(distance_matrix)
        
        # Regrouper par cluster
        clusters = {}
        for idx, label in enumerate(labels):
            if label not in clusters:
                clusters[label] = []
            clusters[label].append(valid_products[idx])
        
        n_clusters = len([l for l in clusters.keys() if l != -1])
        n_noise = len(clusters.get(-1, []))
        
        logger.info(f"Clustering terminé: {n_clusters} clusters, {n_noise} produits isolés")
        
        return clusters
    
    def merge_similar_products(self, cluster: List[Dict]) -> Dict:
        """
        Fusionner un groupe de produits similaires en un seul
        
        Stratégie:
        - Nom: le plus court ou le plus commun
        - Prix: moyenne des prix
        - Prix min/max: min et max du groupe
        """
        if not cluster:
            return None
        
        if len(cluster) == 1:
            return cluster[0]
        
        # Nom: prendre le plus court (généralement le plus générique)
        names = [p.get('nom', '') for p in cluster]
        merged_name = min(names, key=len) if names else 'Produit'
        
        # Prix
        prices = [p.get('prix_moyen', 0) for p in cluster if p.get('prix_moyen')]
        avg_price = sum(prices) / len(prices) if prices else 0
        
        min_prices = [p.get('prix_min', p.get('prix_moyen', 0)) for p in cluster]
        max_prices = [p.get('prix_max', p.get('prix_moyen', 0)) for p in cluster]
        
        # Pays (tous les pays du groupe)
        countries = list(set(p.get('pays', '') for p in cluster if p.get('pays')))
        
        # Sources
        sources = list(set(p.get('source_donnee', '') for p in cluster if p.get('source_donnee')))
        
        # Engagement: prendre le plus fort
        engagements = [p.get('engagement_marche', 'moyen') for p in cluster]
        engagement_priority = {'fort': 3, 'moyen': 2, 'faible': 1}
        best_engagement = max(engagements, key=lambda x: engagement_priority.get(x, 0))
        
        # Volume estimé: somme
        volumes = [p.get('volume_estime', 0) or 0 for p in cluster]
        total_volume = sum(volumes) if any(volumes) else None
        
        return {
            'nom': merged_name,
            'prix_moyen': round(avg_price, 2),
            'prix_min': round(min(min_prices), 2) if min_prices else avg_price,
            'prix_max': round(max(max_prices), 2) if max_prices else avg_price,
            'devise': 'USD',
            'pays_list': countries,
            'sources': sources,
            'engagement_marche': best_engagement,
            'volume_estime': total_volume,
            'nombre_sources': len(cluster),
            'produits_originaux': cluster
        }
    
    def process_and_merge(self, products: List[Dict]) -> Tuple[List[Dict], Dict]:
        """
        Pipeline complet: clustering + fusion
        
        Retourne:
        - Liste des produits fusionnés
        - Statistiques
        """
        # Clustering
        clusters = self.cluster_products_dbscan(products)
        
        merged_products = []
        stats = {
            'total_input': len(products),
            'total_clusters': 0,
            'total_merged': 0,
            'total_isolated': 0
        }
        
        for cluster_id, cluster_products in clusters.items():
            if cluster_id == -1:
                # Produits isolés: garder tels quels
                merged_products.extend(cluster_products)
                stats['total_isolated'] += len(cluster_products)
            else:
                # Fusionner le cluster
                merged = self.merge_similar_products(cluster_products)
                if merged:
                    merged_products.append(merged)
                    stats['total_clusters'] += 1
        
        stats['total_merged'] = len(merged_products)
        
        logger.info(f"Fusion terminée: {stats['total_input']} -> {stats['total_merged']} produits")
        
        return merged_products, stats
    
    def find_duplicates(self, products: List[Dict], threshold: float = 0.95) -> List[Tuple[int, int, float]]:
        """
        Trouver les doublons potentiels (similarité très élevée)
        
        Retourne une liste de tuples (index1, index2, similarité)
        """
        if len(products) < 2:
            return []
        
        embeddings = [p.get('embedding_vector') for p in products if p.get('embedding_vector')]
        
        if len(embeddings) < 2:
            return []
        
        X = np.array(embeddings)
        similarity_matrix = cosine_similarity(X)
        
        duplicates = []
        n = len(similarity_matrix)
        
        for i in range(n):
            for j in range(i + 1, n):
                if similarity_matrix[i][j] >= threshold:
                    duplicates.append((i, j, similarity_matrix[i][j]))
        
        return duplicates


# Instance globale
product_clusterer = ProductClusterer()
