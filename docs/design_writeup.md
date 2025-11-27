
# Scalable Influencer Discovery System — Design Write-Up

_InCreator AI — Founding Engineer Assignment_


## Overview
This document describes a scalable, multi-platform influencer discovery system designed to support 250M+ creator profiles across Instagram, TikTok, YouTube, and X. The architecture emphasizes:


- Continuous ingestion and normalization of platform data
- Enrichment with embeddings, niche classification, and engagement quality analysis
- High-speed search, filtering, ranking, and creator similarity queries
- Cost-efficient embedding and refresh strategies
- Horizontal scaling across ingestion, indexing, storage, and vector similarity layers


Focus: architectural depth, performance and cost trade-offs, and AI-first extensibility (not UI/front-end concerns).


## Table of Contents
- [Overview](#overview)
- [Assumptions & Constraints](#assumptions--constraints)
- [System Architecture Overview](#system-architecture-overview)
- [Data Model & Partitioning](#data-model--partitioning)
- [Ingestion Strategy, Cadence & Scaling](#ingestion-strategy-cadence--scaling)
- [Identity Resolution Across Platforms](#identity-resolution-across-platforms)
- [AI Integration & Enrichment Pipeline](#ai-integration--enrichment-pipeline)
- [Retrieval & Ranking Flow](#retrieval--ranking-flow)
- [Monitoring, Observability & Cost](#monitoring-observability--cost)
- [Security & Multi-Tenancy](#security--multi-tenancy)
- [Trade-Offs & Scaling Roadmap](#trade-offs--scaling-roadmap)
- [Conclusion](#conclusion)
- [Appendix & Decision Notes](#appendix--decision-notes)


---


## Assumptions & Constraints


### Assumptions
- Platform access varies by provider: Instagram often requires 3rd-party APIs; TikTok combines official APIs with occasional scraping; X and YouTube have more direct APIs.
- Creator profiles are highly dynamic — frequent metric updates, content changes, and metadata drift.
- High-value creators receive more frequent refreshes than low-priority creators.
- MVP scope centers on search and discovery (not campaign execution or advanced campaign analytics).


### Constraints
- Platform API rate limits and quota constraints.
- The system must support backfills, retries, and graceful partial-failure recovery.
- Search latency target: P90 < 500ms at scale.
- Embedding generation and enrichment must be cost-efficient (batching, batching, and caching).


## System Architecture Overview


### End-to-end pipeline
```
Data Sources -> Ingestion -> Storage -> Normalization -> Identity Resolution -> AI Enrichment -> Vector DB -> Search/Ranking -> API Layer
```


### Core infrastructure
- `S3` — raw data lake and archival storage
- `SQS`/`Kinesis` — ingestion buffering and rate control
- `Lambda` / `ECS` — scalable ingestion workers and rate-limited fetchers
- `Aurora (Postgres)` — canonical relational creator profiles and metadata
- `DynamoDB` — high-write metrics and fast-changing aggregates
- `Pinecone` / `OpenSearch` (or other vector stores) — embeddings & semantic search
- `FastAPI` — serving query APIs and business logic


Each layer scales independently and communicates via well-defined interfaces (events, queues, APIs).


## Data Model & Partitioning


### Primary stores
| Store | Purpose |
|---|---|
| S3 (raw) | Immutable, versioned platform responses; source-of-truth for replays/backfills |
| Aurora (Postgres) | Canonical creator profiles, normalized metadata, niche tags, links |
| DynamoDB | High-frequency writes for time-series-like metrics & aggregates (followers, likes) |
| Vector DB (Pinecone/OpenSearch) | Embeddings for semantic searches and similarity queries |


### Partitioning & keys
- Partition by platform and shard by `creator_id` hash for horizontal scale.
- S3 paths: `s3://creator-raw/{platform}/YYYY/MM/DD/`
- DynamoDB keys: partition key `pk = creator_id`, sort key `sk = metric_type`
- Vector DB: collections/indices grouped by domain (e.g., short-form, long-form) for cost/latency optimizations


## Ingestion Strategy, Cadence & Scaling


### Scheduling & Orchestration
- `Airflow` DAGs orchestrate multi-platform ingestion and enrichment pipelines.
- Jobs run on hourly/daily cycles depending on creator priority (high-value = higher cadence).
- DAGs support retries/backoff and dependency ordering (fetch -> normalize -> persist -> enrich).


### Rate-limit Management
- Use `SQS`/`Kinesis` as a buffer and token-based throttling to respect platform quotas.
- Worker pools (Lambda/ECS) take tokens from the queue and execute platform-specific fetchers.


### Backfills
- Define dedicated DAGs for historical backfills with slower throttle rates to avoid API penalties.
- All raw backfill data consistently lands in S3, then follows the normalization/enrichment flow.


### Scaling
- Horizontal scaling via ECS Fargate or Lambda for bursts; auto-scale based on queue depth.
- GPU-enabled batch jobs (ECS/Batch) perform batched embedding generation when required.


## Identity Resolution Across Platforms


### Problem
Mapping multiple platform profiles (Instagram, TikTok, X, YouTube) to a unified creator entity.


### Matching signals
- Username similarity (Levenshtein, Jaro–Winkler)
- Bio and title embedding similarity (cosine similarity)
- Website/email matches extracted from metadata
- Cross-linked social handles and links


### Flow (asynchronous)
1. Generate candidate matches using lightweight heuristics (username, handle, external links).
2. Score candidates with a hybrid model that combines lexical and embedding signals.
3. Merge profiles if the score exceeds a threshold; otherwise, flag for manual or ML review.
4. Assign a unified `creator_id` and update canonical profile in Aurora.


This process runs asynchronously so ingestion remains fast and non-blocking.


## AI Integration & Enrichment Pipeline


### Embedding generation
- Create embeddings for bios, content topics, niche categories using models such as OpenAI, SBERT, or Cohere.
- Batch embeddings to reduce per-API cost and achieve better throughput.


### LLM Classification
- Zero-shot or prompt-based approaches for niche classification and content-type tags.
- Risk classification (NSFW/controversial) for content moderation and compliance.


### Engagement & Quality scoring
- Compute engagement rates, follower growth trends, and other health signals.
- Anomaly detection pipeline flags bots, fake followers, or inorganic spikes.


### Vector Search
- Store embeddings in the vector DB and back them with structured profile data.
- Enable similarity queries like “find creators similar to X” and semantic queries over bios/content.


## Retrieval & Ranking Flow


### Two-stage query architecture
1. Structured filtering (Aurora/DynamoDB)
   - Fast key lookups and filters on followers, platform, niche, engagement, or location.
2. Re-ranking (ML + embeddings)
   - Combine a weighted final score from engagement quality, follower size, and vector similarity.


Latency Target: P90 < 500ms achieved via caching, precomputed embeddings, and efficient primary index lookups.


## Monitoring, Observability & Cost


### Monitoring
- Airflow DAG health & task success/failures
- Queue depth/latency in `SQS`/`Kinesis`
- ECS/Lambda utilization & autoscaling performance
- Data quality metrics: missing fields, outliers, identity resolution failures, embedding distribution drift


### Cost drivers
- Embedding generation (API costs for models)
- Vector database storage and query volume
- Large ingestion bursts and storage transfer


### Optimization strategies
- Batch embeddings and compress payloads.
- Dynamic refresh cycles based on creator priority & last-update recency.
- DynamoDB TTLs for short-lived metrics and S3 Lifecycle to archive to Glacier.


## Security & Multi-Tenancy


- API security: API Gateway + JWT-based auth and scoped tokens per tenant.
- Data isolation: enterprise partitions, role-based access control, query quotas and per-tenant metering.
- PII handling: truncate/salt/hash emails, restrict sensitive exposure to authorized roles.


## Trade-Offs & Scaling Roadmap


### MVP scope
- Multi-platform ingestion
- Basic normalization
- Embeddings + classification
- Search & ranking API


### Future enhancements
- Bot/fake-follower detection ML models
- Per-user and per-enterprise personalized ranking
- Real-time ingestion (near-real-time streaming)
- Advanced analytics and geo insights


### 12-month plan
- **Q1**: Full profile index, stable ingestion, basic semantic search
- **Q2**: ML-enhanced identity resolution, engagement anomaly detection
- **Q3**: Enterprise controls & auto prioritised refresh
- **Q4**: Real-time scoring, deeper content similarity and geo insights


## Conclusion
This architecture balances scalability, cost, and AI-powered discovery. A clean separation of ingestion, normalization, enrichment, vector search, and API layers enables independent scaling, easier evolution of components, and long-term flexibility for InCreator AI.


## Appendix & Decision Notes
- Key design decisions and trade-offs are documented inline: embedding selection, vector DB choice vs. open-source alternatives, and cost/latency trade-offs of real-time vs. batch indexing.
- For small teams, begin with managed vector stores (Pinecone, etc.) and later consider self-hosted OpenSearch/FAISS variants for cost optimization.


---

_Document last updated: Nov 27, 2025_
