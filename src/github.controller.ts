import { Controller, Get } from '@nestjs/common';
import { GitHubService } from './github.service';

@Controller('github')
export class GitHubController {
  constructor(private readonly githubService: GitHubService) {}

  // 获取GitHub用户信息
  @Get('profile')
  async getProfile() {
    return this.githubService.getProfile();
  }
}