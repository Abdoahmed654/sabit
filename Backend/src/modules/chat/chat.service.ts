import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateGroupDto, SendMessageDto } from './dto';
import { GroupType } from '@prisma/client';

@Injectable()
export class ChatService {
  constructor(private prisma: PrismaService) {}

  async createGroup(userId: string, dto: CreateGroupDto & { memberIds?: string[] }) {
    const memberIds = dto.memberIds || [];
    // Always include the creator as a member and dedupe member IDs to avoid unique constraint errors
    const uniqueMemberIds = Array.from(new Set([userId, ...memberIds.filter(id => id !== userId)]));

    // Validate member IDs exist
    const users = await this.prisma.user.findMany({ where: { id: { in: uniqueMemberIds } } });
    if (users.length !== uniqueMemberIds.length) {
      throw new BadRequestException('One or more member IDs are invalid');
    }

    // Enforce that groups created via this endpoint are always PRIVATE
    const groupType: GroupType = GroupType.PRIVATE;

    return this.prisma.chatGroup.create({
      data: {
        name: dto.name,
        type: groupType,
        members: {
          create: uniqueMemberIds.map(memberId => ({
            userId: memberId,
          })),
        },
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
    });
  }

  async getAllGroups(userId?: string) {
    if (userId) {
      // Return public groups + private groups where user is a member
      return this.prisma.chatGroup.findMany({
        where: {
          OR: [
            { type: GroupType.PUBLIC },
            {
              type: GroupType.PRIVATE,
              members: {
                some: {
                  userId: userId,
                },
              },
            },
            {
              type: GroupType.USER,
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

    // For PUBLIC and CHALLENGE groups, users might not have a membership record
    // Only PRIVATE groups require explicit membership
    if (group.type === 'PUBLIC' ) {
      // Check if user has a membership record
      const membership = await this.prisma.chatGroupMember.findFirst({
        where: {
          userId,
          groupId,
        },
      });

      // If they have a membership, remove it; otherwise, just return success
      if (membership) {
        await this.prisma.chatGroupMember.delete({
          where: { id: membership.id },
        });
      }

      return { message: 'Successfully left the group' };
    }

    // For PRIVATE groups, membership is required
    const membership = await this.prisma.chatGroupMember.findFirst({
      where: {
        userId,
        groupId,
      },
    });

    if (!membership) {
      throw new NotFoundException('You are not a member of this group');
    }

    // Delete the membership
    await this.prisma.chatGroupMember.delete({
      where: { id: membership.id },
    });

    return { message: 'Successfully left the group' };
  }

  async addMemberToGroup(userId: string, groupId: string, memberId: string) {
    const group = await this.prisma.chatGroup.findUnique({
      where: { id: groupId },
      include: {
        members: {
          where: { userId },
        },
      },
    });

    if (!group) {
      throw new NotFoundException('Group not found');
    }

    // Check if user is a member of the group (for PRIVATE groups)
    if (group.type === 'PRIVATE' && group.members.length === 0) {
      throw new NotFoundException('You are not a member of this group');
    }

    // Check if member is already in the group
    const existingMember = await this.prisma.chatGroupMember.findFirst({
      where: {
        groupId,
        userId: memberId,
      },
    });

    if (existingMember) {
      throw new NotFoundException('User is already a member of this group');
    }

    // Add the member
    await this.prisma.chatGroupMember.create({
      data: {
        groupId,
        userId: memberId,
      },
    });

    return { message: 'Member added successfully' };
  }

  async removeMemberFromGroup(userId: string, groupId: string, memberId: string) {
    const group = await this.prisma.chatGroup.findUnique({
      where: { id: groupId },
      include: {
        members: {
          where: { userId },
        },
      },
    });

    if (!group) {
      throw new NotFoundException('Group not found');
    }

    // Check if user is a member of the group (for PRIVATE groups)
    if (group.type === 'PRIVATE' && group.members.length === 0) {
      throw new NotFoundException('You are not a member of this group');
    }

    // Find the membership to remove
    const membership = await this.prisma.chatGroupMember.findFirst({
      where: {
        groupId,
        userId: memberId,
      },
    });

    if (!membership) {
      throw new NotFoundException('User is not a member of this group');
    }

    // Remove the member
    await this.prisma.chatGroupMember.delete({
      where: { id: membership.id },
    });

    return { message: 'Member removed successfully' };
  }
}

