import { Controller, Get, Post, Put, Delete, Body, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ShopService } from '../shop/shop.service';
import { ChallengesService } from '../challenges/challenges.service';
import { BadgesService } from '../badges/badges.service';
import { CreateItemDto } from '../shop/dto';
import { CreateChallengeDto } from '../challenges/dto';
import { CreateBadgeDto } from '../badges/dto';

@ApiTags('admin')
@ApiBearerAuth()
@Controller('admin')
export class AdminController {
  constructor(
    private shopService: ShopService,
    private challengesService: ChallengesService,
    private badgesService: BadgesService,
  ) {}

  // Items Management
  @Post('items')
  @ApiOperation({ summary: 'Create a new item' })
  async createItem(@Body() dto: CreateItemDto) {
    return this.shopService.createItem(dto);
  }

  // Challenges Management
  @Post('challenges')
  @ApiOperation({ summary: 'Create a new challenge' })
  async createChallenge(@Body() dto: CreateChallengeDto) {
    return this.challengesService.createChallenge(dto);
  }

  // Badges Management
  @Post('badges')
  @ApiOperation({ summary: 'Create a new badge' })
  async createBadge(@Body() dto: CreateBadgeDto) {
    return this.badgesService.createBadge(dto);
  }

  @Post('badges/:badgeId/award/:userId')
  @ApiOperation({ summary: 'Award a badge to a user' })
  async awardBadge(
    @Param('badgeId') badgeId: string,
    @Param('userId') userId: string,
  ) {
    return this.badgesService.awardBadge(userId, badgeId);
  }
}

