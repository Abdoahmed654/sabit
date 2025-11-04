import { Controller, Get, Post, Body, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { BadgesService } from './badges.service';
import { CreateBadgeDto } from './dto';
import { CurrentUser, Public } from '../../common';

@ApiTags('badges')
@Controller('badges')
export class BadgesController {
  constructor(private badgesService: BadgesService) {}

  @Public()
  @Get()
  @ApiOperation({ summary: 'Get all badges' })
  async getAllBadges() {
    return this.badgesService.getAllBadges();
  }

  @Public()
  @Get(':id')
  @ApiOperation({ summary: 'Get badge by ID' })
  async getBadgeById(@Param('id') id: string) {
    return this.badgesService.getBadgeById(id);
  }

  @ApiBearerAuth()
  @Get('user/my-badges')
  @ApiOperation({ summary: 'Get user badges' })
  async getUserBadges(@CurrentUser() user: any) {
    return this.badgesService.getUserBadges(user.id);
  }
}

