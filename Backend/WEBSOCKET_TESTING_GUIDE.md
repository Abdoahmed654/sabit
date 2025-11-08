# WebSocket Real-time Testing Guide

This guide explains how to test the real-time WebSocket functionality for chat messages and friend requests.

## 🎯 Features Implemented

### 1. Real-time Chat Messages
- Users receive messages instantly without refreshing
- Messages are broadcast to all users in the same chat group
- WebSocket events: `joinGroup`, `leaveGroup`, `sendMessage`, `newMessage`

### 2. Real-time Friend Requests
- Users receive friend request notifications instantly
- Users receive acceptance notifications in real-time
- WebSocket events: `friendRequest`, `friendRequestAccepted`, `friendRequestBlocked`

## 🔧 Backend Implementation

### ChatGateway (`src/modules/chat/chat.gateway.ts`)
Handles real-time chat messages:
- `joinGroup`: Client joins a chat group room
- `leaveGroup`: Client leaves a chat group room
- `sendMessage`: Client sends a message, server broadcasts to all in group
- `newMessage`: Server event sent to all group members

### UsersGateway (`src/modules/users/users.gateway.ts`)
Handles real-time friend requests:
- Maintains user socket connections (userId → socketId mapping)
- `emitFriendRequest()`: Sends friend request notification to recipient
- `emitFriendRequestAccepted()`: Sends acceptance notification to sender
- `emitFriendRequestBlocked()`: Sends block notification to sender

### Integration Points
- **UsersService**: Emits WebSocket events when friend requests are sent/accepted/blocked
- **ChatService**: Already integrated with ChatGateway for message broadcasting

## 📱 Flutter Implementation

### WebSocketService (`App/lib/core/services/websocket_service.dart`)
Singleton service that manages WebSocket connection:
- Connects with userId in headers
- Provides methods for chat and friend request events
- Auto-reconnects on disconnect

### ChatBloc Integration
- Connects to WebSocket on user login
- Listens for `newMessage` events
- Auto-appends new messages to state without reloading
- Joins/leaves groups when entering/exiting chat screens

### FriendsBloc Integration
- Listens for `friendRequest` events
- Listens for `friendRequestAccepted` events
- Auto-reloads pending requests when new request arrives
- Auto-reloads friends list when request is accepted

## 🧪 Testing Instructions

### Prerequisites
1. Backend server running: `npm run start:dev`
2. Two devices/emulators with Flutter app installed
3. Two test user accounts

### Test 1: Real-time Chat Messages

**Setup:**
1. Login as User A on Device 1
2. Login as User B on Device 2
3. Both users join the same chat group

**Test Steps:**
1. User A sends a message: "Hello from User A"
2. **Expected**: User B sees the message appear instantly without refreshing
3. User B sends a message: "Hello from User B"
4. **Expected**: User A sees the message appear instantly

**Success Criteria:**
- ✅ Messages appear in real-time on both devices
- ✅ No manual refresh needed
- ✅ Messages appear in correct order
- ✅ Sender info (name, avatar) displays correctly

### Test 2: Real-time Friend Requests

**Setup:**
1. Login as User A on Device 1
2. Login as User B on Device 2
3. Navigate to Chat tab → Requests tab on Device 2

**Test Steps:**
1. User A sends friend request to User B (via email search)
2. **Expected**: User B sees the request appear instantly in Requests tab
3. User B accepts the friend request
4. **Expected**: 
   - User A sees User B appear in Friends tab instantly
   - User B sees the request disappear from Requests tab
   - Both users can now see each other in Friends tab

**Success Criteria:**
- ✅ Friend request appears instantly on recipient's device
- ✅ Acceptance notification appears instantly on sender's device
- ✅ Friends list updates automatically
- ✅ No manual refresh needed

### Test 3: WebSocket Connection Lifecycle

**Test Steps:**
1. Login as User A
2. Check backend logs for: `User {userId} connected with socket {socketId}`
3. Send a friend request or chat message
4. Logout or close app
5. Check backend logs for: `User {userId} disconnected`

**Success Criteria:**
- ✅ Connection established on login
- ✅ Events are sent/received while connected
- ✅ Connection closed on logout/app close
- ✅ No memory leaks or hanging connections

## 🐛 Troubleshooting

### Issue: Messages not appearing in real-time

**Check:**
1. Backend logs show WebSocket connection established
2. Flutter logs show "✅ WebSocket connected"
3. User is in the correct chat group
4. Network connectivity is stable

**Solution:**
- Restart the app to reconnect WebSocket
- Check if backend is running on correct port (3000)
- Verify userId is being sent in WebSocket headers

### Issue: Friend requests not appearing

**Check:**
1. Backend logs show `Sent friend request to user {userId}`
2. Recipient user is logged in and connected
3. FriendsBloc is listening to WebSocket events

**Solution:**
- Check if WebSocket connection is active
- Verify UsersGateway is properly injected in UsersService
- Check backend logs for any errors

### Issue: WebSocket connection fails

**Check:**
1. Backend server is running
2. CORS is enabled for WebSocket connections
3. Firewall/network allows WebSocket connections

**Solution:**
- Restart backend server
- Check WebSocket URL in Flutter app (should be `http://localhost:3000`)
- Try connecting from web browser first to test connectivity

## 📊 Backend Logs to Monitor

When testing, watch for these log messages:

```
✅ Good Signs:
- "User {userId} connected with socket {socketId}"
- "Sent friend request to user {userId}"
- "Sent friend request accepted to user {userId}"

❌ Error Signs:
- "WebSocket connection error: ..."
- "Error parsing new message: ..."
- No connection logs when user logs in
```

## 🔍 Flutter Debug Logs

Enable debug logs in Flutter to see WebSocket activity:

```dart
// In WebSocketService
print('✅ WebSocket connected');
print('❌ WebSocket disconnected');
print('Joined group: $groupId');
print('Message sent to group: $groupId');
```

## 📝 Notes

- WebSocket connections are maintained per user session
- Connections are automatically closed on logout
- Messages are only sent to users currently in the chat group
- Friend request notifications are only sent to online users
- Offline users will see updates when they next login (via normal API calls)

## 🚀 Next Steps

After successful testing, consider:
1. Adding typing indicators for chat
2. Adding "user is online" status
3. Adding read receipts for messages
4. Adding push notifications for offline users
5. Adding message delivery confirmations

