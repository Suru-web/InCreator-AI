# 🏗️ **Scalable Influencer Discovery System — Architecture & Design**

### Founding Engineer Assignment — InCreator AI

This repository contains the system design, architecture diagram, technical artifacts, and supporting documentation for a **scalable, AI-powered influencer discovery platform** built to index and search **250M+ creators** across Instagram, TikTok, YouTube, and X.

The submission focuses on **architectural depth, trade-offs, AI-first design, and reasoning**, as requested.

---

## 🚀 **Overview**

The proposed system:

* Ingests creator data from multiple platforms
* Normalizes and merges profiles across sources
* Generates embeddings and enrichment metadata
* Stores and indexes millions of creator vectors
* Enables high-performance search, filtering, ranking, and “similar creator” recommendations
* Scales horizontally to hundreds of millions of creators

This repo contains:

* Architecture diagram
* 2–4 page design write-up
* 3 technical artifacts
* Scaling roadmap and trade-offs

---

# 📁 **Repository Structure**

```
increator-assignment/
│
├── architecture/
│   ├── architecture_diagram.png
│   ├── architecture_diagram.pdf
│   └── architecture_notes.md
│
├── docs/
│   ├── design_writeup.md
│   ├── scaling_tradeoffs.md
│   └── assumptions.md
│
├── technical-artifacts/
│   ├── airflow_dag.py
│   ├── db_schema.sql
│   └── cost_model.md
│
├── assets/
│   └── (icons, exports, reference materials)
│
└── README.md
```

---

# 🧩 **Included Components**

## **1. Architecture Diagram**

A modern, clean diagram illustrating:

* Multi-platform ingestion
* Rate-limit handling
* Normalization and data storage
* Identity resolution
* AI enrichment pipeline
* Vector search layer
* Ranking engine
* API layer
* Key AWS components (S3, Aurora, DynamoDB, ECS/Lambda, SQS/Kinesis, VectorDB)

📄 Files:
`architecture/architecture_diagram.png`
`architecture/architecture_diagram.pdf`

---

## **2. Design Write-Up (2–4 Pages)**

A detailed explanation covering:

* Data model + partitioning
* Ingestion cadence, retries, backfills
* Identity resolution
* AI-first enrichment (embeddings, LLM classification, quality scores)
* Retrieval + ranking pipeline
* Monitoring and observability
* Cost considerations
* Security + multi-tenancy
* Scaling roadmap

📄 File: `docs/design_writeup.md`

---

## **3. Technical Artifacts**

### **A. Airflow DAG**

Demonstrates ingestion → normalization → enrichment → storage orchestration.

📄 `technical-artifacts/airflow_dag.py`

---

### **B. Database Schema**

SQL + NoSQL hybrid schema for:

* `creator_master`
* `creator_platform_profile`
* `creator_embeddings`
* DynamoDB for fast-changing stats

📄 `technical-artifacts/db_schema.sql`

---

### **C. Cost Model (1M → 250M Creators)**

A practical breakdown of compute, storage, embedding, and vector index costs.

📄 `technical-artifacts/cost_model.md`

---

# 📈 **Scaling Roadmap**

The roadmap outlines:

* MVP (ingestion + enrichment + search)
* PMF enhancements (identity resolution ML, quality scoring, caching)
* Year-long evolution (refresh prioritization, advanced embeddings, enterprise features)

📄 File: `docs/scaling_tradeoffs.md`

---

# 🧠 **Technical Highlights**

* AI-first architecture using embeddings + LLM enrichment
* Horizontally scalable ingestion workers
* Multi-layered storage approach (S3 + Aurora + DynamoDB + Vector DB)
* Optimized retrieval workflow (SQL filter → ML ranking → vector similarity)
* Cost-efficient compute and storage decisions
* Modular design for future product expansion

---

# 🏁 **Conclusion**

This repository demonstrates a **scalable, AI-augmented, production-ready architecture** for discovering and ranking influencers across multiple platforms at massive scale.

It balances:

* Practical engineering
* AI-driven intelligence
* Cost-awareness
* Clear reasoning and trade-offs