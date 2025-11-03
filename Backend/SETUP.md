# Sabit Backend - Quick Setup Guide

## 🚀 Quick Start (5 minutes)

### 1. Install Dependencies
```bash
npm install
```

### 2. Setup PostgreSQL Database

**Option A: Using Docker (Recommended)**
```bash
docker run --name sabit-postgres \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=sabit \
  -p 5432:5432 \
  -d postgres:14
```

**Option B: Local PostgreSQL**
- Install PostgreSQL 14+
- Create a database named `sabit`
- Update `.env` with your credentials

### 3. Configure Environment
The `.env` file is already created with default values. Update if needed:
```env
DATABASE_URL="postgresql://postgres:password@localhost:5432/sabit?schema=public"
JWT_SECRET=sabit-super-secret-jwt-key-change-in-production
```

### 4. Setup Database Schema
```bash
# Generate Prisma Client
npm run prisma:generate

# Run migrations to create tables
npm run prisma:migrate

# Seed database with test data
npm run prisma:seed
```

### 5. Start the Server
```bash
npm run start:dev
```

The server will start on http://localhost:3000

### 6. Access API Documentation
Open your browser and visit:
- **Swagger UI**: http://localhost:3000/api

---

## 📊 What Gets Seeded

The seed script creates:
- **8 Shop Items**: Hair, cloth, accessories, and shoes with different rarities
- **5 Badges**: First Steps, Level milestones, Prayer Warrior, Generous Soul
- **2 Challenges**: Ramadan 2025 and 30-Day Prayer Challenge
- **3 Chat Groups**: General Discussion, Ramadan 2025 Group, Prayer Support

---

## 🧪 Testing the API

### 1. Register a User
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "displayName": "Test User"
  }'
```

### 2. Login
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

Save the `accessToken` from the response.

### 3. Get Profile (Authenticated)
```bash
curl -X GET http://localhost:3000/users/profile \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 4. Record a Daily Action
```bash
curl -X POST http://localhost:3000/daily/actions \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "actionType": "PRAYER"
  }'
```

### 5. Buy an Item
```bash
curl -X POST http://localhost:3000/shop/buy \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "itemId": "ITEM_ID_FROM_SEED"
  }'
```

---

## 🔧 Common Commands

```bash
# Development
npm run start:dev          # Start with hot reload
npm run build              # Build for production
npm run start:prod         # Start production build

# Database
npm run prisma:studio      # Open Prisma Studio GUI
npm run prisma:migrate     # Create and run migrations
npm run prisma:seed        # Seed database
npx prisma migrate reset   # Reset database (WARNING: deletes all data)

# Testing
npm run test               # Run unit tests
npm run test:e2e           # Run e2e tests
npm run test:cov           # Test coverage
```

---

## 📁 Project Structure Overview

```
Backend/
├── prisma/
│   ├── schema.prisma      # Database schema
│   └── seed.ts            # Seed script
├── src/
│   ├── common/            # Shared utilities
│   ├── modules/           # Feature modules
│   │   ├── auth/          # Authentication
│   │   ├── users/         # User management
│   │   ├── shop/          # Shop system
│   │   ├── challenges/    # Challenges
│   │   ├── chat/          # Real-time chat
│   │   ├── leaderboards/  # Rankings
│   │   ├── badges/        # Achievements
│   │   ├── daily/         # Daily actions
│   │   └── admin/         # Admin panel
│   ├── prisma/            # Prisma service
│   ├── app.module.ts      # Root module
│   └── main.ts            # Entry point
├── .env                   # Environment variables
└── package.json           # Dependencies
```

---

## 🎯 Key Features Implemented

✅ **Authentication**: JWT with refresh tokens  
✅ **User System**: Profiles, XP/coins, leveling, friends  
✅ **Shop**: Buy and equip avatar items  
✅ **Challenges**: Multi-task challenges with progress tracking  
✅ **Chat**: Real-time WebSocket chat with Socket.IO  
✅ **Leaderboards**: XP, coins, and challenge rankings  
✅ **Badges**: Auto-awarding achievement system  
✅ **Daily Actions**: Track prayers, tasbeeh, charity, azkar  
✅ **Admin Panel**: Manage items, challenges, badges  
✅ **Swagger Docs**: Complete API documentation  

---

## 🐛 Troubleshooting

### Database Connection Error
- Ensure PostgreSQL is running
- Check DATABASE_URL in `.env`
- Verify database exists: `psql -U postgres -c "CREATE DATABASE sabit;"`

### Port Already in Use
- Change PORT in `.env` to a different port (e.g., 3001)
- Or kill the process using port 3000: `lsof -ti:3000 | xargs kill`

### Prisma Client Not Generated
```bash
npm run prisma:generate
```

### Migration Errors
```bash
# Reset and recreate database
npx prisma migrate reset
npm run prisma:seed
```

---

## 📞 Next Steps

1. **Test all endpoints** using Swagger UI at http://localhost:3000/api
2. **Create a test user** and try the complete flow
3. **Join a challenge** and track progress
4. **Buy items** from the shop
5. **Record daily actions** and check your streak
6. **Check leaderboards** to see rankings

---

## 🎉 You're All Set!

The Sabit backend is now running with:
- ✅ All modules implemented
- ✅ Database seeded with test data
- ✅ Swagger documentation available
- ✅ WebSocket chat ready
- ✅ Authentication working

Visit http://localhost:3000/api to explore the API!

