import {
  Controller,
  Get,
  Put,
  Post,
  Body,
  Param,
  UseGuards,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { UpdateProfileDto, AddFriendDto } from './dto';
import { CurrentUser, JwtAuthGuard } from '../../common';

@UseGuards(JwtAuthGuard)
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

  @Post('friends/:friendshipId/block')
  @ApiOperation({ summary: 'Block friend request' })
  async blockFriendRequest(
    @CurrentUser() user: any,
    @Param('friendshipId') friendshipId: string,
  ) {
    return this.usersService.blockFriendRequest(user.id, friendshipId);
  }

  @Post('friends/:friendId/unfriend')
  @ApiOperation({ summary: 'Unfriend/remove a friend' })
  async unfriend(
    @CurrentUser() user: any,
    @Param('friendId') friendId: string,
  ) {
    return this.usersService.unfriend(user.id, friendId);
  }

  @Post('friends/:friendId/block-friend')
  @ApiOperation({ summary: 'Block an existing friend' })
  async blockFriend(
    @CurrentUser() user: any,
    @Param('friendId') friendId: string,
  ) {
    return this.usersService.blockFriend(user.id, friendId);
  }

  @Get('friends/requests/pending')
  @ApiOperation({ summary: 'Get pending friend requests' })
  async getPendingRequests(@CurrentUser() user: any) {
    return this.usersService.getPendingRequests(user.id);
  }

  @Get('friends')
  @ApiOperation({ summary: 'Get friends list' })
  async getFriends(@CurrentUser() user: any) {
    return this.usersService.getFriends(user.id) ?? [];
  }

  @Get('search')
  @ApiOperation({ summary: 'Search user by email' })
  async searchUserByEmail(@Query('email') email: string) {
    console.log(email)
    return this.usersService.searchUserByEmail(email);
  }
}

