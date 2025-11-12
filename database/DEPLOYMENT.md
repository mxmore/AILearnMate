# Deployment Guide - AILearnMate Database

## Production Deployment Checklist

### Pre-Deployment

- [ ] Review and update `.env` with production values
- [ ] Set strong passwords for all database users
- [ ] Configure SSL/TLS for database connections
- [ ] Set up backup strategy
- [ ] Configure monitoring and alerting
- [ ] Review and adjust connection pool sizes
- [ ] Plan for database scaling strategy
- [ ] Set up VPC and network security groups (cloud)
- [ ] Configure firewall rules
- [ ] Set up database replication (if needed)

### Environment Configuration

```bash
# Production environment variables
export DB_HOST=your-production-host
export DB_PORT=5432
export DB_NAME=ailearn_mate
export DB_USER=ailearn_prod
export DB_PASSWORD=<strong-password>
export MONGO_URI=mongodb://prod-host:27017/ailearn_mate

# Security
export JWT_SECRET=<random-256-bit-secret>
export BCRYPT_ROUNDS=12

# OpenAI (for embeddings)
export OPENAI_API_KEY=<your-openai-key>

# Azure (for document processing)
export AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT=<endpoint>
export AZURE_DOCUMENT_INTELLIGENCE_KEY=<key>
```

### Deployment Options

## Option 1: Docker Compose (Single Server)

**Best for**: Small to medium deployments, staging environments

```bash
# 1. Clone repository
git clone https://github.com/mxmore/AILearnMate.git
cd AILearnMate/database

# 2. Configure environment
cp .env.example .env
nano .env  # Edit with production values

# 3. Start services
docker-compose up -d

# 4. Run migrations
docker exec -it ailearn-postgres psql -U postgres -d ailearn_mate -f /docker-entrypoint-initdb.d/01_extensions.sql
# ... continue with other migration files

# 5. Seed data (optional for production)
./migrations/seed_all.sh

# 6. Verify
docker-compose ps
docker-compose logs -f
```

**Pros**:
- Quick setup
- Easy to manage
- Good for development/staging

**Cons**:
- Single point of failure
- Limited scalability
- Manual scaling required

## Option 2: Managed Database Services (Recommended)

**Best for**: Production deployments, enterprise use

### AWS Deployment

#### RDS PostgreSQL with pgvector

```bash
# 1. Create RDS PostgreSQL 14 instance
aws rds create-db-instance \
  --db-instance-identifier ailearn-postgres \
  --db-instance-class db.t3.large \
  --engine postgres \
  --engine-version 14.7 \
  --master-username postgres \
  --master-user-password <password> \
  --allocated-storage 100 \
  --storage-type gp3 \
  --vpc-security-group-ids sg-xxx \
  --db-subnet-group-name ailearn-subnet \
  --backup-retention-period 7 \
  --preferred-backup-window "03:00-04:00" \
  --multi-az

# 2. Install pgvector extension (via custom parameter group)
# Create custom parameter group and enable shared_preload_libraries

# 3. Connect and run migrations
psql -h ailearn-postgres.xxx.rds.amazonaws.com -U postgres -d ailearn_mate
\i migrations/01_extensions.sql
# ... continue with migrations
```

#### DocumentDB (MongoDB-compatible)

```bash
# Create DocumentDB cluster
aws docdb create-db-cluster \
  --db-cluster-identifier ailearn-docdb \
  --engine docdb \
  --master-username admin \
  --master-user-password <password> \
  --vpc-security-group-ids sg-xxx \
  --db-subnet-group-name ailearn-subnet \
  --backup-retention-period 7

# Create instance
aws docdb create-db-instance \
  --db-instance-identifier ailearn-docdb-instance \
  --db-instance-class db.r5.large \
  --engine docdb \
  --db-cluster-identifier ailearn-docdb
```

#### ElastiCache Redis (Optional)

```bash
aws elasticache create-cache-cluster \
  --cache-cluster-id ailearn-redis \
  --cache-node-type cache.t3.medium \
  --engine redis \
  --num-cache-nodes 1 \
  --vpc-security-group-ids sg-xxx
```

**Estimated Monthly Costs (AWS)**:
- RDS PostgreSQL (db.t3.large, 100GB): ~$150
- DocumentDB (db.r5.large): ~$200
- ElastiCache Redis (cache.t3.medium): ~$50
- **Total**: ~$400/month

### Azure Deployment

```bash
# Create resource group
az group create --name ailearn-rg --location eastus

# Azure Database for PostgreSQL Flexible Server
az postgres flexible-server create \
  --name ailearn-postgres \
  --resource-group ailearn-rg \
  --location eastus \
  --admin-user adminuser \
  --admin-password <password> \
  --sku-name Standard_D2s_v3 \
  --tier GeneralPurpose \
  --version 14 \
  --storage-size 128 \
  --backup-retention 7

# Install pgvector extension
az postgres flexible-server parameter set \
  --name ailearn-postgres \
  --resource-group ailearn-rg \
  --name azure.extensions \
  --value vector

# Cosmos DB (MongoDB API)
az cosmosdb create \
  --name ailearn-cosmos \
  --resource-group ailearn-rg \
  --kind MongoDB \
  --server-version 4.2 \
  --default-consistency-level Session

# Azure Cache for Redis
az redis create \
  --name ailearn-redis \
  --resource-group ailearn-rg \
  --location eastus \
  --sku Basic \
  --vm-size c0
```

**Estimated Monthly Costs (Azure)**:
- PostgreSQL Flexible Server (D2s_v3, 128GB): ~$180
- Cosmos DB (400 RU/s): ~$25
- Redis Cache (Basic C0): ~$17
- **Total**: ~$222/month

### GCP Deployment

```bash
# Cloud SQL for PostgreSQL
gcloud sql instances create ailearn-postgres \
  --database-version=POSTGRES_14 \
  --tier=db-n1-standard-2 \
  --region=us-central1 \
  --backup-start-time=03:00 \
  --enable-bin-log \
  --storage-size=100GB

# MongoDB Atlas (recommended for GCP)
# Use MongoDB Atlas with GCP region

# Memorystore for Redis
gcloud redis instances create ailearn-redis \
  --size=1 \
  --region=us-central1 \
  --tier=basic
```

## Option 3: Kubernetes Deployment

**Best for**: Large scale deployments, microservices architecture

### Using Helm Charts

```yaml
# values.yaml
postgresql:
  enabled: true
  auth:
    username: postgres
    password: <password>
    database: ailearn_mate
  primary:
    persistence:
      size: 100Gi
    resources:
      requests:
        memory: 2Gi
        cpu: 1000m
  extensions:
    - pgvector

mongodb:
  enabled: true
  auth:
    rootPassword: <password>
  persistence:
    size: 50Gi
  resources:
    requests:
      memory: 2Gi
      cpu: 1000m

redis:
  enabled: true
  auth:
    password: <password>
  master:
    persistence:
      size: 10Gi
```

```bash
# Install using Helm
helm repo add bitnami https://charts.bitnami.com/bitnami

helm install ailearn-db bitnami/postgresql \
  -f values-postgresql.yaml \
  --namespace ailearn \
  --create-namespace

helm install ailearn-mongo bitnami/mongodb \
  -f values-mongodb.yaml \
  --namespace ailearn

helm install ailearn-redis bitnami/redis \
  -f values-redis.yaml \
  --namespace ailearn
```

## Post-Deployment

### 1. Run Migrations

```bash
# PostgreSQL
psql -h <prod-host> -U <user> -d ailearn_mate < migrations/run_all.sql

# MongoDB
mongosh <prod-uri> < seeds/mongodb_seeds.js
```

### 2. Verify Installation

```bash
# Check PostgreSQL
psql -h <prod-host> -U <user> -d ailearn_mate -c "SELECT COUNT(*) FROM subjects;"
psql -h <prod-host> -U <user> -d ailearn_mate -c "SELECT * FROM pg_extension WHERE extname = 'vector';"

# Check MongoDB
mongosh <prod-uri> --eval "db.ai_prompt_templates.countDocuments()"
```

### 3. Set Up Backups

#### PostgreSQL Automated Backups

```bash
#!/bin/bash
# /etc/cron.daily/ailearn-pg-backup.sh

BACKUP_DIR="/backups/postgresql"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DB_NAME="ailearn_mate"

# Create backup
pg_dump -h $DB_HOST -U $DB_USER -Fc $DB_NAME > $BACKUP_DIR/backup_$TIMESTAMP.dump

# Compress and encrypt
openssl enc -aes-256-cbc -salt -in $BACKUP_DIR/backup_$TIMESTAMP.dump \
  -out $BACKUP_DIR/backup_$TIMESTAMP.dump.enc -k $ENCRYPTION_KEY

# Upload to S3
aws s3 cp $BACKUP_DIR/backup_$TIMESTAMP.dump.enc s3://ailearn-backups/postgresql/

# Clean old local backups (keep 7 days)
find $BACKUP_DIR -name "backup_*.dump*" -mtime +7 -delete
```

#### MongoDB Automated Backups

```bash
#!/bin/bash
# /etc/cron.daily/ailearn-mongo-backup.sh

BACKUP_DIR="/backups/mongodb"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup
mongodump --uri="$MONGO_URI" --out=$BACKUP_DIR/backup_$TIMESTAMP

# Compress
tar -czf $BACKUP_DIR/backup_$TIMESTAMP.tar.gz $BACKUP_DIR/backup_$TIMESTAMP

# Upload to S3
aws s3 cp $BACKUP_DIR/backup_$TIMESTAMP.tar.gz s3://ailearn-backups/mongodb/

# Clean up
rm -rf $BACKUP_DIR/backup_$TIMESTAMP
find $BACKUP_DIR -name "backup_*.tar.gz" -mtime +7 -delete
```

### 4. Configure Monitoring

#### CloudWatch (AWS)

```bash
# Enable Enhanced Monitoring for RDS
aws rds modify-db-instance \
  --db-instance-identifier ailearn-postgres \
  --monitoring-interval 60 \
  --monitoring-role-arn arn:aws:iam::xxx:role/rds-monitoring-role

# Create CloudWatch alarms
aws cloudwatch put-metric-alarm \
  --alarm-name ailearn-db-cpu \
  --alarm-description "High CPU usage" \
  --metric-name CPUUtilization \
  --namespace AWS/RDS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=DBInstanceIdentifier,Value=ailearn-postgres
```

#### Prometheus + Grafana

```yaml
# prometheus-config.yml
scrape_configs:
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']
  
  - job_name: 'mongodb'
    static_configs:
      - targets: ['mongodb-exporter:9216']
```

### 5. Set Up Replication (High Availability)

#### PostgreSQL Streaming Replication

```bash
# On primary
ALTER SYSTEM SET wal_level = 'replica';
ALTER SYSTEM SET max_wal_senders = 3;
ALTER SYSTEM SET max_replication_slots = 3;

# Create replication user
CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD '<password>';

# On standby
pg_basebackup -h primary-host -D /var/lib/postgresql/14/main -U replicator -P
```

#### MongoDB Replica Set

```javascript
// Initialize replica set
rs.initiate({
  _id: "ailearn-rs",
  members: [
    { _id: 0, host: "mongo1:27017" },
    { _id: 1, host: "mongo2:27017" },
    { _id: 2, host: "mongo3:27017" }
  ]
})
```

## Performance Optimization

### PostgreSQL Tuning

```sql
-- Increase shared buffers (25% of RAM)
ALTER SYSTEM SET shared_buffers = '2GB';

-- Increase work memory
ALTER SYSTEM SET work_mem = '64MB';

-- Tune for SSD
ALTER SYSTEM SET random_page_cost = 1.1;

-- Enable JIT for complex queries
ALTER SYSTEM SET jit = on;

-- Increase connection pool
ALTER SYSTEM SET max_connections = 200;

-- Reload configuration
SELECT pg_reload_conf();
```

### MongoDB Tuning

```javascript
// Enable profiling for slow queries
db.setProfilingLevel(1, { slowms: 100 })

// Create optimal indexes (already in seed script)
db.user_activity_logs.createIndex({ userId: 1, timestamp: -1 })

// Set appropriate read/write concerns
db.getMongo().setReadConcern("majority")
db.getMongo().setWriteConcern({ w: "majority", j: true })
```

### Connection Pooling

```python
# Python example
pg_pool = await asyncpg.create_pool(
    min_size=10,
    max_size=50,
    max_queries=50000,
    max_inactive_connection_lifetime=300
)
```

## Security Hardening

### SSL/TLS Configuration

```bash
# PostgreSQL - Enable SSL
ALTER SYSTEM SET ssl = on;

# Generate certificates
openssl req -new -x509 -days 365 -nodes -text \
  -out server.crt -keyout server.key
chmod 600 server.key
chown postgres:postgres server.key server.crt
```

### Network Security

```bash
# PostgreSQL pg_hba.conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD
hostssl all            all             0.0.0.0/0               scram-sha-256
host    all            all             10.0.0.0/8              scram-sha-256
local   all            postgres                                peer
```

### Firewall Rules

```bash
# Allow only application servers
sudo ufw allow from 10.0.1.0/24 to any port 5432
sudo ufw allow from 10.0.1.0/24 to any port 27017
```

## Disaster Recovery

### Recovery Procedures

```bash
# PostgreSQL Point-in-Time Recovery
pg_restore -h <host> -U <user> -d ailearn_mate \
  --clean --if-exists backup.dump

# MongoDB Restore
mongorestore --uri="<uri>" \
  --drop backup/ailearn_mate
```

### Testing Recovery

```bash
# Create test environment
docker-compose -f docker-compose.test.yml up -d

# Restore backup
pg_restore -h localhost -U postgres -d ailearn_mate_test backup.dump

# Verify data integrity
psql -h localhost -U postgres -d ailearn_mate_test -c "SELECT COUNT(*) FROM users;"
```

## Scaling Strategy

### Vertical Scaling
- Start: 2 vCPU, 4GB RAM
- Medium: 4 vCPU, 16GB RAM
- Large: 8 vCPU, 32GB RAM

### Horizontal Scaling
- Read replicas for analytics
- Connection pooler (PgBouncer)
- MongoDB sharding for large collections
- Redis cluster for caching

### Monitoring Metrics

Key metrics to track:
- Active connections
- Query latency (p50, p95, p99)
- Cache hit ratio
- Disk I/O
- Replication lag
- Vector index performance

## Troubleshooting

See main README.md for common issues and solutions.

## Support

- Documentation: `/database/README.md`
- Issues: GitHub Issues
- Emergency: [Contact details]

---

**Review this checklist before going to production!**
