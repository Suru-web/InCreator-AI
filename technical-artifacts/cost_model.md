| Component                           | 1M creators | 50M creators  | 250M creators         | Notes                                |
| ----------------------------------- | ----------- | ------------- | --------------------- | ------------------------------------ |
| **S3 Storage (Raw Data)**           | ~$10/month  | ~$300/month   | ~$1,200/month         | Compressed JSON, lifecycle → Glacier |
| **Aurora (Postgres)**               | ~$150/month | ~$900/month   | ~$3,500/month         | Storage + IOPS + read replicas       |
| **DynamoDB**                        | ~$20/month  | ~$200/month   | ~$900/month           | Based on 10–50 writes/sec            |
| **Vector DB (Pinecone/OpenSearch)** | ~$80/month  | ~$1,200/month | ~$5,000–$12,000/month | Largest cost driver at scale         |
| **Embedding Generation**            | ~$300       | ~$15,000      | ~$60,000–$100,000     | Depends on batching + model used     |
| **ECS/Lambda Ingestion Compute**    | ~$50        | ~$500         | ~$2,000               | Queue-driven scaling                 |
| **Airflow + Orchestration**         | ~$25        | ~$50          | ~$120                 | Self-hosted or MWAA                  |
| **Monitoring (CloudWatch/Grafana)** | ~$10        | ~$30          | ~$100                 | Logs, metrics, dashboards            |


Total Estimated Monthly Cost
| Scale             | Estimated Cost  |
| ----------------- | --------------- |
| **1M creators**   | **~$350–$600**  |
| **50M creators**  | **~$18k–$25k**  |
| **250M creators** | **~$75k–$120k** |
