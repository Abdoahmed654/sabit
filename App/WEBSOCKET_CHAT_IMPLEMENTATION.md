# WebSocket Chat Implementation

## Overview

The chat feature has been completely rewritten to use WebSockets for real-time communication. Messages are now sent and received via WebSocket connections instead of HTTP API calls.

## Architecture

### Backend (NestJS)

**ChatGateway** (`Backend/src/modules/chat/chat.gateway.ts`)
- Handles WebSocket connections and events
- Events:
  - `joinGroup`: Client joins a chat group room
  - `leaveGroup`: Client leaves a chat group room
  - `sendMessage`: Client sends a message (saved to DB and broadcast to group)
  - `newMessage`: Server broadcasts new message to all group members

### Frontend (Flutter)

**WebSocketService** (`App/lib/core/services/websocket_service.dart`)
- Singleton service managing WebSocket connections
- Methods:
  - `connect(userId)`: Establish WebSocket connection
  - `disconnect()`: Close WebSocket connection
  - `joinGroup(groupId)`: Join a chat group room
  - `leaveGroup(groupId)`: Leave a chat group room
  - `sendMessage(userId, groupId, content)`: Send a message via WebSocket
  - `onNewMessage(callback)`: Listen for incoming messages

**ChatBloc** (`App/lib/features/chat/presentation/bloc/chat_bloc.dart`)
- Manages chat state and WebSocket interactions
- Events:
  - `ConnectWebSocketEvent`: Connect to WebSocket server
  - `DisconnectWebSocketEvent`: Disconnect from WebSocket server
  - `JoinGroupEvent`: Join a chat group
  - `LeaveGroupEvent`: Leave a chat group
  - `SendMessageEvent`: Send a message via WebSocket
  - `NewMessageReceivedEvent`: Handle incoming message from WebSocket
  - `LoadGroupsEvent`: Load chat groups (HTTP API)
  - `LoadMessagesEvent`: Load message history (HTTP API)

**ChatState** (`App/lib/features/chat/presentation/bloc/chat_state.dart`)
- All states now include:
  - `isWebSocketConnected`: Boolean indicating WebSocket connection status
  - `currentGroupId`: Currently active group ID
- States:
  - `ChatInitial`: Initial state
  - `ChatLoading`: Loading data
  - `GroupsLoaded`: Chat groups loaded
  - `MessagesLoaded`: Messages loaded for a group
  - `WebSocketConnected`: WebSocket connected
  - `WebSocketDisconnected`: WebSocket disconnected
  - `ChatError`: Error occurred

## Flow

### 1. User Login
```
AuthListener → ConnectWebSocketEvent → WebSocketService.connect(userId)
```

### 2. Opening a Chat Group
```
ChatMessagesScreen.initState() →
  - LoadMessagesEvent (load history via HTTP)
  - JoinGroupEvent (join WebSocket room)
```

### 3. Sending a Message
```
User types message → SendMessageEvent →
  WebSocketService.sendMessage() →
  Backend ChatGateway.handleMessage() →
  Save to DB → Broadcast 'newMessage' to group
```

### 4. Receiving a Message
```
Backend broadcasts 'newMessage' →
  WebSocketService.onNewMessage() →
  NewMessageReceivedEvent →
  ChatBloc updates MessagesLoaded state →
  UI updates automatically
```

### 5. Leaving a Chat Group
```
ChatMessagesScreen.dispose() →
  LeaveGroupEvent →
  WebSocketService.leaveGroup()
```

## Key Features

### Real-time Updates
- Messages appear instantly for all users in the group
- No need to refresh or poll for new messages

### Connection Status Indicator
- Chat screen shows live connection status (green dot = connected, red dot = offline)
- Displays "Live" or "Offline" text next to group type

### Automatic Reconnection
- WebSocket service handles connection errors
- Emits events for connection/disconnection
- BLoC updates state accordingly

### Optimistic UI
- Messages are sent via WebSocket without waiting for confirmation
- The message will appear when broadcast back from the server
- Ensures consistency across all clients

## Usage

### Connecting to WebSocket
```dart
// Automatically done on login via AuthListener
context.read<ChatBloc>().add(ConnectWebSocketEvent(userId));
```

### Joining a Group
```dart
context.read<ChatBloc>().add(JoinGroupEvent(groupId));
```

### Sending a Message
```dart
context.read<ChatBloc>().add(
  SendMessageEvent(
    userId: currentUserId,
    groupId: groupId,
    content: messageContent,
  ),
);
```

### Leaving a Group
```dart
context.read<ChatBloc>().add(LeaveGroupEvent(groupId));
```

### Disconnecting
```dart
context.read<ChatBloc>().add(const DisconnectWebSocketEvent());
```

## Testing

### 1. Start Backend
```bash
cd Backend
npm run start:dev
```

### 2. Run Flutter App on Two Devices
```bash
cd App
flutter run
```

### 3. Test Real-time Chat
1. Login with two different users on two devices
2. Both users join the same chat group
3. Send a message from User A
4. Message should appear instantly on User B's screen
5. Check connection status indicator (should show green "Live")

### 4. Test Offline Behavior
1. Stop the backend server
2. Connection indicator should turn red "Offline"
3. Try sending a message - should show error
4. Restart backend
5. Connection should automatically restore

## Changes from Previous Implementation

### Removed
- ❌ `SendMessageUsecase` - No longer needed (using WebSocket)
- ❌ HTTP POST to `/chat/groups/:groupId/messages` for sending messages
- ❌ Polling or manual refresh for new messages

### Added
- ✅ WebSocket connection management in ChatBloc
- ✅ Real-time message broadcasting
- ✅ Connection status tracking
- ✅ Join/Leave group events
- ✅ Automatic message updates via WebSocket events
- ✅ Connection status indicator in UI

### Modified
- 🔄 `ChatBloc` - Now manages WebSocket lifecycle
- 🔄 `ChatState` - Includes WebSocket connection status
- 🔄 `ChatEvent` - Added WebSocket-related events
- 🔄 `ChatMessagesScreen` - Uses BLoC events for join/leave/send
- 🔄 `injection_container.dart` - Removed SendMessageUsecase

## Benefits

1. **Real-time Communication**: Messages appear instantly without polling
2. **Reduced Server Load**: No need for constant HTTP requests
3. **Better UX**: Users see messages as they arrive
4. **Scalability**: WebSocket connections are more efficient than HTTP polling
5. **Connection Awareness**: Users know when they're connected/disconnected
6. **Consistency**: All clients receive messages in the same order

## Future Enhancements

- [ ] Typing indicators
- [ ] Read receipts
- [ ] Message delivery status
- [ ] Offline message queue
- [ ] Automatic reconnection with exponential backoff
- [ ] Message encryption
- [ ] File/image sharing via WebSocket
