-- Master Creator table (Aurora/Postgres)
CREATE TABLE creator_master (
    creator_id UUID PRIMARY KEY,
    name TEXT,
    username TEXT,
    bio TEXT,
    niche TEXT,
    profile_image TEXT,
    unified_score FLOAT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Platform Profile table
CREATE TABLE creator_platform_profile (
    platform_profile_id UUID PRIMARY KEY,
    creator_id UUID REFERENCES creator_master(creator_id),
    platform TEXT CHECK (platform IN ('instagram', 'tiktok', 'youtube', 'x')),
    platform_user_id TEXT,
    followers BIGINT,
    likes BIGINT,
    views BIGINT,
    url TEXT,
    fetched_at TIMESTAMP DEFAULT NOW()
);

-- Index for fast filtering
CREATE INDEX idx_platform_creator ON creator_platform_profile (platform, followers);

-- Embeddings table
CREATE TABLE creator_embeddings (
    creator_id UUID REFERENCES creator_master(creator_id),
    embedding VECTOR(768),         
    model_name TEXT,
    updated_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (creator_id)
);
