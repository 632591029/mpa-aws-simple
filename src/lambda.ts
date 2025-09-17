import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import serverlessExpress from 'serverless-http';

let server: any;

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  await app.init();
  const expressApp = app.getHttpAdapter().getInstance();
  return serverlessExpress(expressApp);
}

export const handler = async (event: any, context: any) => {
  server = server ?? (await bootstrap());
  return server(event, context);
};