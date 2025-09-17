#!/bin/bash

echo "🚀 NestJS + Prisma Lambda Deployment"
echo "===================================="

set -e  # 遇到错误立即退出

# 1. 清理临时文件
echo "🧹 Cleaning up temporary files..."
rm -rf .aws-sam/ dist/ layers/

# 2. Build Layer (通用依赖，完全排除Prisma)
echo "📦 Building Layer with common dependencies (excluding Prisma)..."
mkdir -p layers/dependencies/nodejs

# 在 Layer 根目录创建 package.json (SAM 需要)
cat > layers/dependencies/package.json << 'EOF'
{
  "name": "lambda-layer-deps",
  "version": "1.0.0",
  "dependencies": {
    "@nestjs/common": "^11.0.1",
    "@nestjs/core": "^11.0.1",
    "@nestjs/platform-express": "^11.0.1",
    "aws-lambda": "^1.0.7",
    "reflect-metadata": "^0.2.2",
    "rxjs": "^7.8.1",
    "serverless-http": "^4.0.0"
  }
}
EOF

# 同时在 nodejs 子目录也创建一份（运行时需要）
cp layers/dependencies/package.json layers/dependencies/nodejs/

cd layers/dependencies
# 安装依赖到 nodejs 目录
npm install --prefix nodejs --production --no-package-lock

# 彻底清理所有不需要的文件（包括任何 Prisma 残留）
rm -rf nodejs/node_modules/aws-sdk* 2>/dev/null || true
rm -rf nodejs/node_modules/@prisma* 2>/dev/null || true
rm -rf nodejs/node_modules/.prisma* 2>/dev/null || true
rm -rf nodejs/node_modules/prisma* 2>/dev/null || true
find nodejs/node_modules -name "*.d.ts" -delete 2>/dev/null || true
find nodejs/node_modules -name "*.map" -delete 2>/dev/null || true

echo "📋 Layer cleanup verification:"
echo "- No Prisma in Layer: $([ ! -d nodejs/node_modules/.prisma ] && echo '✅ Clean' || echo '❌ Found Prisma')"

cd ../../

# 3. 生成 Prisma 客户端 (包含 Linux ARM64 二进制文件)
echo "📦 Generating Prisma client with Linux binaries..."
yarn prisma generate

# 4. 构建应用
echo "📦 Building NestJS application..."
yarn build

# 5. 准备应用包 (包含 Prisma)
echo "📦 Preparing application package with Prisma..."
cd dist

# 只安装 Prisma 相关依赖（其他依赖在 Layer 中）
cat > package.json << 'EOF'
{
  "name": "lambda-app",
  "version": "1.0.0",
  "dependencies": {
    "@prisma/client": "^6.16.1"
  }
}
EOF

# 安装 Prisma 客户端
npm install --production --no-package-lock

# 复制生成的 Prisma 客户端和二进制文件
echo "📦 Copying Prisma client and binaries..."
cp -r ../node_modules/.prisma ./node_modules/

# 不再将 Prisma 放到 Layer 中，遵循最佳实践

# 验证关键文件
echo "📋 Verifying Prisma files:"
echo "- @prisma/client: $([ -d node_modules/@prisma/client ] && echo '✅' || echo '❌')"
echo "- .prisma/client: $([ -d node_modules/.prisma/client ] && echo '✅' || echo '❌')"
echo "- Linux binary: $([ -f node_modules/.prisma/client/libquery_engine-linux-arm64-openssl-3.0.x.so.node ] && echo '✅' || echo '❌')"

cd ..

# 6. Build with SAM
echo "☁️ Building with SAM..."
sam build --no-cached

# 7. 修复 SAM build 后的 Prisma 问题
echo "🔧 Fixing Prisma after SAM build..."
# SAM build 会重新安装依赖，覆盖我们的 Prisma 客户端
# 需要重新复制包含 Linux 二进制文件的版本
cp -r node_modules/.prisma .aws-sam/build/NestJSFunction/node_modules/

echo "📋 Final verification in SAM build:"
echo "- Linux binary: $([ -f .aws-sam/build/NestJSFunction/node_modules/.prisma/client/libquery_engine-linux-arm64-openssl-3.0.x.so.node ] && echo '✅' || echo '❌')"

# 8. Deploy with environment variables
echo "🚀 Deploying to AWS..."

# 检查环境变量
if [ -f .env ]; then
    echo "📋 Loading environment variables from .env file..."
    source .env
    
    # 验证必需的环境变量
    if [ -z "$DATABASE_ENDPOINT" ] || [ -z "$DATABASE_USER" ] || [ -z "$DATABASE_PASSWORD" ]; then
        echo "❌ Missing required database environment variables!"
        echo "Please set DATABASE_ENDPOINT, DATABASE_USER, and DATABASE_PASSWORD in .env file"
        exit 1
    fi
    
    echo "✅ Environment variables loaded"
    echo "- DATABASE_ENDPOINT: ${DATABASE_ENDPOINT}"
    echo "- DATABASE_USER: ${DATABASE_USER}"
    echo "- GITHUB_TOKEN: $([ -n "$GITHUB_TOKEN" ] && echo 'Set' || echo 'Not set')"
else
    echo "❌ .env file not found!"
    echo "Please create .env file with required environment variables"
    echo "You can copy from .env.example and fill in your values"
    exit 1
fi

# 使用环境变量部署
echo "y" | sam deploy \
    --parameter-overrides \
    DatabaseEndpoint="$DATABASE_ENDPOINT" \
    DatabaseUser="$DATABASE_USER" \
    DatabasePassword="$DATABASE_PASSWORD" \
    GithubToken="${GITHUB_TOKEN:-''}"

echo "✅ Deployment completed!"
echo "📋 Check CloudWatch logs if there are any Prisma connection issues."