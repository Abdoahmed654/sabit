import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateBadgeDto } from './dto';
import { OnEvent } from '@nestjs/event-emitter';

@Injectable()
export class BadgesService {
  constructor(private prisma: PrismaService) {}

  async createBadge(dto: CreateBadgeDto) {
    return this.prisma.badge.create({
      data: dto,
    });
  }

  async getAllBadges() {
    return this.prisma.badge.findMany({
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async getBadgeById(badgeId: string) {
    const badge = await this.prisma.badge.findUnique({
      where: { id: badgeId },
    });

    if (!badge) {
      throw new NotFoundException('Badge not found');
    }

    return badge;
  }

  async awardBadge(userId: string, badgeId: string) {
    // Check if badge exists
    const badge = await this.prisma.badge.findUnique({
      where: { id: badgeId },
    });

    if (!badge) {
      throw new NotFoundException('Badge not found');
    }

    // Check if user already has the badge
    const existingUserBadge = await this.prisma.userBadge.findUnique({
      where: {
        userId_badgeId: {
          userId,
          badgeId,
        },
      },
    });

    if (existingUserBadge) {
      throw new ConflictException('User already has this badge');
    }

    // Award badge
    const userBadge = await this.prisma.userBadge.create({
      data: {
        userId,
        badgeId,
      },
      include: {
        badge: true,
      },
    });

    return userBadge;
  }

  async getUserBadges(userId: string) {
    return this.prisma.userBadge.findMany({
      where: { userId },
      include: {
        badge: true,
      },
      orderBy: {
        awardedAt: 'desc',
      },
    });
  }

  // Event listeners for auto-awarding badges
  @OnEvent('user.levelUp')
  async handleLevelUp(payload: {
    userId: string;
    oldLevel: number;
    newLevel: number;
  }) {
    // Award level milestone badges
    const levelMilestones = [5, 10, 25, 50, 100];
    
    if (levelMilestones.includes(payload.newLevel)) {
      const badgeName = `Level ${payload.newLevel} Master`;
      const badge = await this.prisma.badge.findFirst({
        where: { name: badgeName },
      });

      if (badge) {
        try {
          await this.awardBadge(payload.userId, badge.id);
        } catch (error) {
          // Badge already awarded or other error
          console.log(`Could not award badge: ${error.message}`);
        }
      }
    }
  }

  @OnEvent('challenge.completed')
  async handleChallengeCompleted(payload: {
    userId: string;
    challengeId: string;
    challenge: any;
  }) {
    // Award challenge completion badge if exists
    const badge = await this.prisma.badge.findFirst({
      where: {
        name: `${payload.challenge.title} Champion`,
      },
    });

    if (badge) {
      try {
        await this.awardBadge(payload.userId, badge.id);
      } catch (error) {
        console.log(`Could not award badge: ${error.message}`);
      }
    }
  }
}

