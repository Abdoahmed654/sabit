import { Controller, Get, Post, Body, Query, UseGuards, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { DailyService } from './daily.service';
import { RecordActionDto, CompletePrayerDto, UpdateAzkarDto, GetPrayerTimesDto, CreateAzkarGroupDto, CreateAzkarDto, CompleteAzkarDto, CompleteFastingDto } from './dto';
import { CurrentUser, JwtAuthGuard, Public } from '../../common';
import { AzkarCategory } from '@prisma/client';

@UseGuards(JwtAuthGuard)
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

  // ==================== PRAYER ENDPOINTS ====================

  @Public()
  @Get('prayer-times')
  @ApiOperation({ summary: 'Get prayer times for a specific date and location' })
  async getPrayerTimes(@Query() dto: GetPrayerTimesDto) {
    return this.dailyService.getPrayerTimes(dto);
  }

  @ApiBearerAuth()
  @Post('prayer/complete')
  @ApiOperation({ summary: 'Mark a prayer as completed' })
  async completePrayer(@CurrentUser() user: any, @Body() dto: CompletePrayerDto) {
    return this.dailyService.completePrayer(user.id, dto);
  }

  @ApiBearerAuth()
  @Get('prayer/today')
  @ApiOperation({ summary: 'Get today\'s prayer status' })
  async getTodayPrayers(@CurrentUser() user: any) {
    return this.dailyService.getTodayPrayers(user.id);
  }

  // ==================== AZKAR ENDPOINTS ====================

  @Public()
  @Get('azkar/templates')
  @ApiOperation({ summary: 'Get azkar templates' })
  @ApiQuery({ name: 'category', required: false, enum: AzkarCategory })
  async getAzkarTemplates(@Query('category') category?: AzkarCategory) {
    return this.dailyService.getAzkarTemplates(category);
  }

  @ApiBearerAuth()
  @Post('azkar/progress')
  @ApiOperation({ summary: 'Update azkar progress (increment count)' })
  async updateAzkarProgress(@CurrentUser() user: any, @Body() dto: UpdateAzkarDto) {
    return this.dailyService.updateAzkarProgress(user.id, dto);
  }

  @ApiBearerAuth()
  @Get('azkar/today')
  @ApiOperation({ summary: 'Get today\'s azkar progress' })
  async getTodayAzkarProgress(@CurrentUser() user: any) {
    return this.dailyService.getTodayAzkarProgress(user.id);
  }

  // ==================== USER DAILY TASKS ====================

  @ApiBearerAuth()
  @Get('tasks')
  @ApiOperation({ summary: 'Get user\'s daily tasks from subscribed challenges' })
  async getUserDailyTasks(@CurrentUser() user: any) {
    return this.dailyService.getUserDailyTasks(user.id);
  }

  // ==================== NEW AZKAR GROUPS & AZKARS ====================

  @ApiBearerAuth()
  @Post('azkar-groups')
  @ApiOperation({ summary: 'Create a new Azkar group (Admin only)' })
  async createAzkarGroup(@CurrentUser() user: any, @Body() dto: CreateAzkarGroupDto) {
    return this.dailyService.createAzkarGroup(user.id, dto);
  }

  @Public()
  @Get('azkar-groups')
  @ApiOperation({ summary: 'Get all Azkar groups' })
  @ApiQuery({ name: 'category', required: false, enum: AzkarCategory })
  async getAllAzkarGroups(@Query('category') category?: AzkarCategory) {
    return this.dailyService.getAllAzkarGroups(category);
  }

  @Public()
  @Get('azkar-groups/:groupId')
  @ApiOperation({ summary: 'Get a specific Azkar group with its Azkars' })
  async getAzkarGroup(@Param('groupId') groupId: string) {
    return this.dailyService.getAzkarGroup(groupId);
  }

  @ApiBearerAuth()
  @Post('azkars')
  @ApiOperation({ summary: 'Create a new Azkar (Admin only)' })
  async createAzkar(@CurrentUser() user: any, @Body() dto: CreateAzkarDto) {
    return this.dailyService.createAzkar(user.id, dto);
  }

  @ApiBearerAuth()
  @Post('azkars/complete')
  @ApiOperation({ summary: 'Complete an Azkar (one-time, cannot redo)' })
  async completeAzkar(@CurrentUser() user: any, @Body() dto: CompleteAzkarDto) {
    return this.dailyService.completeAzkar(user.id, dto);
  }

  @ApiBearerAuth()
  @Get('azkars/completions')
  @ApiOperation({ summary: 'Get user\'s Azkar completions' })
  @ApiQuery({ name: 'groupId', required: false, type: String })
  async getUserAzkarCompletions(
    @CurrentUser() user: any,
    @Query('groupId') groupId?: string,
  ) {
    return this.dailyService.getUserAzkarCompletions(user.id, groupId);
  }

  // ==================== FASTING ====================

  @ApiBearerAuth()
  @Post('fasting/complete')
  @ApiOperation({ summary: 'Complete fasting (can only submit between Maghrib and Fajr)' })
  async completeFasting(@CurrentUser() user: any, @Body() dto: CompleteFastingDto) {
    return this.dailyService.completeFasting(user.id, dto);
  }

  @ApiBearerAuth()
  @Get('fasting/history')
  @ApiOperation({ summary: 'Get user\'s fasting history' })
  @ApiQuery({ name: 'days', required: false, type: Number })
  async getUserFastingHistory(
    @CurrentUser() user: any,
    @Query('days') days?: number,
  ) {
    return this.dailyService.getUserFastingHistory(user.id, days ? +days : 30);
  }

  @ApiBearerAuth()
  @Get('fasting/today')
  @ApiOperation({ summary: 'Get today\'s fasting status' })
  async getTodayFastingStatus(@CurrentUser() user: any) {
    return this.dailyService.getTodayFastingStatus(user.id);
  }
}

