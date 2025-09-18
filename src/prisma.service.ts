import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  constructor() {
    super({
      // Lambda 环境优化配置
      datasources: {
        db: {
          url: process.env.DATABASE_URL,
        },
      },
    });
  }

  async onModuleInit() {
    // Lambda 环境下的连接优化
    try {
      // 在 Lambda 环境中，确保 Prisma 客户端正确初始化
      console.log('🔄 Initializing Prisma client...');
      await this.$connect();
      console.log('✅ Prisma connected successfully');
      
      // 执行一个简单的查询来验证连接
      await this.$queryRaw`SELECT 1`;
      console.log('✅ Database connection verified');

      // 🎓 学习环境：自动初始化数据库表结构
      // 注意：生产环境应该用 prisma migrate deploy
      try {
        await this.$queryRaw`SELECT 1 FROM "Note" LIMIT 1`;
        console.log('✅ Database schema exists');
      } catch (schemaError) {
        console.log('🔄 Database schema not found, creating tables...');
        try {
          // 创建 Note 表
          await this.$executeRaw`
            CREATE TABLE IF NOT EXISTS "Note" (
              "id" SERIAL NOT NULL,
              "title" TEXT NOT NULL,
              "content" TEXT NOT NULL,
              "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
              "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
              CONSTRAINT "Note_pkey" PRIMARY KEY ("id")
            )
          `;
          console.log('✅ Database schema created successfully');
        } catch (createError) {
          console.error('❌ Failed to create schema:', createError);
        }
      }
    } catch (error) {
      console.error('❌ Prisma initialization/connection failed:', error);
      // 在 Lambda 环境中，我们可能需要重试
      console.log('🔄 Retrying Prisma connection...');
      try {
        await new Promise(resolve => setTimeout(resolve, 1000)); // 等待 1 秒
        await this.$connect();
        console.log('✅ Prisma connected on retry');
      } catch (retryError) {
        console.error('❌ Prisma retry failed:', retryError);
        throw error;
      }
    }
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }

  // Lambda 环境下的健康检查
  async healthCheck() {
    try {
      await this.$queryRaw`SELECT 1`;
      return { status: 'healthy' };
    } catch (error) {
      console.error('Database health check failed:', error);
      return { status: 'unhealthy', error: error.message };
    }
  }
}