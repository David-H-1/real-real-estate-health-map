# Real Real Estate Health Map

Full web application for finding the healthiest places to buy a home by overlaying:

- Zillow home prices and cost of living
- Flood zones (FEMA)
- Drinking water jurisdictions + PFAS/PFOA testing (EPA/state)
- Crime rates
- Education / school test scores by grade (NCES/state)
- Health metrics: cancer rates, autism, Lyme disease, Parkinson's, Alzheimer's (CDC/state)
- Toxic sites (EPA)
- Other environmental factors

**Tech stack**
- Frontend: Leaflet map + custom controls (vanilla JS initially, React later)
- Backend: FastAPI (Python) on internal port 4006
- Proxy: nginx on real.duckofdev.com (3002 public / 443)
- Data: PostGIS for geospatial queries, ETL scripts for public datasets

**Current status**
- Nginx + HTTPS configured and active
- Basic FastAPI + Leaflet skeleton deployed
- Port mapping: 3002 → 4006

**Next**
- Data pipeline for each source
- Overlap/segmentation queries
- Advanced filtering and "healthiest places" scoring
- GitHub push to David-H-1 org

Subdomain: https://real.duckofdev.com
