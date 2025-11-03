import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { UpdateProfileDto, AddFriendDto } from './dto';
import { calculateLevel } from '../../common/utils';
import { EventEmitter2 } from '@nestjs/event-emitter';

@Injectable()
export class UsersService {
  constructor(
    private prisma: PrismaService,
    private eventEmitter: EventEmitter2,
  ) {}

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        displayName: true,
        avatarUrl: true,
        xp: true,
        coins: true,
        level: true,
        createdAt: true,
        inventory: {
          where: { equipped: true },
          include: { item: true },
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return user;
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: dto,
      select: {
        id: true,
        email: true,
        displayName: true,
        avatarUrl: true,
        xp: true,
        coins: true,
        level: true,
      },
    });

    return user;
  }

  async addXp(userId: string, amount: number) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const newXp = user.xp + amount;
    const oldLevel = user.level;
    const newLevel = calculateLevel(newXp);

    const updatedUser = await this.prisma.user.update({
      where: { id: userId },
      data: {
        xp: newXp,
        level: newLevel,
      },
    });

    // Emit level up event if level changed
    if (newLevel > oldLevel) {
      this.eventEmitter.emit('user.levelUp', {
        userId,
        oldLevel,
        newLevel,
      });
    }

    return updatedUser;
  }

  async addCoins(userId: string, amount: number) {
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: {
        coins: {
          increment: amount,
        },
      },
    });

    return user;
  }

  async deductCoins(userId: string, amount: number) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (user.coins < amount) {
      throw new BadRequestException('Insufficient coins');
    }

    const updatedUser = await this.prisma.user.update({
      where: { id: userId },
      data: {
        coins: {
          decrement: amount,
        },
      },
    });

    return updatedUser;
  }

  async sendFriendRequest(userId: string, dto: AddFriendDto) {
    if (userId === dto.friendId) {
      throw new BadRequestException('Cannot send friend request to yourself');
    }

    // Check if friend exists
    const friend = await this.prisma.user.findUnique({
      where: { id: dto.friendId },
    });

    if (!friend) {
      throw new NotFoundException('User not found');
    }

    // Check if friendship already exists
    const existingFriendship = await this.prisma.friend.findFirst({
      where: {
        OR: [
          { userId, friendId: dto.friendId },
          { userId: dto.friendId, friendId: userId },
        ],
      },
    });

    if (existingFriendship) {
      throw new ConflictException('Friend request already exists');
    }

    const friendship = await this.prisma.friend.create({
      data: {
        userId,
        friendId: dto.friendId,
        status: 'PENDING',
      },
    });

    return friendship;
  }

  async acceptFriendRequest(userId: string, friendshipId: string) {
    const friendship = await this.prisma.friend.findUnique({
      where: { id: friendshipId },
    });

    if (!friendship) {
      throw new NotFoundException('Friend request not found');
    }

    if (friendship.friendId !== userId) {
      throw new BadRequestException('You can only accept requests sent to you');
    }

    const updatedFriendship = await this.prisma.friend.update({
      where: { id: friendshipId },
      data: { status: 'ACCEPTED' },
    });

    return updatedFriendship;
  }

  async getFriends(userId: string) {
    const friendships = await this.prisma.friend.findMany({
      where: {
        OR: [{ userId }, { friendId: userId }],
        status: 'ACCEPTED',
      },
      include: {
        user: {
          select: {
            id: true,
            displayName: true,
            avatarUrl: true,
            level: true,
            xp: true,
          },
        },
      },
    });

    // Map to get the friend's data (not the current user)
    const friends = await Promise.all(
      friendships.map(async (friendship) => {
        const friendId =
          friendship.userId === userId ? friendship.friendId : friendship.userId;
        return this.prisma.user.findUnique({
          where: { id: friendId },
          select: {
            id: true,
            displayName: true,
            avatarUrl: true,
            level: true,
            xp: true,
          },
        });
      }),
    );

    return friends;
  }

  async getInventory(userId: string) {
    const inventory = await this.prisma.userItem.findMany({
      where: { userId },
      include: { item: true },
      orderBy: { unlockedAt: 'desc' },
    });

    return inventory;
  }

  async getEquippedItems(userId: string) {
    const equippedItems = await this.prisma.userItem.findMany({
      where: { userId, equipped: true },
      include: { item: true },
    });

    return equippedItems;
  }
}

