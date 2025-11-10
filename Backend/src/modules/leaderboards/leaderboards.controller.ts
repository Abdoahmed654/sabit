import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { LeaderboardsService } from './leaderboards.service';
import { CurrentUser, Public } from '../../common';

@ApiTags('leaderboards')
@Controller('leaderboards')
export class LeaderboardsController {
  constructor(private leaderboardsService: LeaderboardsService) {}

  @Public()
  @Get('xp')
  @ApiOperation({ summary: 'Get XP leaderboard' })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getXpLeaderboard(@Query('limit') limit?: number) {
    return this.leaderboardsService.getXpLeaderboard(limit ? +limit : 100);
  }

  @Public()
  @Get('coins')
  @ApiOperation({ summary: 'Get coins leaderboard' })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getCoinsLeaderboard(@Query('limit') limit?: number) {
    return this.leaderboardsService.getCoinsLeaderboard(limit ? +limit : 100);
  }

  @ApiBearerAuth()
  @Get('friends')
  @ApiOperation({ summary: 'Get friends leaderboard' })
  @ApiQuery({ name: 'type', required: false, enum: ['xp', 'coins'] })
  async getFriendsLeaderboard(
    @CurrentUser() user: any,
    @Query('type') type?: 'xp' | 'coins',
  ) {
    return this.leaderboardsService.getFriendsLeaderboard(
      user.id,
      type || 'xp',
    );
  }
}

