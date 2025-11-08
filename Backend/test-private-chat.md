# Testing Private Chat Feature

## Overview
When two users become friends (by accepting a friend request), a private chat is automatically created for them.

## How It Works

### 1. Database Schema
A new `ChatGroupMember` table was created to track which users belong to which chat groups:

```sql
CREATE TABLE "ChatGroupMember" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "ChatGroupMember_pkey" PRIMARY KEY ("id")
);
```

### 2. Friend Request Acceptance Flow

When User B accepts User A's friend request:

1. **Friendship Status Updated**: The friendship status is set to 'ACCEPTED'
2. **Check for Existing Chat**: System checks if a private chat already exists between these two users
3. **Create Private Chat** (if it doesn't exist):
   - Creates a new `ChatGroup` with type `PRIVATE`
   - Names it: "User A & User B"
   - Adds both users as members via `ChatGroupMember` table
4. **WebSocket Notification**: User A is notified that their friend request was accepted

### 3. Viewing Private Chats

When a user requests their chat groups via `GET /chat/groups`:
- Returns all PUBLIC groups
- Returns all CHALLENGE groups
- Returns all PRIVATE groups where the user is a member

The response includes member information so the frontend can display the friend's name and avatar.

## Testing Steps

### Step 1: Create Two Users
```bash
# Register User A
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@example.com",
    "password": "password123",
    "displayName": "Alice"
  }'

# Register User B
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "bob@example.com",
    "password": "password123",
    "displayName": "Bob"
  }'
```

### Step 2: User A Sends Friend Request to User B
```bash
# Login as Alice and get token
TOKEN_A=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@example.com","password":"password123"}' \
  | jq -r '.accessToken')

# Send friend request (replace USER_B_ID with Bob's actual ID)
curl -X POST http://localhost:3000/users/friends/request \
  -H "Authorization: Bearer $TOKEN_A" \
  -H "Content-Type: application/json" \
  -d '{"friendId": "USER_B_ID"}'
```

### Step 3: User B Accepts Friend Request
```bash
# Login as Bob and get token
TOKEN_B=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"bob@example.com","password":"password123"}' \
  | jq -r '.accessToken')

# Get pending friend requests
curl -X GET http://localhost:3000/users/friends/requests/pending \
  -H "Authorization: Bearer $TOKEN_B"

# Accept the friend request (replace FRIENDSHIP_ID with actual ID from above)
curl -X POST http://localhost:3000/users/friends/FRIENDSHIP_ID/accept \
  -H "Authorization: Bearer $TOKEN_B"
```

### Step 4: Verify Private Chat Was Created
```bash
# Check Alice's chat groups
curl -X GET http://localhost:3000/chat/groups \
  -H "Authorization: Bearer $TOKEN_A"

# Check Bob's chat groups
curl -X GET http://localhost:3000/chat/groups \
  -H "Authorization: Bearer $TOKEN_B"

# Both should see a PRIVATE group named "Alice & Bob" with both users as members
```

### Step 5: Send Messages in Private Chat
```bash
# Alice sends a message (replace GROUP_ID with the private chat group ID)
curl -X POST http://localhost:3000/chat/messages \
  -H "Authorization: Bearer $TOKEN_A" \
  -H "Content-Type: application/json" \
  -d '{
    "groupId": "GROUP_ID",
    "content": "Hi Bob! This is our private chat!"
  }'

# Bob can see the messages
curl -X GET http://localhost:3000/chat/groups/GROUP_ID/messages \
  -H "Authorization: Bearer $TOKEN_B"
```

## Frontend Integration

The Flutter app automatically:
1. Loads all chat groups (including private chats) when opening the chat screen
2. Displays private chats with the friend's name and avatar
3. Uses WebSocket for real-time message delivery
4. Caches chat groups and messages locally for offline access

## Key Features

✅ **Automatic Creation**: Private chat is created automatically when friends are accepted
✅ **Duplicate Prevention**: Checks if a private chat already exists before creating a new one
✅ **Proper Naming**: Chat is named with both users' display names
✅ **Member Tracking**: Uses `ChatGroupMember` table to track who belongs to which groups
✅ **Filtered Access**: Users only see private chats they're members of
✅ **Real-time Messaging**: Uses WebSocket for instant message delivery
✅ **Offline Support**: Messages and groups are cached locally

