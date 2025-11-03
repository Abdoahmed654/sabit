import {
  Controller,
  Get,
  Put,
  Post,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { UpdateProfileDto, AddFriendDto } from './dto';
import { CurrentUser } from '../../common';

@ApiTags('users')
@ApiBearerAuth()
@Controller('users')
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('profile')
  @ApiOperation({ summary: 'Get current user profile' })
  async getProfile(@CurrentUser() user: any) {
    return this.usersService.getProfile(user.id);
  }

  @Put('profile')
  @ApiOperation({ summary: 'Update user profile' })
  async updateProfile(
    @CurrentUser() user: any,
    @Body() dto: UpdateProfileDto,
  ) {
    return this.usersService.updateProfile(user.id, dto);
  }

  @Get('inventory')
  @ApiOperation({ summary: 'Get user inventory' })
  async getInventory(@CurrentUser() user: any) {
    return this.usersService.getInventory(user.id);
  }

  @Get('equipped')
  @ApiOperation({ summary: 'Get equipped items' })
  async getEquippedItems(@CurrentUser() user: any) {
    return this.usersService.getEquippedItems(user.id);
  }

  @Post('friends/request')
  @ApiOperation({ summary: 'Send friend request' })
  async sendFriendRequest(
    @CurrentUser() user: any,
    @Body() dto: AddFriendDto,
  ) {
    return this.usersService.sendFriendRequest(user.id, dto);
  }

  @Post('friends/:friendshipId/accept')
  @ApiOperation({ summary: 'Accept friend request' })
  async acceptFriendRequest(
    @CurrentUser() user: any,
    @Param('friendshipId') friendshipId: string,
  ) {
    return this.usersService.acceptFriendRequest(user.id, friendshipId);
  }

  @Get('friends')
  @ApiOperation({ summary: 'Get friends list' })
  async getFriends(@CurrentUser() user: any) {
    return this.usersService.getFriends(user.id);
  }
}

