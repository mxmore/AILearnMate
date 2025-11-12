# AILearnMate 部署指南

本文档描述如何部署 AILearnMate 到生产环境。

## 部署方式

### 1. Docker Compose 部署（推荐）

适合中小规模部署，单服务器或小集群。

#### 前置要求
- Docker 20.10+
- Docker Compose 2.0+
- 至少 4GB RAM
- 至少 20GB 磁盘空间

#### 部署步骤

1. **准备服务器**
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 安装 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

2. **克隆代码**
```bash
git clone https://github.com/mxmore/AILearnMate.git
cd AILearnMate
```

3. **配置环境变量**
```bash
# 后端环境变量
cp backend/.env.example backend/.env
nano backend/.env

# 前端环境变量
cp frontend/.env.example frontend/.env
nano frontend/.env
```

重要配置项:
```env
# 后端 .env
ENVIRONMENT=production
DEBUG=false
SECRET_KEY=<生成强随机字符串>
JWT_SECRET_KEY=<生成强随机字符串>

POSTGRES_PASSWORD=<强密码>
MONGODB_PASSWORD=<强密码>
REDIS_PASSWORD=<强密码>

OPENAI_API_KEY=<你的 OpenAI API Key>
# 或
QWEN_API_KEY=<你的 Qwen API Key>

ALLOWED_ORIGINS=https://yourdomain.com
```

4. **生成强密钥**
```bash
# 生成 SECRET_KEY 和 JWT_SECRET_KEY
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

5. **启动服务**
```bash
docker-compose up -d
```

6. **验证部署**
```bash
# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f backend
docker-compose logs -f frontend
```

7. **设置 Nginx 反向代理**

创建 `/etc/nginx/sites-available/ailearnmate`:
```nginx
server {
    listen 80;
    server_name yourdomain.com;

    # 前端
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # 后端 API
    location /api {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # 文件上传大小限制
    client_max_body_size 50M;
}
```

启用站点:
```bash
sudo ln -s /etc/nginx/sites-available/ailearnmate /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

8. **配置 SSL (Let's Encrypt)**
```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d yourdomain.com
```

### 2. Kubernetes 部署

适合大规模生产环境，需要高可用性和自动扩缩容。

#### Helm Chart 安装

```bash
# 添加 Helm 仓库
helm repo add ailearnmate https://charts.ailearnmate.com
helm repo update

# 安装
helm install ailearnmate ailearnmate/ailearnmate \
  --namespace ailearnmate \
  --create-namespace \
  --set backend.replicas=3 \
  --set frontend.replicas=2 \
  --set postgresql.enabled=true \
  --set mongodb.enabled=true \
  --set redis.enabled=true
```

详细的 Kubernetes 部署配置请参考 `k8s/` 目录。

## 数据库管理

### PostgreSQL 备份

```bash
# 备份
docker-compose exec postgres pg_dump -U ailearnmate ailearnmate > backup.sql

# 恢复
docker-compose exec -T postgres psql -U ailearnmate ailearnmate < backup.sql
```

### MongoDB 备份

```bash
# 备份
docker-compose exec mongodb mongodump --out=/backup

# 恢复
docker-compose exec mongodb mongorestore /backup
```

## 监控

### Prometheus + Grafana

1. **启动监控服务**
```bash
docker-compose -f docker-compose.monitoring.yml up -d
```

2. **访问 Grafana**
- URL: http://localhost:3000
- 默认用户名: admin
- 默认密码: admin

3. **导入 Dashboard**
- 导入 `monitoring/grafana-dashboards/ailearnmate.json`

## 性能优化

### 1. 数据库优化

PostgreSQL:
```sql
-- 调整连接池
ALTER SYSTEM SET max_connections = 200;
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
```

MongoDB:
```js
// 创建索引
db.questions.createIndex({ "subject": 1, "difficulty": 1, "status": 1 })
db.questions.createIndex({ "knowledge_points": 1 })
```

### 2. Redis 优化

```bash
# 在 redis.conf 中
maxmemory 512mb
maxmemory-policy allkeys-lru
```

### 3. 应用层优化

- 启用 API 响应缓存
- 使用 CDN 加速静态资源
- 启用 Gzip 压缩
- 图片懒加载和优化

## 安全检查清单

- [ ] 修改所有默认密码
- [ ] 配置防火墙规则
- [ ] 启用 HTTPS
- [ ] 配置 CORS 白名单
- [ ] 设置速率限制
- [ ] 定期备份数据
- [ ] 配置日志监控和告警
- [ ] 更新依赖包到最新稳定版本
- [ ] 禁用生产环境的 debug 模式
- [ ] 配置数据库访问权限

## 故障排查

### 后端服务无法启动

```bash
# 查看日志
docker-compose logs backend

# 检查环境变量
docker-compose exec backend env | grep -i secret

# 重启服务
docker-compose restart backend
```

### 数据库连接失败

```bash
# 检查数据库状态
docker-compose ps postgres mongodb

# 测试连接
docker-compose exec backend python -c "from app.core.database import engine; engine.connect()"
```

### Celery 任务不执行

```bash
# 查看 worker 日志
docker-compose logs celery_worker

# 查看任务队列
docker-compose exec redis redis-cli LLEN celery

# 重启 worker
docker-compose restart celery_worker
```

## 升级部署

```bash
# 拉取最新代码
git pull origin main

# 重新构建镜像
docker-compose build

# 滚动更新
docker-compose up -d --no-deps --build backend
docker-compose up -d --no-deps --build frontend

# 执行数据库迁移（如果有）
docker-compose exec backend alembic upgrade head
```

## 扩展阅读

- [PostgreSQL Performance Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [MongoDB Production Notes](https://docs.mongodb.com/manual/administration/production-notes/)
- [FastAPI Deployment](https://fastapi.tiangolo.com/deployment/)
- [Next.js Deployment](https://nextjs.org/docs/deployment)
