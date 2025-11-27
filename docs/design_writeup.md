Design Write-Up — Scalable Influencer Discovery System (250M+ Creators)

InCreator AI — Founding Engineer Assignment

1. Introduction
This document details the architecture of a multi-platform influencer discovery system designed to scale to over 250 million creator profiles across Instagram, TikTok, YouTube, and X. The system is built to:

	•	Continuously ingest and normalize creator data from diverse platforms.
	•	Enrich profiles with embeddings, niche classification, and engagement/bot analysis.
	•	Deliver high-speed search, filtering, ranking, and similarity queries at large scale.
	•	Maintain cost efficiency while supporting dynamic refresh cycles.
	•	Scale horizontally across ingestion, indexing, storage, and vector similarity layers.

The focus is on architectural depth, performance, trade-offs, and AI-first extensibility, rather than UI or frontend concerns.


2. Assumptions & Constraints
Assumptions
	•	Platform access differs: Instagram needs 3rd-party APIs; TikTok blends official APIs and scraping; X and YouTube have accessible APIs.
	•	Creator data is highly dynamic with frequent updates.
	•	High-value creators refresh more frequently.
	•	The initial scope is search and discovery, not campaign management.

Constraints
	•	Platform rate limits and API quotas.
	•	Must support backfills, retries, and partial failure recovery.
	•	Search latency target: <500ms at scale.
	•	Enrichment and embeddings must be cost-efficient.


3. System Architecture Overview
End-to-End Pipeline:
Data Sources → Ingestion → Storage → Normalization →
Identity Resolution → AI Enrichment → Vector DB →
Search / Ranking → API Layer

Core Infrastructure:
	•	S3 for raw data lake and archival storage.
	•	SQS/Kinesis for ingestion buffering and rate control.
	•	Lambda/ECS for scalable ingestion workers.
	•	Aurora (Postgres) for relational creator profiles.
	•	DynamoDB for fast-changing metrics and aggregates.
	•	Pinecone/OpenSearch for vector-based semantic search.
	•	FastAPI for serving queries.

Each layer scales independently with clear interface contracts.


4. Data Model & Partitioning
Primary Stores
	•	Raw Data (S3): Immutable, versioned platform responses.
	•	Aurora/Postgres: Unified creator profiles with metadata, niche tags, and platform links.
	•	DynamoDB: High-write metrics like followers, likes, and engagement rates with TTLs.
	•	Vector Store (Pinecone/OpenSearch): Embeddings for similarity and semantic queries.

Partitioning
	•	Partition by platform → Shard by creator_id hash.
	•	S3 path: s3://creator-raw/{platform}/YYYY/MM/DD/
	•	DynamoDB keys: pk = creator_id, sk = metric_type
	•	Vector DB collections grouped by domain (short-form, long-form).


5. Ingestion Strategy, Cadence & Scaling
Scheduling
	•	Airflow DAG orchestrates multi-platform ingestion.
	•	Hourly/daily batches based on creator priority.
	•	Handles retries, backoff, and dependency ordering.

Rate Limit Management
	•	Fetches via SQS/Kinesis with token-based throttling.
	•	Workers respect platform-specific rate tokens.

Backfills
	•	Separate DAGs for historical data.
	•	Slower throttled ingestion to avoid API issues.
	•	All raw backfill data lands in S3 first.

Scaling
	•	ECS Fargate for horizontal scalability.
	•	Queue depth drives auto-scaling.
	•	GPU-enabled batch jobs for embeddings.


6. Identity Resolution Across Platforms
Challenge: Mapping creators across TikTok, Instagram, and YouTube.

Signals for Matching:
	•	Username similarity (Levenshtein, Jaro-Winkler)
	•	Bio embeddings comparison (cosine similarity)
	•	Email/website matches
	•	Cross-linked socials in profiles

Flow:
	1.	Generate candidate matches.
	2.	Score with weighted hybrid model.
	3.	Merge if above threshold.
	4.	Assign unified creator_id.

Runs asynchronously to keep ingestion fast.


7. AI Integration & Enrichment Pipeline
Embedding Generation:
	•	Bio, content-topic, and niche embeddings via OpenAI/SBERT/Cohere.

LLM Classification:
	•	Zero-shot niche and content type categorization.
	•	Risk tagging (controversial/NSFW).

Engagement Quality Model:
	•	Calculated engagement rates.
	•	Anomaly detection for bots, fake followers, or inorganic spikes.

Vector Search:
	•	Embeddings stored in vector DB.
	•	Enables semantic queries and “find similar creators.”


8. Retrieval & Ranking Flow
Two-Stage Query:
	1.	Structured Filtering (Aurora/DynamoDB)
	◦	Follower count, platform, niche, engagement, location.
	2.	Re-Ranking (ML + Embeddings)
	◦	Weighted final score combining engagement, follower size, quality, and vector similarity.

Latency Goal: P90 < 500ms with caching and precomputed embeddings.


9. Monitoring, Observability & Cost
Monitoring:
	•	Airflow DAG health, SQS queue depth, ECS/Lambda utilization.
	•	Data quality: missing fields, outliers, failed identity resolutions, embedding drift.

Cost Drivers:
	•	Embedding generation
	•	Vector storage
	•	Large ingestion bursts

Optimization:
	•	Batch embeddings
	•	Dynamic refresh cycles
	•	DynamoDB TTLs
	•	S3 → Glacier lifecycle policies


10. Security & Multi-Tenancy
	•	API Security: API Gateway + JWT-based auth.
	•	Data Isolation: Enterprise partitions, query quotas, access logs.
	•	PII Handling: Hash emails, restrict sensitive exposure.


11. Trade-Offs & Scaling Roadmap
MVP Ships:
	•	Multi-platform ingestion
	•	Basic normalization
	•	Embeddings + classification
	•	Search & ranking API

Future Enhancements:
	•	Bot detection ML
	•	Personalized ranking
	•	Real-time ingestion
	•	Advanced analytics

12-Month Plan:
	•	Q1: Full index, stable ingestion, basic semantic search
	•	Q2: ML identity resolution, engagement anomaly detection
	•	Q3: Enterprise controls, auto-prioritized refresh
	•	Q4: Real-time scoring, deep content similarity, geo insights


12. Conclusion
This architecture balances scalability, cost, and AI-powered discovery. Clean separation of ingestion, normalization, enrichment, vector search, and API layers ensures independent scaling and long-term flexibility for InCreator AI’s roadmap.
