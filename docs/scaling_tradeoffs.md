Scaling Trade-Offs & Roadmap — Influencer Discovery System (250M+ Creators)

This document outlines the key trade-offs, MVP decisions, and the 12-month scaling roadmap for the influencer discovery system. The focus is on finding the right balance between simplicity, cost-efficiency, and long-term scalability as the system grows from 1M → 50M → 250M+ creators.

## 1. MVP (What Ships Now)

The objective is to deliver a functional, reliable, AI-driven search system quickly, without premature complexity.

✅ MVP Scope (Essential)

Multi-platform ingestion for Instagram, TikTok, YouTube, X

Basic normalization + unified creator schema

Simple identity resolution (username + embedding similarity)

Initial embeddings generation (bio text → vector)

Category/niche classification using LLM zero-shot

Vector search for “similar creators”

SQL + vector hybrid retrieval

FastAPI-based API layer

S3 for raw data

Aurora for relational profile storage

DynamoDB for rapidly changing stats

Airflow for orchestration

These features deliver a usable searchable index with AI-powered enrichment.

## 2. What Waits Until Post-PMF

Areas that add complexity or cost should be deferred until product-market fit is validated.

⏳ Post-PMF Enhancements

Full ML-based identity resolution (beyond heuristics)

Advanced bot/fake follower detection model

Behavioral embeddings from content history

Real-time ingestion or streaming pipelines

Creator audience demographic estimation

Multi-language content embeddings

Graph-based creator–creator relationships

Personalized ranking per user/customer

Deep analytics dashboards and insights

These enhancements are valuable but should not block initial launch.

## 3. Key Architectural Trade-offs
Trade-off #1: ETL via Airflow vs. Real-Time Streaming

Airflow DAGs chosen for MVP due to simplicity and cost control

Real-time ingestion (Kafka/Kinesis + Flink) postponed until needed

Reason: Most creator data changes daily or weekly, not per second.

Trade-off #2: Vector DB vs. Elasticsearch/OpenSearch

Vector DB (Pinecone/OpenSearch vector engine) chosen

More expensive but enables semantic search & similarity immediately

Can switch to self-hosted OpenSearch at scale for cost control

Trade-off #3: Aurora + DynamoDB Hybrid

Aurora for structured queries → relational, consistent

DynamoDB for fast writes → cheap, scalable, perfect for stats

Prevents Aurora from becoming write-heavy and expensive

Trade-off #4: Embeddings Model Choice

Zero-shot LLMs + embeddings for MVP

The system can later transition to:

fine-tuned embeddings,

or domain-specific vector models

This reduces cost per embedding as volume grows.

Trade-off #5: Compute Cost vs. Freshness

High-value creators refreshed daily

Long-tail refreshed weekly → huge cost savings

Only refresh embeddings every 7–30 days unless signals change

Trade-off #6: Identity Resolution

MVP uses embeddings + string similarity

Post-PMF uses ML-based multi-signal identity graph

## 4. 12-Month System Evolution
Quarter 1

Stable ingestion across 4 platforms

Unified creator database

AI enrichment pipeline

Search, filter, similarity API

Quarter 2

Improved identity resolution ML model

Add engagement anomaly detection (bot detection baseline)

Introduce caching layer for popular queries

Quarter 3

Automated refresh-priority engine

Vector DB sharding

Basic enterprise multi-tenancy

Cluster-level rate-limit controller per platform

Quarter 4

Fine-tuned niche model

Real-time scoring signals

Audience affinity modeling

Geo-language clustering

CDP integrations for high-scale customers

## 5. Scaling to 250M+ Creators

At 250M creators, the architecture evolves:

S3 → Glacier tier for older data

Pinecone/OpenSearch → sharded vector clusters

Aurora read replicas + caching for heavy search

Batch embeddings processed with GPUs

Ingestion scaled using ECS autoscaling

The pipeline remains horizontally scalable across ingestion, enrichment, and vector-serving layers.

## Conclusion

This roadmap ensures rapid delivery of a strong MVP, with a clear path to scaling the system intelligently while balancing cost, performance, and AI-driven value.