# ============================================================
# MODULE EMBEDDINGS - IA pour similarité produits
# ============================================================

from sentence_transformers import SentenceTransformer
from typing import List, Dict, Optional
import numpy as np
import logging

from config import AI_CONFIG

logger = logging.getLogger(__name__)

class EmbeddingGenerator:
    """Générateur d'embeddings pour les produits"""
    
    def __init__(self):
        self.model_name = AI_CONFIG.get('embedding_model', 'sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2')
        self.model = None
        self.dimension = AI_CONFIG.get('embedding_dimension', 384)
    
    def load_model(self):
        """Charger le modèle Sentence Transformer"""
        if self.model is None:
            logger.info(f"Chargement du modèle: {self.model_name}")
            self.model = SentenceTransformer(self.model_name)
            logger.info("Modèle chargé avec succès")
    
    def generate_embedding(self, text: str) -> List[float]:
        """Générer un embedding pour un texte"""
        self.load_model()
        embedding = self.model.encode(text, convert_to_numpy=True)
        return embedding.tolist()
    
    def generate_embeddings_batch(self, texts: List[str], batch_size: int = 100) -> List[List[float]]:
        """Générer des embeddings pour plusieurs textes"""
        self.load_model()
        
        all_embeddings = []
        
        for i in range(0, len(texts), batch_size):
            batch = texts[i:i + batch_size]
            logger.info(f"Traitement batch {i//batch_size + 1}/{(len(texts)-1)//batch_size + 1}")
            
            embeddings = self.model.encode(batch, convert_to_numpy=True, show_progress_bar=True)
            all_embeddings.extend(embeddings.tolist())
        
        return all_embeddings
    
    def generate_product_embedding(self, product: Dict) -> List[float]:
        """Générer un embedding pour un produit (nom + description)"""
        # Combiner nom et autres informations pertinentes
        text_parts = [product.get('nom', '')]
        
        if product.get('description'):
            text_parts.append(product['description'])
        
        if product.get('categorie'):
            text_parts.append(product['categorie'])
        
        combined_text = ' '.join(filter(None, text_parts))
        return self.generate_embedding(combined_text)
    
    def calculate_similarity(self, embedding1: List[float], embedding2: List[float]) -> float:
        """Calculer la similarité cosinus entre deux embeddings"""
        vec1 = np.array(embedding1)
        vec2 = np.array(embedding2)
        
        dot_product = np.dot(vec1, vec2)
        norm1 = np.linalg.norm(vec1)
        norm2 = np.linalg.norm(vec2)
        
        if norm1 == 0 or norm2 == 0:
            return 0.0
        
        return float(dot_product / (norm1 * norm2))
    
    def find_similar_products(self, query_embedding: List[float], 
                             product_embeddings: List[Dict],
                             threshold: float = 0.85,
                             top_k: int = 10) -> List[Dict]:
        """Trouver les produits similaires"""
        similarities = []
        
        for product in product_embeddings:
            if product.get('embedding'):
                similarity = self.calculate_similarity(query_embedding, product['embedding'])
                if similarity >= threshold:
                    similarities.append({
                        'product': product,
                        'similarity': similarity
                    })
        
        # Trier par similarité décroissante
        similarities.sort(key=lambda x: x['similarity'], reverse=True)
        
        return similarities[:top_k]


# Instance globale
embedding_generator = EmbeddingGenerator()
