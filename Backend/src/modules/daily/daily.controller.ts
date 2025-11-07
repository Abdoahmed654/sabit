import { Controller, Get, Post, Body, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { DailyService } from './daily.service';
import { RecordActionDto } from './dto';
import { CurrentUser, Public } from '../../common';

@ApiTags('daily')
@Controller('daily')
export class DailyController {
  constructor(private dailyService: DailyService) {}

  @ApiBearerAuth()
  @Post('actions')
  @ApiOperation({ summary: 'Record a daily action' })
  async recordAction(@CurrentUser() user: any, @Body() dto: RecordActionDto) {
    return this.dailyService.recordAction(user.id, dto);
  }

  @ApiBearerAuth()
  @Get('actions')
  @ApiOperation({ summary: 'Get user actions' })
  @ApiQuery({ name: 'days', required: false, type: Number })
  async getUserActions(
    @Query('userid') userid: any,
    @Query('days') days?: number,
  ) {
    return this.dailyService.getUserActions(userid, days ? +days : 7);
  }

  @ApiBearerAuth()
  @Get('actions/today')
  @ApiOperation({ summary: 'Get today actions' })
  async getTodayActions(@CurrentUser() user: any) {
    return this.dailyService.getTodayActions(user.id);
  }

  @ApiBearerAuth()
  @Get('streak')
  @ApiOperation({ summary: 'Get action streak' })
  @ApiQuery({ name: 'actionType', required: true, type: String })
  async getStreak(
    @CurrentUser() user: any,
    @Query('actionType') actionType: string,
  ) {
    return this.dailyService.getStreak(user.id, actionType);
  }

  @Public()
  @Get('quote')
  @ApiOperation({ summary: 'Get quote of the day' })
  async getQuoteOfTheDay() {
    return this.dailyService.getQuoteOfTheDay();
  }
}

