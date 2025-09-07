# HNSW: Fast Approximate Nearest Neighbors with Hierarchical Graphs
---
Layout: post
Title: "HNSW: Fast Approximate Nearest Neighbors with Hierarchical Graphs"
Date: 2024-02-15
Categories: [machine-learning]
Tags: [ann, vector-search, algorithms]
Github_repo: "https://github.com/statnativ/hnsw-implementation-demo"
---

# HNSW: Fast Approximate Nearest Neighbors with Hierarchical Graphs

## 1. Problem Statement
- Traditional nearest neighbor search becomes computationally expensive in high-dimensional spaces (the "curse of dimensionality")
- Exact search (like brute-force) is O(n) per query - infeasible for large datasets
- Real-world applications require fast similarity search in recommendation systems, NLP, and image retrieval

---

## 2. Solution / Approach
**Hierarchical Navigable Small World (HNSW)** combines:
- **Probabilistic skip lists** for hierarchical structure
- **Small world graphs** for efficient navigation

**Key mechanisms:**
1. *Layered structure*: Top layers have long connections, bottom layers contain all elements
2. *Greedy search*: Start at top layer, move downward while refining search
3. *Heuristic connectivity*: Balances exploration and exploitation

![HNSW Graph Structure](https://github.com/statnativ/RAG/raw/statnativ-assets/An-illustration-of-an-HNSW-Graph.png)
---
## 3. Code / Implementation

### Installation & Setup
```python
# Install required packages
!pip install hnswlib groq numpy
```

### Basic HNSW Index Construction
```python
import hnswlib
import numpy as np
from groq import Groq

# Initialize Groq client (using llama3-70b-8192 for embeddings)
client = Groq(api_key="your_groq_api_key")

def get_embeddings(texts, model="llama3-70b-8192"):
    """Generate embeddings using Groq API"""
    response = client.embeddings.create(
        model=model,
        input=texts,
        encoding_format="float"
    )
    return np.array([data.embedding for data in response.data])

# Generate sample embeddings
texts = ["machine learning", "artificial intelligence", "deep learning"]
embeddings = get_embeddings(texts)

# Initialize HNSW index
dim = len(embeddings[0])
index = hnswlib.Index(space="cosine", dim=dim)

# Build index
index.init_index(max_elements=1000, ef_construction=200, M=16)
index.add_items(embeddings, np.arange(len(embeddings)))

# Perform search
query_embedding = get_embeddings(["AI technology"])[0]
labels, distances = index.knn_query(query_embedding, k=2)
print(f"Nearest neighbors: {labels} with distances {distances}")
```

### Complete Implementation
```python
import hnswlib
import numpy as np
from groq import Groq

class HNSWVectorSearch:
    def __init__(self, model_name="llama3-70b-8192"):
        self.client = Groq(api_key="your_groq_api_key")
        self.model = model_name
        self.index = None

    def create_embeddings(self, texts: list):
        """Generate embeddings using Groq API"""
        response = self.client.embeddings.create(
            model=self.model,
            input=texts,
            encoding_format="float"
        )
        return np.array([data.embedding for data in response.data])

    def build_index(self, texts, M=16, ef_construction=200):
        """Build HNSW index from text data"""
        embeddings = self.create_embeddings(texts)
        dim = embeddings.shape[1]

        self.index = hnswlib.Index(space="cosine", dim=dim)
        self.index.init_index(
            max_elements=len(texts),
            ef_construction=ef_construction,
            M=M
        )

        self.index.add_items(embeddings, np.arange(len(texts)))
        return self

    def search(self, query, k=5):
        """Search for similar items"""
        query_emb = self.create_embeddings([query])[0]
        labels, distances = self.index.knn_query(query_emb, k=k)
        return labels, distances

# Usage example
text_corpus = [
    "machine learning algorithms",
    "deep neural networks",
    "natural language processing",
    "computer vision applications",
    "reinforcement learning frameworks"
]

searcher = HNSWVectorSearch()
searcher.build_index(text_corpus)

results = searcher.search("AI models")
print(f"Search results: {results}")
```

👉 [View complete implementation on GitHub](https://github.com/statnativ/hnsw-implementation-demo)

---

## 4. Pros and Cons

| Pros ✅ | Cons ⚠️ |
|---------|---------|
| Sublinear search time | Memory intensive for very large datasets |
| High recall accuracy | Parameter tuning required (M, ef) |
| Dynamic index support | Batch insertion better than incremental |
| Multi-threaded support | Not deterministic for exact reproduction |

---

## 5. Key Takeaways
- **Hierarchical structure** enables O(log n) search complexity
- **Balance between connectivity** and efficiency through parameters M (neighbors) and ef (search depth)
- **Ideal for medium-to-large datasets** where exact search is prohibitive
- [Read original paper](https://arxiv.org/abs/1603.09320) for theoretical details

---

## 6. Future Improvements
- Hybrid quantization techniques for memory reduction
- GPU acceleration for index building
- Automatic parameter tuning based on dataset characteristics

---

## ✅ Checklist
* [x] Title, Date, Categories, Tags filled
* [x] Problem clearly defined
* [x] Solution explained with context
* [x] Code snippet included
* [x] GitHub repo link added
* [x] Pros & Cons table completed
* [x] Takeaways section summarized

*Note: Remember to replace `your_groq_api_key` with your actual API key and ensure you have sufficient quota for embeddings generation.*
