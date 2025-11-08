import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
  Inject,
  forwardRef,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { UpdateProfileDto, AddFriendDto } from './dto';
import { calculateLevel } from '../../common/utils';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { UsersGateway } from './users.gateway';

@Injectable()
export class UsersService {
  constructor(
    private prisma: PrismaService,
    private eventEmitter: EventEmitter2,
    @Inject(forwardRef(() => UsersGateway))
    private usersGateway: UsersGateway,
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
    let friendId = dto.friendId;

    // If email is provided, find user by email
    if (dto.email) {
      const friend = await this.prisma.user.findUnique({
        where: { email: dto.email },
      });

      if (!friend) {
        throw new NotFoundException('User not found with this email');
      }

      friendId = friend.id;
    }

    if (!friendId) {
      throw new BadRequestException('Either friendId or email must be provided');
    }

    if (userId === friendId) {
      throw new BadRequestException('Cannot send friend request to yourself');
    }

    // Check if friend exists
    const friend = await this.prisma.user.findUnique({
      where: { id: friendId },
    });

    if (!friend) {
      throw new NotFoundException('User not found');
    }

    // Check if friendship already exists
    const existingFriendship = await this.prisma.friend.findFirst({
      where: {
        OR: [
          { userId, friendId },
          { userId: friendId, friendId: userId },
        ],
      },
    });

    if (existingFriendship) {
      throw new ConflictException('Friend request already exists');
    }

    const friendship = await this.prisma.friend.create({
      data: {
        userId,
        friendId,
        status: 'PENDING',
      },
      include: {
        user: {
          select: {
            id: true,
            displayName: true,
            avatarUrl: true,
            email: true,
            xp: true,
            level: true,
          },
        },
      },
    });

    // Emit WebSocket event to the friend
    this.usersGateway.emitFriendRequest(friendId, {
      id: friendship.id,
      user: friendship.user,
      createdAt: friendship.createdAt,
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
      include: {
        user: {
          select: {
            id: true,
            displayName: true,
            avatarUrl: true,
            email: true,
            xp: true,
            level: true,
          },
        },
      },
    });

    // Get the friend's details (the user who accepted the request)
    const friend = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        displayName: true,
        avatarUrl: true,
        email: true,
        xp: true,
        level: true,
      },
    });

    // Create a private chat group for these two friends (if it doesn't exist)
    // Check if a private chat already exists between these two users
    const existingPrivateChat = await this.prisma.chatGroup.findFirst({
      where: {
        type: 'PRIVATE',
        AND: [
          {
            members: {
              some: {
                userId: friendship.userId,
              },
            },
          },
          {
            members: {
              some: {
                userId: userId,
              },
            },
          },
        ],
      },
    });

    // Only create if no private chat exists
    if (!existingPrivateChat) {
      const user1 = await this.prisma.user.findUnique({
        where: { id: friendship.userId },
        select: { displayName: true },
      });
      const user2 = await this.prisma.user.findUnique({
        where: { id: userId },
        select: { displayName: true },
      });

      if (user1 && user2) {
        await this.prisma.chatGroup.create({
          data: {
            name: `${user1.displayName} & ${user2.displayName}`,
            type: 'PRIVATE',
            members: {
              create: [
                { userId: friendship.userId },
                { userId: userId },
              ],
            },
          },
        });
      }
    }

    // Emit WebSocket event to the user who sent the request
    this.usersGateway.emitFriendRequestAccepted(friendship.userId, {
      id: updatedFriendship.id,
      friend,
    });

    return updatedFriendship;
  }

  async blockFriendRequest(userId: string, friendshipId: string) {
    const friendship = await this.prisma.friend.findUnique({
      where: { id: friendshipId },
    });

    if (!friendship) {
      throw new NotFoundException('Friend request not found');
    }

    if (friendship.friendId !== userId) {
      throw new BadRequestException('You can only block requests sent to you');
    }

    const updatedFriendship = await this.prisma.friend.update({
      where: { id: friendshipId },
      data: { status: 'BLOCKED' },
    });

    // Emit WebSocket event to the user who sent the request
    this.usersGateway.emitFriendRequestBlocked(friendship.userId, {
      id: updatedFriendship.id,
    });

    return updatedFriendship;
  }

  async unfriend(userId: string, friendId: string) {
    // Find the friendship (could be in either direction)
    const friendship = await this.prisma.friend.findFirst({
      where: {
        OR: [
          { userId, friendId, status: 'ACCEPTED' },
          { userId: friendId, friendId: userId, status: 'ACCEPTED' },
        ],
      },
    });

    if (!friendship) {
      throw new NotFoundException('Friendship not found');
    }

    // Delete the friendship
    await this.prisma.friend.delete({
      where: { id: friendship.id },
    });

    // Emit WebSocket event to the other user
    const otherUserId = friendship.userId === userId ? friendship.friendId : friendship.userId;
    this.usersGateway.emitFriendRemoved(otherUserId, {
      userId,
      friendshipId: friendship.id,
    });

    return { message: 'Friend removed successfully' };
  }

  async blockFriend(userId: string, friendId: string) {
    // Find the friendship (could be in either direction)
    const friendship = await this.prisma.friend.findFirst({
      where: {
        OR: [
          { userId, friendId, status: 'ACCEPTED' },
          { userId: friendId, friendId: userId, status: 'ACCEPTED' },
        ],
      },
    });

    if (!friendship) {
      throw new NotFoundException('Friendship not found');
    }

    // Update the friendship to BLOCKED
    const updatedFriendship = await this.prisma.friend.update({
      where: { id: friendship.id },
      data: { status: 'BLOCKED' },
    });

    // Emit WebSocket event to the other user
    const otherUserId = friendship.userId === userId ? friendship.friendId : friendship.userId;
    this.usersGateway.emitFriendBlocked(otherUserId, {
      userId,
      friendshipId: friendship.id,
    });

    return { message: 'Friend blocked successfully' };
  }

  async getPendingRequests(userId: string) {
    const pendingRequests = await this.prisma.friend.findMany({
      where: {
        friendId: userId,
        status: 'PENDING',
      },
      include: {
        user: {
          select: {
            id: true,
            displayName: true,
            avatarUrl: true,
            email: true,
            level: true,
            xp: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return pendingRequests;
  }

  async searchUserByEmail(email: string) {
    const user = await this.prisma.user.findUnique({
      where: { email },
      select: {
        id: true,
        displayName: true,
        avatarUrl: true,
        email: true,
        level: true,
        xp: true,
      },
    });

    if (!user) {
      throw new NotFoundException('User not found with this email');
    }

    return user;
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
            email: true,
            level: true,
            xp: true,
            coins: true,
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
            email: true,
            level: true,
            xp: true,
            coins: true,
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

