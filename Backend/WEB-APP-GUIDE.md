# 🌐 Sabit Web App - Quick Start Guide

A beautiful, simple web interface to interact with your Sabit Islamic Gamified App backend!

## 🚀 Quick Start (3 Steps)

### Step 1: Start the Backend
```bash
cd Backend
npm run start:dev
```

### Step 2: Open Your Browser
Go to: **http://localhost:3000**

### Step 3: Register & Start Using!
1. Click "Login" button
2. Click "Register" link
3. Fill in your details
4. Start recording daily actions! 🎉

---

## ✨ What You Can Do

### 🏆 View Challenges
- See all active challenges
- View tasks for each challenge
- Check rewards (XP & coins)
- See start/end dates

**Example Challenge:**
```
Ramadan 2025 Challenge
- Complete 30 fasts
- Read Quran daily
- Give charity weekly
Rewards: 1000 XP + 200 coins
```

### 📿 Record Daily Actions
Click buttons to instantly record:
- **🕌 Prayer** → +50 XP, +10 coins
- **📿 Tasbeeh** → +30 XP, +5 coins
- **💰 Charity** → +100 XP, +20 coins
- **📖 Azkar** → +40 XP, +8 coins

**Your progress updates instantly!**

### 🔥 Track Streaks
See your consecutive days for each action:
```
Prayer Streak: 15 days 🔥
Tasbeeh Streak: 7 days 🔥
Charity Streak: 3 days 🔥
Azkar Streak: 10 days 🔥
```

### 🥇 Check Leaderboard
- View top 100 users
- Switch between XP and Coins
- See rankings with medals (🥇🥈🥉)

---

## 📸 Features Overview

### Header
```
🕌 Sabit
Islamic Gamified App

[Your Name]
Level 5 | XP 500 | Coins 100
[Logout]
```

### Tabs
- **🏆 Challenges** - Browse and view challenges
- **📿 Daily Actions** - Record activities and track streaks
- **🥇 Leaderboard** - See top users

### Daily Actions Tab
1. **Quote of the Day** (top banner)
   - Inspirational Islamic quote
   - Changes daily

2. **Quick Action Buttons** (4 buttons)
   - One click to record
   - Instant feedback
   - XP & coins shown

3. **Today's Actions** (list)
   - All actions you recorded today
   - Time stamps
   - Action types

4. **Streaks** (4 cards)
   - Prayer streak
   - Tasbeeh streak
   - Charity streak
   - Azkar streak

---

## 🎯 Example Usage Flow

### First Time User
```
1. Open http://localhost:3000
2. Click "Login" → "Register"
3. Enter:
   - Display Name: "Abdullah"
   - Email: "abdullah@example.com"
   - Password: "password123"
4. Click "Register"
5. Login with same credentials
6. You're in! 🎉
```

### Recording Your First Action
```
1. Go to "Daily Actions" tab
2. Click "🕌 Prayer" button
3. See toast: "PRAYER recorded! +50 XP, +10 coins"
4. Check header: XP increased to 50, Coins to 10
5. See action in "Today's Actions" list
6. Check streak: "Prayer Streak: 1 day 🔥"
```

### Daily Routine
```
Morning:
- Record Fajr prayer
- Record morning Azkar
- Do 100 Tasbeeh

Afternoon:
- Record Dhuhr prayer
- Record Asr prayer

Evening:
- Record Maghrib prayer
- Record evening Azkar
- Record Isha prayer
- Give charity (weekly)

Total Daily: 430 XP + 86 coins! 💰
```

---

## 🎨 Design Features

### Modern UI
- Clean, gradient backgrounds
- Smooth animations
- Card-based layout
- Responsive design

### Color Scheme
- Primary: Green (#2ecc71)
- Secondary: Blue (#3498db)
- Danger: Red (#e74c3c)
- Warning: Orange (#f39c12)

### Interactive Elements
- Hover effects on cards
- Click animations on buttons
- Toast notifications
- Modal dialogs

### Responsive
- Works on desktop (1200px+)
- Works on tablet (768px+)
- Works on mobile (320px+)

---

## 🔧 Technical Details

### Files Location
```
Backend/public/
├── index.html    # Main HTML structure
├── styles.css    # All styling
├── app.js        # JavaScript logic
└── README.md     # Documentation
```

### API Endpoints Used
```javascript
// Authentication
POST /auth/register
POST /auth/login

// User
GET /users/profile

// Challenges
GET /challenges

// Daily Actions
POST /daily/actions
GET /daily/actions/today
GET /daily/streak?actionType=PRAYER
GET /daily/quote

// Leaderboard
GET /leaderboards/xp
GET /leaderboards/coins
```

### State Management
- **Access Token**: Stored in localStorage
- **User Profile**: Cached in memory
- **Auto-refresh**: On login/logout

---

## 💡 Tips & Tricks

### Maximize Your XP
```
Daily Goal: 430 XP + 86 coins

✅ Record all 5 prayers (250 XP, 50 coins)
✅ Morning Azkar (40 XP, 8 coins)
✅ Evening Azkar (40 XP, 8 coins)
✅ Tasbeeh after prayers (30 XP, 5 coins)
✅ Weekly charity (100 XP, 20 coins)
```

### Build Streaks
- Record actions daily
- Don't break the chain!
- Streaks = motivation 🔥

### Compete on Leaderboard
- Check your ranking
- Compete with friends
- Aim for top 10!

---

## 🐛 Troubleshooting

### Problem: Can't see the website
**Solution:**
```bash
# Make sure backend is running
npm run start:dev

# Open browser to:
http://localhost:3000
```

### Problem: Login not working
**Solution:**
1. Register first if new user
2. Check email/password spelling
3. Check backend logs for errors

### Problem: Actions not recording
**Solution:**
1. Make sure you're logged in
2. Check if token expired (re-login)
3. Check browser console for errors

### Problem: Data not loading
**Solution:**
1. Refresh the page
2. Clear browser cache
3. Check backend is running
4. Check browser console

---

## 📱 Mobile Usage

The web app is fully responsive!

### On Mobile
- Tabs stack vertically
- Cards resize to fit screen
- Touch-friendly buttons
- Optimized layout

### Best Experience
- Use Chrome or Safari
- Portrait or landscape mode
- Add to home screen (PWA-ready)

---

## 🎯 Next Steps

### For Users
1. ✅ Record daily actions
2. ✅ Build streaks
3. ✅ Join challenges
4. ✅ Compete on leaderboard
5. ✅ Earn badges

### For Developers
Want to customize? Edit:
- `public/index.html` - Structure
- `public/styles.css` - Styling
- `public/app.js` - Functionality

---

## 🌟 Features Showcase

### Quote of the Day
```
"Verily, with hardship comes ease."
- Quran 94:6
```

### Challenge Card
```
┌─────────────────────────────────┐
│ Ramadan 2025 Challenge          │
│ Complete Ramadan activities     │
│ Mar 1, 2025 - Mar 30, 2025     │
│                                 │
│ 🎯 1000 XP  💰 200 Coins       │
│                                 │
│ Tasks (3):                      │
│ ├─ Complete 30 fasts            │
│ ├─ Read Quran daily             │
│ └─ Give charity weekly          │
└─────────────────────────────────┘
```

### Leaderboard Entry
```
#1 🥇 [A] Abdullah
       Level 25
       15,420 XP
```

---

## 🎉 Success!

You now have a fully functional web interface for Sabit!

**Enjoy tracking your Islamic activities and earning rewards!** 🕌

---

**May Allah accept your good deeds! 🤲**

