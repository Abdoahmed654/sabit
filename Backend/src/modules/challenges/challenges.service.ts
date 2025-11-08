import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateChallengeDto, UpdateProgressDto } from './dto';
import { EventEmitter2 } from '@nestjs/event-emitter';

@Injectable()
export class ChallengesService {
  constructor(
    private prisma: PrismaService,
    private eventEmitter: EventEmitter2,
  ) {}

  async createChallenge(dto: CreateChallengeDto) {
    const challenge = await this.prisma.challenge.create({
      data: {
        title: dto.title,
        description: dto.description,
        startAt: new Date(dto.startAt),
        endAt: new Date(dto.endAt),
        rewardXp: dto.rewardXp,
        rewardCoins: dto.rewardCoins,
        isGlobal: dto.isGlobal ?? true,
        tasks: {
          create: dto.tasks.map((task) => ({
            title: task.title,
            type: task.type,
            goalCount: task.goalCount,
            points: task.points ?? 10,
            params: task.params,
          })),
        },
      },
      include: {
        tasks: true,
      },
    });

    // Create a chat group for this challenge
    await this.prisma.chatGroup.create({
      data: {
        name: `${challenge.title} - Challenge Group`,
        type: 'CHALLENGE',
        challengeId: challenge.id,
      },
    });

    return challenge;
  }

  async getAllChallenges() {
    return this.prisma.challenge.findMany({
      where: {
        isGlobal: true,
        endAt: {
          gte: new Date(),
        },
      },
      include: {
        tasks: true,
      },
      orderBy: {
        startAt: 'desc',
      },
    });
  }

  async getChallengeById(challengeId: string) {
    const challenge = await this.prisma.challenge.findUnique({
      where: { id: challengeId },
      include: {
        tasks: true,
      },
    });

    if (!challenge) {
      throw new NotFoundException('Challenge not found');
    }

    return challenge;
  }

  async joinChallenge(userId: string, challengeId: string) {
    const challenge = await this.prisma.challenge.findUnique({
      where: { id: challengeId },
      include: { tasks: true },
    });

    if (!challenge) {
      throw new NotFoundException('Challenge not found');
    }

    // Check if already joined
    const existingProgress = await this.prisma.challengeProgress.findUnique({
      where: {
        userId_challengeId: {
          userId,
          challengeId,
        },
      },
    });

    if (existingProgress) {
      throw new ConflictException('Already joined this challenge');
    }

    // Initialize task progress
    const taskProgress = {};
    challenge.tasks.forEach((task) => {
      taskProgress[task.id] = {
        current: 0,
        goal: task.goalCount || 1,
        completed: false,
      };
    });

    const progress = await this.prisma.challengeProgress.create({
      data: {
        userId,
        challengeId,
        taskProgress,
        status: 'IN_PROGRESS',
      },
      include: {
        challenge: {
          include: {
            tasks: true,
          },
        },
      },
    });

    // Note: User is automatically part of the challenge group
    // The group was created when the challenge was created
    // No need to explicitly add users to groups - they can access it when they join the challenge

    return progress;
  }

  async updateProgress(
    userId: string,
    challengeId: string,
    dto: UpdateProgressDto,
  ) {
    const progress = await this.prisma.challengeProgress.findUnique({
      where: {
        userId_challengeId: {
          userId,
          challengeId,
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

    if (!progress) {
      throw new NotFoundException('Challenge progress not found');
    }

    if (progress.status === 'COMPLETED') {
      throw new BadRequestException('Challenge already completed');
    }

    // Find the task
    const task = progress.challenge.tasks.find((t) => t.id === dto.taskId);
    if (!task) {
      throw new NotFoundException('Task not found');
    }

    // Update task progress
    const taskProgress = progress.taskProgress as any;
    if (!taskProgress[dto.taskId]) {
      taskProgress[dto.taskId] = {
        current: 0,
        goal: task.goalCount || 1,
        completed: false,
      };
    }

    taskProgress[dto.taskId].current += dto.increment;

    // Check if task is completed
    if (taskProgress[dto.taskId].current >= taskProgress[dto.taskId].goal) {
      taskProgress[dto.taskId].completed = true;
      taskProgress[dto.taskId].current = taskProgress[dto.taskId].goal;
    }

    // Calculate points earned
    let pointsEarned = progress.pointsEarned;
    if (taskProgress[dto.taskId].completed) {
      pointsEarned += task.points;
    }

    // Check if all tasks are completed
    const allTasksCompleted = Object.values(taskProgress).every(
      (tp: any) => tp.completed,
    );

    const status = allTasksCompleted ? 'COMPLETED' : 'IN_PROGRESS';

    // Update progress
    const updatedProgress = await this.prisma.challengeProgress.update({
      where: {
        userId_challengeId: {
          userId,
          challengeId,
        },
      },
      data: {
        taskProgress,
        pointsEarned,
        status,
      },
      include: {
        challenge: {
          include: {
            tasks: true,
          },
        },
      },
    });

    // If challenge completed, award rewards
    if (status === 'COMPLETED') {
      await this.awardChallengeRewards(userId, progress.challenge);
      this.eventEmitter.emit('challenge.completed', {
        userId,
        challengeId,
        challenge: progress.challenge,
      });
    }

    return updatedProgress;
  }

  async getUserProgress(userId: string, challengeId: string) {
    const progress = await this.prisma.challengeProgress.findUnique({
      where: {
        userId_challengeId: {
          userId,
          challengeId,
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

    if (!progress) {
      throw new NotFoundException('Challenge progress not found');
    }

    return progress;
  }

  async getUserChallenges(userId: string) {
    return this.prisma.challengeProgress.findMany({
      where: { userId },
      include: {
        challenge: {
          include: {
            tasks: true,
          },
        },
      },
      orderBy: {
        updatedAt: 'desc',
      },
    });
  }

  private async awardChallengeRewards(userId: string, challenge: any) {
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        xp: {
          increment: challenge.rewardXp,
        },
        coins: {
          increment: challenge.rewardCoins,
        },
      },
    });
  }
}

