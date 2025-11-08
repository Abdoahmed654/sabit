import { Injectable, BadRequestException, ConflictException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RecordActionDto, CompletePrayerDto, UpdateAzkarDto, GetPrayerTimesDto, CreateAzkarGroupDto, CreateAzkarDto, CompleteAzkarDto, CompleteFastingDto } from './dto';
import { UsersService } from '../users/users.service';
import { PrayerName, AzkarCategory } from '@prisma/client';
import axios from 'axios';

@Injectable()
export class DailyService {
  constructor(
    private prisma: PrismaService,
    private usersService: UsersService,
  ) {}

  async recordAction(userId: string, dto: RecordActionDto) {
    // Check if this is a one-time daily action
    if (dto.actionType !== 'AZKAR' && !dto.taskId) {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const existingAction = await this.prisma.dailyAction.findFirst({
        where: {
          userId,
          actionType: dto.actionType,
          createdAt: {
            gte: today,
          },
        },
      });

      if (existingAction) {
        throw new ConflictException(
          `You have already recorded ${dto.actionType} today. Try again tomorrow!`,
        );
      }
    }

    // Record the action
    const action = await this.prisma.dailyAction.create({
      data: {
        userId,
        actionType: dto.actionType,
        metadata: dto.metadata,
        taskId: dto.taskId,
        count: dto.count || 1,
      },
    });

    // Award XP and coins based on action type
    const rewards = this.getActionRewards(dto.actionType, dto.count || 1);

    await Promise.all([
      this.usersService.addXp(userId, rewards.xp),
      this.usersService.addCoins(userId, rewards.coins),
    ]);

    // If this is for a challenge task, update progress
    if (dto.taskId) {
      await this.updateChallengeTaskProgress(userId, dto.taskId, dto.count || 1);
    }

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
      { text: 'Verily, with hardship comes ease.', reference: 'Quran 94:6', author: null, category: 'QURAN' },
      { text: 'The best among you are those who have the best manners.', reference: 'Hadith', author: 'Prophet Muhammad (PBUH)', category: 'HADITH' },
      { text: 'Do not lose hope, nor be sad.', reference: 'Quran 3:139', author: null, category: 'QURAN' },
      { text: 'Allah does not burden a soul beyond that it can bear.', reference: 'Quran 2:286', author: null, category: 'QURAN' },
      { text: 'The strong person is not the one who can wrestle someone else down. The strong person is the one who can control himself when he is angry.', reference: 'Hadith', author: 'Prophet Muhammad (PBUH)', category: 'HADITH' },
    ];

    const dayOfYear = Math.floor(
      (Date.now() - new Date(new Date().getFullYear(), 0, 0).getTime()) /
        (1000 * 60 * 60 * 24),
    );

    const selectedQuote = quotes[dayOfYear % quotes.length];
    const today = new Date().toISOString().split('T')[0];

    return {
      id: `quote-${today}`,
      text: selectedQuote.text,
      author: selectedQuote.author,
      reference: selectedQuote.reference,
      category: selectedQuote.category,
      date: today,
    };
  }

  private getActionRewards(actionType: string, count: number = 1): { xp: number; coins: number } {
    const rewardMap = {
      PRAYER: { xp: 50, coins: 10 },
      TASBEEH: { xp: 30, coins: 5 },
      CHARITY: { xp: 100, coins: 20 },
      AZKAR: { xp: 5, coins: 1 }, // Per count
      QURAN_READ: { xp: 40, coins: 8 },
      DUA: { xp: 20, coins: 4 },
      FASTING: { xp: 150, coins: 30 },
    };

    const baseReward = rewardMap[actionType] || { xp: 10, coins: 2 };

    // For counter-based actions, multiply by count
    if (actionType === 'AZKAR') {
      return {
        xp: baseReward.xp * count,
        coins: baseReward.coins * count,
      };
    }

    return baseReward;
  }

  private async updateChallengeTaskProgress(userId: string, taskId: string, count: number) {
    // Find the task
    const task = await this.prisma.challengeTask.findUnique({
      where: { id: taskId },
      include: { challenge: true },
    });

    if (!task) return;

    // Find user's progress for this challenge
    const progress = await this.prisma.challengeProgress.findUnique({
      where: {
        userId_challengeId: {
          userId,
          challengeId: task.challengeId,
        },
      },
    });

    if (!progress) return;

    // Update task progress
    const taskProgress = (progress.taskProgress as any) || {};
    if (!taskProgress[taskId]) {
      taskProgress[taskId] = {
        current: 0,
        goal: task.goalCount || 1,
        completed: false,
      };
    }

    taskProgress[taskId].current += count;
    if (taskProgress[taskId].current >= taskProgress[taskId].goal) {
      taskProgress[taskId].completed = true;
    }

    // Check if all tasks are completed
    const allTasksCompleted = Object.values(taskProgress).every(
      (tp: any) => tp.completed,
    );

    await this.prisma.challengeProgress.update({
      where: { id: progress.id },
      data: {
        taskProgress,
        status: allTasksCompleted ? 'COMPLETED' : 'IN_PROGRESS',
      },
    });

    // If challenge completed, award rewards
    if (allTasksCompleted && progress.status !== 'COMPLETED') {
      await Promise.all([
        this.usersService.addXp(userId, task.challenge.rewardXp),
        this.usersService.addCoins(userId, task.challenge.rewardCoins),
      ]);
    }
  }

  // ==================== PRAYER TIMES ====================

  async getPrayerTimes(dto: GetPrayerTimesDto) {
    const date = dto.date || new Date().toISOString().split('T')[0];
    const latitude = dto.latitude || 21.3891; // Default: Mecca
    const longitude = dto.longitude || 39.8579;
    const method = dto.method || 4; // Default: Umm Al-Qura University, Makkah

    try {
      // Check if we have cached prayer times for this date and location
      const cachedTimes = await this.prisma.prayerTime.findFirst({
        where: {
          date: new Date(date),
          latitude,
          longitude,
        },
      });

      if (cachedTimes) {
        return {
          timings: {
            Fajr: cachedTimes.fajr,
            Sunrise: '06:00', // Placeholder - not stored in DB
            Dhuhr: cachedTimes.dhuhr,
            Asr: cachedTimes.asr,
            Maghrib: cachedTimes.maghrib,
            Isha: cachedTimes.isha,
          },
          date: cachedTimes.date.toISOString().split('T')[0],
          hijriDate: '', // Placeholder
        };
      }

      // Fetch from Aladhan API
      const [day, month, year] = date.split('-').reverse();
      const response = await axios.get(
        `https://api.aladhan.com/v1/timings/${day}-${month}-${year}`,
        {
          params: {
            latitude,
            longitude,
            method,
          },
        },
      );

      const timings = response.data.data.timings;
      const location = response.data.data.meta.timezone;

      // Cache the prayer times
      const prayerTime = await this.prisma.prayerTime.create({
        data: {
          date: new Date(date),
          fajr: timings.Fajr,
          dhuhr: timings.Dhuhr,
          asr: timings.Asr,
          maghrib: timings.Maghrib,
          isha: timings.Isha,
          location,
          latitude,
          longitude,
        },
      });

      return {
        timings: {
          Fajr: prayerTime.fajr,
          Sunrise: timings.Sunrise || '06:00',
          Dhuhr: prayerTime.dhuhr,
          Asr: prayerTime.asr,
          Maghrib: prayerTime.maghrib,
          Isha: prayerTime.isha,
        },
        date: prayerTime.date.toISOString().split('T')[0],
        hijriDate: response.data.data.date?.hijri?.date || '',
      };
    } catch (error) {
      // Return default times if API fails
      return {
        date: new Date(date),
        fajr: '05:00',
        dhuhr: '12:00',
        asr: '15:30',
        maghrib: '18:00',
        isha: '19:30',
        location: 'Default',
      };
    }
  }

  async completePrayer(userId: string, dto: CompletePrayerDto) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Check if prayer already completed today
    const existing = await this.prisma.prayerCompletion.findUnique({
      where: {
        userId_prayerName_date: {
          userId,
          prayerName: dto.prayerName,
          date: today,
        },
      },
    });

    if (existing) {
      throw new ConflictException(
        `You have already completed ${dto.prayerName} prayer today!`,
      );
    }

    // Create prayer completion
    const completion = await this.prisma.prayerCompletion.create({
      data: {
        userId,
        prayerName: dto.prayerName,
        date: today,
        onTime: dto.onTime || false,
      },
    });

    // Award XP and coins
    const baseReward = { xp: 50, coins: 10 };
    const onTimeBonus = dto.onTime ? { xp: 20, coins: 5 } : { xp: 0, coins: 0 };

    const totalReward = {
      xp: baseReward.xp + onTimeBonus.xp,
      coins: baseReward.coins + onTimeBonus.coins,
    };

    await Promise.all([
      this.usersService.addXp(userId, totalReward.xp),
      this.usersService.addCoins(userId, totalReward.coins),
    ]);

    return {
      completion,
      rewards: totalReward,
    };
  }

  async getTodayPrayers(userId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const completions = await this.prisma.prayerCompletion.findMany({
      where: {
        userId,
        date: today,
      },
    });

    const allPrayers = ['FAJR', 'DHUHR', 'ASR', 'MAGHRIB', 'ISHA'];
    const completed = completions.map((c) => c.prayerName);
    const remaining = allPrayers.filter((p) => !completed.includes(p as PrayerName));

    return {
      completed: completions,
      remaining,
      total: allPrayers.length,
      completedCount: completions.length,
    };
  }

  // ==================== AZKAR (OLD - DEPRECATED) ====================

  async getAzkarTemplates(category?: AzkarCategory) {
    // Deprecated: Use getAllAzkarGroups instead
    return this.getAllAzkarGroups(category);
  }

  async updateAzkarProgress(userId: string, dto: UpdateAzkarDto) {
    // Deprecated: This method is no longer used with the new Azkar system
    throw new BadRequestException('This endpoint is deprecated. Use /azkars/complete instead');
  }

  async getTodayAzkarProgress(userId: string) {
    // Deprecated: Use getUserAzkarCompletions instead
    throw new BadRequestException('This endpoint is deprecated. Use /azkars/completions instead');
  }

  // ==================== USER DAILY TASKS ====================

  async getUserDailyTasks(userId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Get user's active challenges
    const userChallenges = await this.prisma.challengeProgress.findMany({
      where: {
        userId,
        status: 'IN_PROGRESS',
        challenge: {
          endAt: {
            gte: new Date(),
          },
        },
      },
      include: {
        challenge: {
          include: {
            tasks: true,
          },
        },
      },
    });

    // Get today's completed actions
    const todayActions = await this.prisma.dailyAction.findMany({
      where: {
        userId,
        createdAt: {
          gte: today,
        },
      },
    });

    // Get today's prayer completions
    const todayPrayers = await this.prisma.prayerCompletion.findMany({
      where: {
        userId,
        date: today,
      },
    });

    // Get today's azkar completions (new system)
    const todayAzkar = await this.prisma.azkarCompletion.findMany({
      where: {
        userId,
        completedAt: {
          gte: today,
        },
      },
    });

    // Build daily tasks from challenges
    const dailyTasks: Array<{
      taskId: string;
      challengeId: string;
      challengeTitle: string;
      taskTitle: string;
      taskType: string;
      goalCount: number | null;
      currentProgress: number;
      completedToday: boolean;
      overallCompleted: boolean;
      points: number;
    }> = [];

    for (const userChallenge of userChallenges) {
      const taskProgress = (userChallenge.taskProgress as any) || {};

      for (const task of userChallenge.challenge.tasks) {
        const progress = taskProgress[task.id] || {
          current: 0,
          goal: task.goalCount || 1,
          completed: false,
        };

        // Determine if task is completed today
        let completedToday = false;

        if (task.type === 'PRAYER') {
          // Check if all 5 prayers are done
          completedToday = todayPrayers.length === 5;
        } else if (task.type === 'AZKAR') {
          // Check if specific azkar is done (from params)
          const params = task.params as any;
          const azkarId = params?.azkarId;
          if (azkarId) {
            const azkarCompletion = todayAzkar.find((a) => a.azkarId === azkarId);
            completedToday = !!azkarCompletion;
          }
        } else if (task.type === 'DAILY') {
          // Check if action is done today
          completedToday = todayActions.some((a) => a.taskId === task.id);
        }

        dailyTasks.push({
          taskId: task.id,
          challengeId: userChallenge.challenge.id,
          challengeTitle: userChallenge.challenge.title,
          taskTitle: task.title,
          taskType: task.type,
          goalCount: task.goalCount,
          currentProgress: progress.current,
          completedToday,
          overallCompleted: progress.completed,
          points: task.points,
        });
      }
    }

    return {
      dailyTasks,
      summary: {
        totalTasks: dailyTasks.length,
        completedToday: dailyTasks.filter((t) => t.completedToday).length,
        overallCompleted: dailyTasks.filter((t) => t.overallCompleted).length,
      },
    };
  }

  // ==================== NEW AZKAR GROUPS & AZKARS ====================

  async createAzkarGroup(userId: string, dto: CreateAzkarGroupDto) {
    // Check if user is admin
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { isAdmin: true },
    });

    if (!user?.isAdmin) {
      throw new ForbiddenException('Only admins can create Azkar groups');
    }

    return this.prisma.azkarGroup.create({
      data: {
        name: dto.name,
        nameAr: dto.nameAr,
        description: dto.description,
        icon: dto.icon,
        color: dto.color,
        category: dto.category,
        order: dto.order || 0,
      },
    });
  }

  async getAllAzkarGroups(category?: AzkarCategory) {
    return this.prisma.azkarGroup.findMany({
      where: category ? { category } : undefined,
      include: {
        azkars: {
          orderBy: { order: 'asc' },
        },
      },
      orderBy: { order: 'asc' },
    });
  }

  async getAzkarGroup(groupId: string) {
    const group = await this.prisma.azkarGroup.findUnique({
      where: { id: groupId },
      include: {
        azkars: {
          orderBy: { order: 'asc' },
        },
      },
    });

    if (!group) {
      throw new NotFoundException('Azkar group not found');
    }

    return group;
  }

  async createAzkar(userId: string, dto: CreateAzkarDto) {
    // Check if user is admin
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { isAdmin: true },
    });

    if (!user?.isAdmin) {
      throw new ForbiddenException('Only admins can create Azkars');
    }

    // Verify group exists
    const group = await this.prisma.azkarGroup.findUnique({
      where: { id: dto.groupId },
    });

    if (!group) {
      throw new NotFoundException('Azkar group not found');
    }

    return this.prisma.azkar.create({
      data: {
        groupId: dto.groupId,
        title: dto.title,
        titleAr: dto.titleAr,
        arabicText: dto.arabicText,
        translation: dto.translation,
        transliteration: dto.transliteration,
        targetCount: dto.targetCount,
        xpReward: dto.xpReward,
        coinsReward: dto.coinsReward,
        order: dto.order || 0,
        reference: dto.reference,
      },
    });
  }

  async completeAzkar(userId: string, dto: CompleteAzkarDto) {
    // Check if azkar exists
    const azkar = await this.prisma.azkar.findUnique({
      where: { id: dto.azkarId },
    });

    if (!azkar) {
      throw new NotFoundException('Azkar not found');
    }

    // Get today's date (normalized to start of day)
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Check if user has already completed this azkar today
    const existingCompletion = await this.prisma.azkarCompletion.findUnique({
      where: {
        userId_azkarId_date: {
          userId,
          azkarId: dto.azkarId,
          date: today,
        },
      },
    });

    if (existingCompletion) {
      throw new ConflictException('You have already completed this Azkar today');
    }

    // Create completion record
    const completion = await this.prisma.azkarCompletion.create({
      data: {
        userId,
        azkarId: dto.azkarId,
        date: today,
        xpEarned: azkar.xpReward,
        coinsEarned: azkar.coinsReward,
      },
    });

    // Award XP and coins
    await Promise.all([
      this.usersService.addXp(userId, azkar.xpReward),
      this.usersService.addCoins(userId, azkar.coinsReward),
    ]);

    return {
      completion,
      rewards: {
        xp: azkar.xpReward,
        coins: azkar.coinsReward,
      },
    };
  }

  async getUserAzkarCompletions(userId: string, groupId?: string) {
    // Get today's date (normalized to start of day)
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    return this.prisma.azkarCompletion.findMany({
      where: {
        userId,
        date: today, // Only return today's completions
        ...(groupId && {
          azkar: {
            groupId,
          },
        }),
      },
      include: {
        azkar: {
          include: {
            group: true,
          },
        },
      },
      orderBy: {
        completedAt: 'desc',
      },
    });
  }

  // ==================== FASTING ====================

  async completeFasting(userId: string, dto: CompleteFastingDto) {
    const now = new Date();
    const currentHour = now.getHours();

    // Check if current time is between Maghrib (18:00) and Fajr (05:00)
    // Simplified check: allow submission between 18:00 and 23:59, or 00:00 and 05:00
    const isValidTime = currentHour >= 18 || currentHour < 5;

    if (!isValidTime) {
      throw new BadRequestException(
        'Fasting can only be submitted between Maghrib and Fajr (6:00 PM - 5:00 AM)',
      );
    }

    // Get today's date (normalized)
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Check if user has already completed fasting today
    const existingFasting = await this.prisma.fastingCompletion.findUnique({
      where: {
        userId_date: {
          userId,
          date: today,
        },
      },
    });

    if (existingFasting) {
      throw new ConflictException('You have already recorded fasting for today');
    }

    // Determine rewards based on fasting type
    const xpReward = dto.fastingType === 'RAMADAN' ? 150 : 100;
    const coinsReward = dto.fastingType === 'RAMADAN' ? 75 : 50;

    // Create fasting completion
    const completion = await this.prisma.fastingCompletion.create({
      data: {
        userId,
        date: today,
        fastingType: dto.fastingType || 'VOLUNTARY',
        xpEarned: xpReward,
        coinsEarned: coinsReward,
      },
    });

    // Award XP and coins
    await Promise.all([
      this.usersService.addXp(userId, xpReward),
      this.usersService.addCoins(userId, coinsReward),
    ]);

    return {
      completion,
      rewards: {
        xp: xpReward,
        coins: coinsReward,
      },
    };
  }

  async getUserFastingHistory(userId: string, days = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    startDate.setHours(0, 0, 0, 0);

    return this.prisma.fastingCompletion.findMany({
      where: {
        userId,
        date: {
          gte: startDate,
        },
      },
      orderBy: {
        date: 'desc',
      },
    });
  }

  async getTodayFastingStatus(userId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const completion = await this.prisma.fastingCompletion.findUnique({
      where: {
        userId_date: {
          userId,
          date: today,
        },
      },
    });

    const now = new Date();
    const currentHour = now.getHours();
    const canSubmit = currentHour >= 18 || currentHour < 5;

    return {
      completed: !!completion,
      completion,
      canSubmit,
      currentTime: now.toISOString(),
    };
  }
}