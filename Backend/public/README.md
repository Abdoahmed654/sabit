# 🕌 Sabit Web App

A simple HTML/CSS/JavaScript web interface for the Sabit Islamic Gamified App.

## 🎯 Features

### 🏆 Challenges Tab
- View all active challenges
- See challenge tasks and requirements
- View rewards (XP and coins)
- See start and end dates

### 📿 Daily Actions Tab
- **Quote of the Day**: Inspirational Islamic quote
- **Quick Actions**: Record daily activities with one click
  - 🕌 Prayer (+50 XP, +10 coins)
  - 📿 Tasbeeh (+30 XP, +5 coins)
  - 💰 Charity (+100 XP, +20 coins)
  - 📖 Azkar (+40 XP, +8 coins)
- **Today's Actions**: See all actions recorded today
- **Streaks**: Track your consecutive days for each action type

### 🥇 Leaderboard Tab
- View top users by XP or Coins
- See rankings with gold/silver/bronze medals
- View user levels and scores

## 🚀 How to Use

### 1. Start the Backend
```bash
cd Backend
npm run start:dev
```

### 2. Open the Web App
Open your browser and go to:
```
http://localhost:3000
```

### 3. Register/Login
- Click the "Login" button in the top right
- If you don't have an account, click "Register"
- Fill in your details and submit

### 4. Explore Features
- **Challenges**: Browse active challenges and their tasks
- **Daily Actions**: Record your daily Islamic activities
- **Leaderboard**: See how you rank against other users

## 📱 Screenshots

### Challenges View
Shows all active challenges with their tasks, rewards, and dates.

### Daily Actions View
- Quote of the day at the top
- Quick action buttons to record activities
- List of today's completed actions
- Streak counters for each action type

### Leaderboard View
- Top 100 users by XP or Coins
- Rankings with medals for top 3
- User avatars and levels

## 🎨 Design

- **Modern UI**: Clean, gradient-based design
- **Responsive**: Works on desktop and mobile
- **Interactive**: Smooth animations and transitions
- **User-friendly**: Intuitive navigation with tabs

## 🔧 Technical Details

### Files
- `index.html` - Main HTML structure
- `styles.css` - All styling and responsive design
- `app.js` - JavaScript for API calls and interactivity

### API Integration
The app connects to the Sabit backend API:
- **Base URL**: `http://localhost:3000`
- **Authentication**: JWT tokens stored in localStorage
- **Endpoints Used**:
  - `POST /auth/login` - User login
  - `POST /auth/register` - User registration
  - `GET /users/profile` - Get user profile
  - `GET /challenges` - Get all challenges
  - `POST /daily/actions` - Record daily action
  - `GET /daily/actions/today` - Get today's actions
  - `GET /daily/streak` - Get action streaks
  - `GET /daily/quote` - Get quote of the day
  - `GET /leaderboards/xp` - Get XP leaderboard
  - `GET /leaderboards/coins` - Get coins leaderboard

### State Management
- Access token stored in `localStorage`
- User profile cached in memory
- Auto-refresh on login/logout

### Features
- ✅ Tab-based navigation
- ✅ Modal dialogs for login/register
- ✅ Toast notifications for feedback
- ✅ Real-time data updates
- ✅ Responsive design
- ✅ Loading states
- ✅ Error handling

## 🎮 Usage Examples

### Recording a Daily Action
1. Login to your account
2. Go to "Daily Actions" tab
3. Click on any action button (Prayer, Tasbeeh, etc.)
4. See instant feedback with XP and coins earned
5. Watch your stats update in the header

### Viewing Challenges
1. Go to "Challenges" tab
2. Browse all active challenges
3. See tasks required for each challenge
4. View rewards you can earn

### Checking Leaderboard
1. Go to "Leaderboard" tab
2. Switch between XP and Coins tabs
3. See your ranking among all users
4. View top performers

## 🔐 Security

- JWT tokens for authentication
- Tokens stored securely in localStorage
- Auto-logout on token expiration
- CORS enabled for API access

## 🎯 Future Enhancements

Possible improvements:
- Join challenges from the UI
- Track challenge progress
- View user badges
- Friend system integration
- Chat functionality
- Profile customization
- Dark mode
- Notifications
- PWA support

## 🐛 Troubleshooting

### Can't connect to API
- Make sure the backend is running on port 3000
- Check the console for CORS errors
- Verify `API_BASE_URL` in `app.js`

### Login not working
- Check your email and password
- Make sure you registered first
- Check the backend logs for errors

### Data not loading
- Make sure you're logged in
- Check your internet connection
- Open browser console for error messages

## 📞 Support

For issues or questions:
- Check backend logs: `npm run start:dev`
- View API docs: http://localhost:3000/api
- Check browser console for errors

---

**Built with ❤️ for the Muslim community**

