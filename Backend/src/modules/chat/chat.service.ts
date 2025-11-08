import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateGroupDto, SendMessageDto } from './dto';

@Injectable()
export class ChatService {
  constructor(private prisma: PrismaService) {}

  async createGroup(dto: CreateGroupDto) {
    return this.prisma.chatGroup.create({
      data: dto,
    });
  }

  async getAllGroups(userId?: string) {
    if (userId) {
      // Return public groups + private groups where user is a member
      return this.prisma.chatGroup.findMany({
        where: {
          OR: [
            { type: 'PUBLIC' },
            { type: 'CHALLENGE' },
            {
              type: 'PRIVATE',
              members: {
                some: {
                  userId: userId,
                },
              },
            },
          ],
        },
        include: {
          members: {
            include: {
              user: {
                select: {
                  id: true,
                  displayName: true,
                  avatarUrl: true,
                },
              },
            },
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
      });
    }

    // If no userId, return only public groups
    return this.prisma.chatGroup.findMany({
      where: {
        type: 'PUBLIC',
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async getGroupById(groupId: string) {
    const group = await this.prisma.chatGroup.findUnique({
      where: { id: groupId },
    });

    if (!group) {
      throw new NotFoundException('Group not found');
    }

    return group;
  }

  async sendMessage(userId: string, dto: SendMessageDto) {
    const group = await this.prisma.chatGroup.findUnique({
      where: { id: dto.groupId },
    });

    if (!group) {
      throw new NotFoundException('Group not found');
    }

    const message = await this.prisma.message.create({
      data: {
        groupId: dto.groupId,
        senderId: userId,
        content: dto.content,
      },
      include: {
        sender: {
          select: {
            id: true,
            displayName: true,
            avatarUrl: true,
          },
        },
      },
    });

    return message;
  }

  async getMessages(groupId: string, limit = 50) {
    const group = await this.prisma.chatGroup.findUnique({
      where: { id: groupId },
    });

    if (!group) {
      throw new NotFoundException('Group not found');
    }

    return this.prisma.message.findMany({
      where: { groupId },
      include: {
        sender: {
          select: {
            id: true,
            displayName: true,
            avatarUrl: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
      take: limit,
    });
  }

  async leaveGroup(userId: string, groupId: string) {
    const group = await this.prisma.chatGroup.findUnique({
      where: { id: groupId },
    });

    if (!group) {
      throw new NotFoundException('Group not found');
    }

    // Find the membership
    const membership = await this.prisma.groupMember.findFirst({
      where: {
        userId,
        groupId,
      },
    });

    if (!membership) {
      throw new NotFoundException('You are not a member of this group');
    }

    // Delete the membership
    await this.prisma.groupMember.delete({
      where: { id: membership.id },
    });

    return { message: 'Successfully left the group' };
  }
}

