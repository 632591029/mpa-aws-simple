import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaService } from './prisma.service';
import { NoteController } from './note.controller';
import { NoteService } from './note.service';
import { GitHubController } from './github.controller';
import { GitHubService } from './github.service';

@Module({
  imports: [],
  controllers: [AppController, NoteController, GitHubController],
  providers: [AppService, PrismaService, NoteService, GitHubService],
})
export class AppModule {}
