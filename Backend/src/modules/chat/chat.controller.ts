import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { ChatService } from './chat.service';
import { CreateGroupDto, SendMessageDto } from './dto';
import { CurrentUser, Public } from '../../common';

@ApiTags('chat')
@Controller('chat')
export class ChatController {
  constructor(private chatService: ChatService) {}

  @ApiBearerAuth()
  @Post('groups')
  @ApiOperation({ summary: 'Create a chat group' })
  async createGroup(@Body() dto: CreateGroupDto) {
    return this.chatService.createGroup(dto);
  }

  @Public()
  @Get('groups')
  @ApiOperation({ summary: 'Get all public groups' })
  async getAllGroups() {
    return this.chatService.getAllGroups();
  }

  @Public()
  @Get('groups/:id')
  @ApiOperation({ summary: 'Get group by ID' })
  async getGroupById(@Param('id') id: string) {
    return this.chatService.getGroupById(id);
  }

  @ApiBearerAuth()
  @Post('messages')
  @ApiOperation({ summary: 'Send a message (REST endpoint)' })
  async sendMessage(@CurrentUser() user: any, @Body() dto: SendMessageDto) {
    return this.chatService.sendMessage(user.id, dto);
  }

  @Public()
  @Get('groups/:id/messages')
  @ApiOperation({ summary: 'Get messages from a group' })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getMessages(
    @Param('id') groupId: string,
    @Query('limit') limit?: number,
  ) {
    return this.chatService.getMessages(groupId, limit ? +limit : 50);
  }
}

