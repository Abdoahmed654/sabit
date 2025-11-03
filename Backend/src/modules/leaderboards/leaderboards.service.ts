import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class LeaderboardsService {
  constructor(private prisma: PrismaService) {}

  async getXpLeaderboard(limit = 100) {
    return this.prisma.user.findMany({
      select: {
        id: true,
        displayName: true,
        avatarUrl: true,
        xp: true,
        level: true,
      },
      orderBy: {
        xp: 'desc',
      },
      take: limit,
    });
  }

  async getCoinsLeaderboard(limit = 100) {
    return this.prisma.user.findMany({
      select: {
        id: true,
        displayName: true,
        avatarUrl: true,
        coins: true,
        level: true,
      },
      orderBy: {
        coins: 'desc',
      },
      take: limit,
    });
  }

  async getChallengeLeaderboard(challengeId: string, limit = 100) {
    return this.prisma.challengeProgress.findMany({
      where: {
        challengeId,
        status: {
          in: ['IN_PROGRESS', 'COMPLETED'],
        },
      },
      select: {
        user: {
          select: {
            id: true,
            displayName: true,
            avatarUrl: true,
            level: true,
          },
        },
        pointsEarned: true,
        status: true,
      },
      orderBy: {
        pointsEarned: 'desc',
      },
      take: limit,
    });
  }

  async getFriendsLeaderboard(userId: string, type: 'xp' | 'coins' = 'xp') {
    // Get user's friends
    const friendships = await this.prisma.friend.findMany({
      where: {
        OR: [{ userId }, { friendId: userId }],
        status: 'ACCEPTED',
      },
    });

    const friendIds = friendships.map((f) =>
      f.userId === userId ? f.friendId : f.userId,
    );

    // Include the user themselves
    friendIds.push(userId);

    const orderBy = type === 'xp' ? { xp: 'desc' as const } : { coins: 'desc' as const };

    return this.prisma.user.findMany({
      where: {
        id: {
          in: friendIds,
        },
      },
      select: {
        id: true,
        displayName: true,
        avatarUrl: true,
        xp: true,
        coins: true,
        level: true,
      },
      orderBy,
    });
  }
}

