# NestJS + Prisma AWS Lambda Demo

基于 NestJS 和 Prisma 的 AWS Lambda 无服务器应用演示项目。

## 🚀 特性

- **NestJS 框架**：现代化的 Node.js 后端框架
- **Prisma ORM**：类型安全的数据库访问
- **AWS Lambda**：无服务器部署
- **Lambda Layers**：优化包大小和部署速度
- **PostgreSQL**：生产级数据库

## 📦 项目结构

```
├── src/                    # 源代码
│   ├── prisma.service.ts  # Prisma 服务
│   ├── note.controller.ts # 笔记控制器
│   ├── note.service.ts    # 笔记服务
│   └── lambda.ts          # Lambda 入口
├── prisma/                # Prisma 配置
│   └── schema.prisma      # 数据库模式
├── template.yaml          # SAM 模板
└── deploy.sh              # 部署脚本
```

## 🛠️ 开发

```bash
# 安装依赖
yarn install

# 生成 Prisma 客户端
yarn prisma:generate

# 本地开发
yarn start:dev

# 构建
yarn build
```

## 🚀 部署

```bash
# 一键部署到 AWS
yarn deploy
```

## 📊 API 接口

- `GET /notes` - 获取所有笔记
- `POST /notes` - 创建新笔记
- `DELETE /notes/:id` - 删除笔记

## 🏗️ 架构说明

### Lambda Layers 策略
- **Layer**: NestJS 框架和通用依赖
- **应用包**: Prisma 客户端和业务代码

### 为什么这样设计？
1. **包大小优化**: 通用依赖放 Layer，减少应用包大小
2. **部署速度**: Layer 缓存，只需重新部署业务代码
3. **避免路径冲突**: Prisma 二进制文件单独处理

## 🔧 配置

### 环境变量
- `DATABASE_URL`: PostgreSQL 连接字符串
- `GITHUB_TOKEN`: GitHub API 令牌

### AWS 资源
- Lambda 函数 (ARM64)
- API Gateway
- VPC 和安全组
- Lambda Layer

## 📝 注意事项

1. **Prisma 不放 Layer**: 避免二进制文件路径冲突
2. **ARM64 架构**: 性能更好，成本更低
3. **VPC 配置**: 用于连接 RDS 数据库

## 🐛 故障排除

### 常见问题
- **Prisma 初始化失败**: 检查二进制文件是否正确生成
- **数据库连接超时**: 检查 VPC 和安全组配置
- **包大小超限**: 确保 Prisma 不在 Layer 中

### 查看日志
```bash
aws logs tail /aws/lambda/mpa-aws-demo-nestjs-api --follow
```