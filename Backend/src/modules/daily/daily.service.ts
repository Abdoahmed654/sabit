import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RecordActionDto } from './dto';
import { UsersService } from '../users/users.service';

@Injectable()
export class DailyService {
  constructor(
    private prisma: PrismaService,
    private usersService: UsersService,
  ) {}

  async recordAction(userId: string, dto: RecordActionDto) {
    // Record the action
    const action = await this.prisma.dailyAction.create({
      data: {
        userId,
        actionType: dto.actionType,
        metadata: dto.metadata,
      },
    });

    // Award XP and coins based on action type
    const rewards = this.getActionRewards(dto.actionType);
    
    await Promise.all([
      this.usersService.addXp(userId, rewards.xp),
      this.usersService.addCoins(userId, rewards.coins),
    ]);

    return {
      action,
      rewards,
    };
  }

  async getUserActions(userId: string, days = 7) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    return this.prisma.dailyAction.findMany({
      where: {
        userId,
        createdAt: {
          gte: startDate,
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async getTodayActions(userId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    return this.prisma.dailyAction.findMany({
      where: {
        userId,
        createdAt: {
          gte: today,
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async getStreak(userId: string, actionType: string) {
    const actions = await this.prisma.dailyAction.findMany({
      where: {
        userId,
        actionType: actionType as any,
      },
      orderBy: {
        createdAt: 'desc',
      },
      take: 365, // Check last year
    });

    let streak = 0;
    let currentDate = new Date();
    currentDate.setHours(0, 0, 0, 0);

    for (const action of actions) {
      const actionDate = new Date(action.createdAt);
      actionDate.setHours(0, 0, 0, 0);

      const diffDays = Math.floor(
        (currentDate.getTime() - actionDate.getTime()) / (1000 * 60 * 60 * 24),
      );

      if (diffDays === streak) {
        streak++;
      } else if (diffDays > streak) {
        break;
      }
    }

    return { actionType, streak };
  }

  async getQuoteOfTheDay() {
    // In a real app, this would fetch from a database or API
    const quotes = [
      'Verily, with hardship comes ease. - Quran 94:6',
      'The best among you are those who have the best manners. - Prophet Muhammad (PBUH)',
      'Do not lose hope, nor be sad. - Quran 3:139',
      'Allah does not burden a soul beyond that it can bear. - Quran 2:286',
      'The strong person is not the one who can wrestle someone else down. The strong person is the one who can control himself when he is angry. - Prophet Muhammad (PBUH)',
    ];

    const dayOfYear = Math.floor(
      (Date.now() - new Date(new Date().getFullYear(), 0, 0).getTime()) /
        (1000 * 60 * 60 * 24),
    );

    return {
      quote: quotes[dayOfYear % quotes.length],
      date: new Date().toISOString().split('T')[0],
    };
  }

  private getActionRewards(actionType: string): { xp: number; coins: number } {
    const rewardMap = {
      PRAYER: { xp: 50, coins: 10 },
      TASBEEH: { xp: 30, coins: 5 },
      CHARITY: { xp: 100, coins: 20 },
      AZKAR: { xp: 40, coins: 8 },
    };

    return rewardMap[actionType] || { xp: 10, coins: 2 };
  }
}

