import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Put,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ChallengesService } from './challenges.service';
import { CreateChallengeDto, UpdateProgressDto } from './dto';
import { CurrentUser, Public, JwtAuthGuard } from '../../common';

@UseGuards(JwtAuthGuard)
@ApiTags('challenges')
@Controller('challenges')
export class ChallengesController {
  constructor(private challengesService: ChallengesService) {}

  @Public()
  @Get()
  @ApiOperation({ summary: 'Get all active challenges' })
  async getAllChallenges() {
    return this.challengesService.getAllChallenges();
  }

  @Public()
  @Get(':id')
  @ApiOperation({ summary: 'Get challenge by ID' })
  async getChallengeById(@Param('id') id: string) {
    return this.challengesService.getChallengeById(id);
  }

  @ApiBearerAuth()
  @Post(':id/join')
  @ApiOperation({ summary: 'Join a challenge' })
  async joinChallenge(
    @CurrentUser() user: any,
    @Param('id') challengeId: string,
  ) {
    return this.challengesService.joinChallenge(user.id, challengeId);
  }

  @ApiBearerAuth()
  @Put(':id/progress')
  @ApiOperation({ summary: 'Update challenge progress' })
  async updateProgress(
    @CurrentUser() user: any,
    @Param('id') challengeId: string,
    @Body() dto: UpdateProgressDto,
  ) {
    return this.challengesService.updateProgress(user.id, challengeId, dto);
  }

  @ApiBearerAuth()
  @Get(':id/progress')
  @ApiOperation({ summary: 'Get user progress for a challenge' })
  async getUserProgress(
    @CurrentUser() user: any,
    @Param('id') challengeId: string,
  ) {
    return this.challengesService.getUserProgress(user.id, challengeId);
  }

  @ApiBearerAuth()
  @Get('user/my-challenges')
  @ApiOperation({ summary: 'Get all user challenges' })
  async getUserChallenges(@CurrentUser() user: any) {
    return this.challengesService.getUserChallenges(user.id);
  }
}

