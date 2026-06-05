# mybarbor-backend

Spring Boot 后端服务，配合 Vue3 前端使用。

## 技术栈

- Spring Boot 3.2.0
- Spring Data JPA
- Spring Data Redis
- MySQL 8.0
- Maven

## API 接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/health` | GET | 健康检查 |
| `/api/health/db` | GET | 数据库连接检查 |
| `/api/health/redis` | GET | Redis 连接检查 |
| `/api/test` | GET | API 功能测试 |
| `/api/pod-info` | GET | Pod 环境信息 |

## 构建

```bash
cd backend
mvn clean package
docker build -t myharbor.com/ops120/mybarbor-backend:1.0.0 .
```

## 部署

使用 K8s 部署清单：`backend/k8s/deployment.yaml`
