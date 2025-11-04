import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { ChatService } from './chat.service';
import { UseGuards } from '@nestjs/common';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  constructor(private chatService: ChatService) {}

  handleConnection(client: Socket) {
    console.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    console.log(`Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('joinGroup')
  async handleJoinGroup(
    @MessageBody() data: { groupId: string },
    @ConnectedSocket() client: Socket,
  ) {
    client.join(data.groupId);
    return { event: 'joinedGroup', data: { groupId: data.groupId } };
  }

  @SubscribeMessage('leaveGroup')
  async handleLeaveGroup(
    @MessageBody() data: { groupId: string },
    @ConnectedSocket() client: Socket,
  ) {
    client.leave(data.groupId);
    return { event: 'leftGroup', data: { groupId: data.groupId } };
  }

  @SubscribeMessage('sendMessage')
  async handleMessage(
    @MessageBody() data: { userId: string; groupId: string; content: string },
    @ConnectedSocket() client: Socket,
  ) {
    const message = await this.chatService.sendMessage(data.userId, {
      groupId: data.groupId,
      content: data.content,
    });

    this.server.to(data.groupId).emit('newMessage', message);

    return { event: 'messageSent', data: message };
  }
}

