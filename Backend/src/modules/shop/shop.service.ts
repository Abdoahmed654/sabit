import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateItemDto, BuyItemDto, EquipItemDto } from './dto';

@Injectable()
export class ShopService {
  constructor(private prisma: PrismaService) {}

  async getAllItems() {
    return this.prisma.item.findMany({
      orderBy: [{ rarity: 'desc' }, { priceCoins: 'asc' }],
    });
  }

  async getItemById(itemId: string) {
    const item = await this.prisma.item.findUnique({
      where: { id: itemId },
    });

    if (!item) {
      throw new NotFoundException('Item not found');
    }

    return item;
  }

  async createItem(dto: CreateItemDto) {
    return this.prisma.item.create({
      data: dto,
    });
  }

  async buyItem(userId: string, dto: BuyItemDto) {
    // Check if item exists
    const item = await this.prisma.item.findUnique({
      where: { id: dto.itemId },
    });

    if (!item) {
      throw new NotFoundException('Item not found');
    }

    // Check if user already owns the item
    const existingUserItem = await this.prisma.userItem.findUnique({
      where: {
        userId_itemId: {
          userId,
          itemId: dto.itemId,
        },
      },
    });

    if (existingUserItem) {
      throw new ConflictException('You already own this item');
    }

    // Get user
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Check if user has enough coins
    if (user.coins < item.priceCoins) {
      throw new BadRequestException('Insufficient coins');
    }

    // Check if user has enough XP (if required)
    if (item.priceXp > 0 && user.xp < item.priceXp) {
      throw new BadRequestException('Insufficient XP');
    }

    // Use transaction to ensure atomicity
    const result = await this.prisma.$transaction(async (tx) => {
      // Deduct coins
      await tx.user.update({
        where: { id: userId },
        data: {
          coins: {
            decrement: item.priceCoins,
          },
        },
      });

      // Add item to user's inventory
      const userItem = await tx.userItem.create({
        data: {
          userId,
          itemId: dto.itemId,
        },
        include: {
          item: true,
        },
      });

      // Create purchase record
      await tx.purchase.create({
        data: {
          userId,
          itemId: dto.itemId,
          priceCoins: item.priceCoins,
          status: 'SUCCESS',
        },
      });

      return userItem;
    });

    return result;
  }

  async equipItem(userId: string, dto: EquipItemDto) {
    // Find the user item
    const userItem = await this.prisma.userItem.findUnique({
      where: { id: dto.userItemId },
      include: { item: true },
    });

    if (!userItem) {
      throw new NotFoundException('Item not found in inventory');
    }

    if (userItem.userId !== userId) {
      throw new BadRequestException('This item does not belong to you');
    }

    // Unequip all items of the same type
    await this.prisma.userItem.updateMany({
      where: {
        userId,
        item: {
          type: userItem.item.type,
        },
      },
      data: {
        equipped: false,
      },
    });

    // Equip the selected item
    const equippedItem = await this.prisma.userItem.update({
      where: { id: dto.userItemId },
      data: { equipped: true },
      include: { item: true },
    });

    return equippedItem;
  }

  async unequipItem(userId: string, userItemId: string) {
    const userItem = await this.prisma.userItem.findUnique({
      where: { id: userItemId },
    });

    if (!userItem) {
      throw new NotFoundException('Item not found in inventory');
    }

    if (userItem.userId !== userId) {
      throw new BadRequestException('This item does not belong to you');
    }

    const unequippedItem = await this.prisma.userItem.update({
      where: { id: userItemId },
      data: { equipped: false },
      include: { item: true },
    });

    return unequippedItem;
  }
}

