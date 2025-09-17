import { Injectable } from '@nestjs/common';

@Injectable()
export class GitHubService {
  private readonly githubToken = process.env.GITHUB_TOKEN;

  async getProfile() {
    if (!this.githubToken) {
      throw new Error('GITHUB_TOKEN environment variable is not set');
    }

    try {
      const response = await fetch('https://api.github.com/user', {
        headers: {
          Authorization: `Bearer ${this.githubToken}`,
          'User-Agent': 'mpa-aws-demo',
        },
      });

      if (!response.ok) {
        throw new Error(`GitHub API error: ${response.status}`);
      }

      const profile = await response.json();

      return {
        login: profile.login,
        name: profile.name,
        email: profile.email,
        avatar_url: profile.avatar_url,
        bio: profile.bio,
        company: profile.company,
        location: profile.location,
        public_repos: profile.public_repos,
        followers: profile.followers,
        following: profile.following,
        created_at: profile.created_at,
      };
    } catch (error) {
      throw new Error(`Failed to fetch GitHub profile: ${error.message}`);
    }
  }
}