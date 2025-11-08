import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class UsersGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private userSockets: Map<string, string> = new Map(); // userId -> socketId

  handleConnection(client: Socket) {
    const userId = client.handshake.headers.userid as string;
    if (userId) {
      this.userSockets.set(userId, client.id);
      console.log(`User ${userId} connected with socket ${client.id}`);
    }
  }

  handleDisconnect(client: Socket) {
    // Find and remove user from map
    for (const [userId, socketId] of this.userSockets.entries()) {
      if (socketId === client.id) {
        this.userSockets.delete(userId);
        console.log(`User ${userId} disconnected`);
        break;
      }
    }
  }

  // Emit friend request to specific user
  emitFriendRequest(userId: string, data: any) {
    const socketId = this.userSockets.get(userId);
    if (socketId) {
      this.server.to(socketId).emit('friendRequest', data);
      console.log(`Sent friend request to user ${userId}`);
    }
  }

  // Emit friend request accepted to specific user
  emitFriendRequestAccepted(userId: string, data: any) {
    const socketId = this.userSockets.get(userId);
    if (socketId) {
      this.server.to(socketId).emit('friendRequestAccepted', data);
      console.log(`Sent friend request accepted to user ${userId}`);
    }
  }

  // Emit friend request blocked to specific user
  emitFriendRequestBlocked(userId: string, data: any) {
    const socketId = this.userSockets.get(userId);
    if (socketId) {
      this.server.to(socketId).emit('friendRequestBlocked', data);
      console.log(`Sent friend request blocked to user ${userId}`);
    }
  }

  // Emit friend removed to specific user
  emitFriendRemoved(userId: string, data: any) {
    const socketId = this.userSockets.get(userId);
    if (socketId) {
      this.server.to(socketId).emit('friendRemoved', data);
      console.log(`Sent friend removed to user ${userId}`);
    }
  }

  // Emit friend blocked to specific user
  emitFriendBlocked(userId: string, data: any) {
    const socketId = this.userSockets.get(userId);
    if (socketId) {
      this.server.to(socketId).emit('friendBlocked', data);
      console.log(`Sent friend blocked to user ${userId}`);
    }
  }
}

