-- PostGIS schema for Real Real Estate Health Map
-- Run: psql -U hermes -d real_estate -f schema.sql

CREATE EXTENSION IF NOT EXISTS postgis;

-- Core county-level metrics table (normalized)
CREATE TABLE IF NOT EXISTS county_metrics (
    geoid TEXT PRIMARY KEY,           -- FIPS code
    county_name TEXT,
    state TEXT,
    geometry GEOMETRY(MultiPolygon, 4326),
    home_price_median NUMERIC,
    cost_of_living_index NUMERIC,
    flood_risk_score NUMERIC,         -- 0-1 normalized
    water_pfas_score NUMERIC,
    crime_rate NUMERIC,
    school_score_avg NUMERIC,
    cancer_rate NUMERIC,
    autism_rate NUMERIC,
    lyme_rate NUMERIC,
    parkinsons_rate NUMERIC,
    alzheimers_rate NUMERIC,
    toxic_sites_count INTEGER,
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_county_geom ON county_metrics USING GIST (geometry);

-- Detailed layers (for map rendering)
CREATE TABLE IF NOT EXISTS flood_zones (
    id SERIAL PRIMARY KEY,
    geometry GEOMETRY(MultiPolygon, 4326),
    risk_level TEXT,                  -- low, moderate, high, etc.
    county_geoid TEXT REFERENCES county_metrics(geoid)
);

-- Similar tables for other layers omitted for brevity in initial schema
-- (water_systems, schools, toxic_sites, etc.)

-- Materialized view for fast segmentation queries
CREATE MATERIALIZED VIEW IF NOT EXISTS health_scores AS
SELECT
    geoid,
    county_name,
    (COALESCE(home_price_median, 0) * -0.1 +   -- lower price better in context
     COALESCE(school_score_avg, 0) * 0.25 +
     COALESCE(water_pfas_score, 0) * 0.15 +
     (1 - COALESCE(flood_risk_score, 0)) * 0.15 +
     (1 - COALESCE(crime_rate, 0)) * 0.1 +
     (1 - COALESCE(cancer_rate, 0)) * 0.05 +
     (1 - COALESCE(autism_rate, 0)) * 0.05 +
     (1 - COALESCE(lyme_rate, 0)) * 0.05 +
     (1 - COALESCE(parkinsons_rate, 0)) * 0.05 +
     (1 - COALESCE(alzheimers_rate, 0)) * 0.05 +
     (1 - LEAST(toxic_sites_count / 10.0, 1)) * 0.05
    ) AS composite_score
FROM county_metrics;

CREATE INDEX IF NOT EXISTS idx_health_scores ON health_scores (composite_score DESC);
