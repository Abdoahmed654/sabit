// API Configuration
const API_BASE_URL = 'http://localhost:3000';

// State
let accessToken = localStorage.getItem('accessToken');
let currentUser = null;

// DOM Elements
const loginModal = document.getElementById('loginModal');
const registerModal = document.getElementById('registerModal');
const loginBtn = document.getElementById('loginBtn');
const userInfo = document.getElementById('userInfo');
const toast = document.getElementById('toast');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    initTabs();
    initModals();
    initAuth();
    loadInitialData();
});

// Tab Management
function initTabs() {
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');

    tabBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const tabName = btn.dataset.tab;
            
            tabBtns.forEach(b => b.classList.remove('active'));
            tabContents.forEach(c => c.classList.remove('active'));
            
            btn.classList.add('active');
            document.getElementById(tabName).classList.add('active');

            // Load data for the active tab
            if (tabName === 'challenges') loadChallenges();
            if (tabName === 'daily') loadDailyData();
            if (tabName === 'leaderboard') loadLeaderboard('xp');
        });
    });
}

// Modal Management
function initModals() {
    const closeBtns = document.querySelectorAll('.close');
    
    loginBtn.addEventListener('click', () => {
        if (accessToken) {
            logout();
        } else {
            showModal(loginModal);
        }
    });

    document.getElementById('showRegister').addEventListener('click', (e) => {
        e.preventDefault();
        hideModal(loginModal);
        showModal(registerModal);
    });

    document.getElementById('showLogin').addEventListener('click', (e) => {
        e.preventDefault();
        hideModal(registerModal);
        showModal(loginModal);
    });

    closeBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            hideModal(loginModal);
            hideModal(registerModal);
        });
    });

    document.getElementById('loginForm').addEventListener('submit', handleLogin);
    document.getElementById('registerForm').addEventListener('submit', handleRegister);
}

function showModal(modal) {
    modal.classList.add('show');
}

function hideModal(modal) {
    modal.classList.remove('show');
}

// Auth
function initAuth() {
    if (accessToken) {
        loadUserProfile();
    }
}

async function handleLogin(e) {
    e.preventDefault();
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;

    try {
        const response = await fetch(`${API_BASE_URL}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password })
        });

        const data = await response.json();
        
        if (response.ok) {
            accessToken = data.accessToken;
            localStorage.setItem('accessToken', accessToken);
            hideModal(loginModal);
            showToast('Login successful!', 'success');
            loadUserProfile();
            loadInitialData();
        } else {
            showToast(data.message || 'Login failed', 'error');
        }
    } catch (error) {
        showToast('Login failed', 'error');
    }
}

async function handleRegister(e) {
    e.preventDefault();
    const displayName = document.getElementById('regDisplayName').value;
    const email = document.getElementById('regEmail').value;
    const password = document.getElementById('regPassword').value;

    try {
        const response = await fetch(`${API_BASE_URL}/auth/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password, displayName })
        });

        const data = await response.json();
        
        if (response.ok) {
            showToast('Registration successful! Please login.', 'success');
            hideModal(registerModal);
            showModal(loginModal);
        } else {
            showToast(data.message || 'Registration failed', 'error');
        }
    } catch (error) {
        showToast('Registration failed', 'error');
    }
}

async function loadUserProfile() {
    try {
        const response = await fetch(`${API_BASE_URL}/users/profile`, {
            headers: { 'Authorization': `Bearer ${accessToken}` }
        });

        if (response.ok) {
            currentUser = await response.json();
            updateUserUI();
        } else {
            logout();
        }
    } catch (error) {
        console.error('Failed to load user profile', error);
    }
}

function updateUserUI() {
    if (currentUser) {
        userInfo.innerHTML = `
            <div class="user-stats">
                <div class="user-name">${currentUser.displayName}</div>
                <div class="stats">
                    <span class="stat">Level <strong>${currentUser.level}</strong></span>
                    <span class="stat">XP <strong>${currentUser.xp}</strong></span>
                    <span class="stat">Coins <strong>${currentUser.coins}</strong></span>
                </div>
            </div>
            <button class="btn btn-danger" id="loginBtn">Logout</button>
        `;
        document.getElementById('loginBtn').addEventListener('click', logout);
    }
}

function logout() {
    accessToken = null;
    currentUser = null;
    localStorage.removeItem('accessToken');
    userInfo.innerHTML = '<button class="btn btn-primary" id="loginBtn">Login</button>';
    document.getElementById('loginBtn').addEventListener('click', () => showModal(loginModal));
    showToast('Logged out successfully', 'success');
    loadInitialData();
}

// Load Initial Data
function loadInitialData() {
    loadChallenges();
    loadQuote();
    loadLeaderboard('xp');
    if (accessToken) {
        loadDailyData();
    }
}

// Challenges
async function loadChallenges() {
    const container = document.getElementById('challengesList');
    container.innerHTML = '<div class="loading">Loading challenges...</div>';

    try {
        const response = await fetch(`${API_BASE_URL}/challenges`);
        const challenges = await response.json();

        if (challenges.length === 0) {
            container.innerHTML = '<div class="loading">No active challenges</div>';
            return;
        }

        container.innerHTML = challenges.map(challenge => `
            <div class="challenge-card">
                <div class="challenge-header">
                    <h3 class="challenge-title">${challenge.title}</h3>
                    <p class="challenge-description">${challenge.description}</p>
                    <p class="challenge-dates">
                        ${new Date(challenge.startAt).toLocaleDateString()} - 
                        ${new Date(challenge.endAt).toLocaleDateString()}
                    </p>
                </div>
                <div class="challenge-rewards">
                    <span class="reward xp">🎯 ${challenge.rewardXp} XP</span>
                    <span class="reward coins">💰 ${challenge.rewardCoins} Coins</span>
                </div>
                <div class="challenge-tasks">
                    <h4>Tasks (${challenge.tasks.length})</h4>
                    ${challenge.tasks.map(task => `
                        <div class="task-item">
                            <div class="task-title">${task.title}</div>
                            <div class="task-details">
                                Goal: ${task.goalCount} | Points: ${task.points} | Type: ${task.type}
                            </div>
                        </div>
                    `).join('')}
                </div>
            </div>
        `).join('');
    } catch (error) {
        console.log(error);
        container.innerHTML = '<div class="loading">Failed to load challenges</div>';
    }
}

// Daily Actions
async function loadQuote() {
    const container = document.getElementById('quoteCard');
    
    try {
        const response = await fetch(`${API_BASE_URL}/daily/quote`);
        const data = await response.json();

        container.innerHTML = `
            <div class="quote-text">"${data.quote}"</div>
            <div class="quote-date">${new Date(data.date).toLocaleDateString()}</div>
        `;
    } catch (error) {
        console.log(error);
        container.innerHTML = '<div class="loading">Failed to load quote</div>';
    }
}

async function loadDailyData() {
    if (!accessToken) {
        document.getElementById('dailyTasksList').innerHTML = '<div class="loading">Login to see your daily tasks</div>';
        document.getElementById('azkarList').innerHTML = '<div class="loading">Login to see azkar</div>';
        return;
    }

    loadDailyTasks();
    loadPrayerTimes();
    loadAzkar();
    initActionButtons();
    initAzkarFilters();
}

// Daily Tasks from Challenges
async function loadDailyTasks() {
    const container = document.getElementById('dailyTasksList');

    try {
        const response = await fetch(`${API_BASE_URL}/daily/tasks`, {
            headers: { 'Authorization': `Bearer ${accessToken}` }
        });
        const data = await response.json();

        if (data.dailyTasks.length === 0) {
            container.innerHTML = '<div class="loading">No daily tasks. Join a challenge to get started!</div>';
            return;
        }

        container.innerHTML = data.dailyTasks.map(task => {
            const completedClass = task.completedToday ? 'completed' : '';
            const checkIcon = task.completedToday ? '✅' : '⬜';

            return `
                <div class="daily-task-item ${completedClass}">
                    <div class="task-check">${checkIcon}</div>
                    <div class="task-info">
                        <div class="task-name">${task.taskTitle}</div>
                        <div class="task-challenge">${task.challengeTitle}</div>
                        <div class="task-progress">
                            ${task.taskType === 'PRAYER' ? 'Complete 5 daily prayers' :
                              task.taskType === 'AZKAR' ? `Count: ${task.currentProgress}/${task.goalCount}` :
                              task.taskType === 'DAILY' ? 'Complete once today' :
                              `Progress: ${task.currentProgress}/${task.goalCount}`}
                        </div>
                    </div>
                    <div class="task-points">+${task.points} pts</div>
                </div>
            `;
        }).join('');

        // Add summary
        container.innerHTML += `
            <div class="tasks-summary">
                <strong>${data.summary.completedToday}/${data.summary.totalTasks}</strong> tasks completed today
            </div>
        `;
    } catch (error) {
        console.log(error);
        container.innerHTML = '<div class="loading">Failed to load daily tasks</div>';
    }
}

// Prayer Times
async function loadPrayerTimes() {
    const container = document.getElementById('prayerTimesList');

    try {
        // Get prayer times (using default location - Mecca)
        const timesResponse = await fetch(`${API_BASE_URL}/daily/prayer-times?latitude=21.3891&longitude=39.8579`);
        const timesData = await timesResponse.json();
        console.log(timesData)

        const prayers = ['FAJR', 'DHUHR', 'ASR', 'MAGHRIB', 'ISHA'];
        let completedPrayers = [];

        // Get today's completed prayers only if user is logged in
        if (accessToken) {
            try {
                const todayResponse = await fetch(`${API_BASE_URL}/daily/prayer/today`, {
                    headers: { 'Authorization': `Bearer ${accessToken}` }
                });

                if (todayResponse.ok) {
                    const todayData = await todayResponse.json();
                    completedPrayers = todayData.completed.map(p => p.prayerName);
                }
            } catch (error) {
                console.log('Error loading prayer completion status:', error);
            }
        }

        container.innerHTML = prayers.map(prayer => {
            const time = timesData.times[prayer];
            const isCompleted = completedPrayers.includes(prayer);
            const completedClass = isCompleted ? 'completed' : '';
            const checkIcon = isCompleted ? '✅' : '⬜';

            return `
                <div class="prayer-item ${completedClass}">
                    <div class="prayer-check">${checkIcon}</div>
                    <div class="prayer-info">
                        <div class="prayer-name">${prayer}</div>
                        <div class="prayer-time">${time}</div>
                    </div>
                    ${accessToken && !isCompleted ? `
                        <button class="btn-complete-prayer" data-prayer="${prayer}">
                            Complete
                        </button>
                    ` : isCompleted ? '<span class="completed-badge">Done</span>' :
                        '<span class="login-required">Login to track</span>'}
                </div>
            `;
        }).join('');

        // Add summary
        if (accessToken) {
            container.innerHTML += `
                <div class="prayer-summary">
                    <strong>${completedPrayers.length}/5</strong> prayers completed today
                </div>
            `;
        }

        // Add event listeners to complete buttons
        document.querySelectorAll('.btn-complete-prayer').forEach(btn => {
            btn.addEventListener('click', async () => {
                const prayerName = btn.dataset.prayer;
                await completePrayer(prayerName);
            });
        });
    } catch (error) {
        console.log(error);
        container.innerHTML = '<div class="loading">Failed to load prayer times</div>';
    }
}

async function completePrayer(prayerName) {
    try {
        const response = await fetch(`${API_BASE_URL}/daily/prayer/complete`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${accessToken}`
            },
            body: JSON.stringify({ prayerName, onTime: true })
        });

        const data = await response.json();

        if (response.ok) {
            showToast(`${prayerName} completed! +${data.xpEarned} XP, +${data.coinsEarned} coins`, 'success');
            loadPrayerTimes();
            loadDailyTasks();
            loadUserProfile();
        } else {
            showToast(data.message || 'Failed to complete prayer', 'error');
        }
    } catch (error) {
        showToast('Failed to complete prayer', 'error');
    }
}

// Azkar
let currentAzkarCategory = 'all';

async function loadAzkar(category = 'all') {
    const container = document.getElementById('azkarList');

    try {
        // Get azkar templates
        const templatesUrl = category === 'all'
            ? `${API_BASE_URL}/daily/azkar/templates`
            : `${API_BASE_URL}/daily/azkar/templates?category=${category}`;

        const templatesResponse = await fetch(templatesUrl);
        const templates = await templatesResponse.json();

        let progressData = [];

        // Get today's progress only if user is logged in
        if (accessToken) {
            try {
                const progressResponse = await fetch(`${API_BASE_URL}/daily/azkar/today`, {
                    headers: { 'Authorization': `Bearer ${accessToken}` }
                });

                if (progressResponse.ok) {
                    progressData = await progressResponse.json();
                }
            } catch (error) {
                console.log('Error loading azkar progress:', error);
            }
        }

        if (templates.length === 0) {
            container.innerHTML = '<div class="loading">No azkar found</div>';
            return;
        }

        container.innerHTML = templates.map(template => {
            const progress = progressData.find(p => p.azkarId === template.id);
            const currentCount = progress?.currentCount || 0;
            const targetCount = template.targetCount;
            const isCompleted = progress?.completed || false;
            const percentage = (currentCount / targetCount) * 100;
            const completedClass = isCompleted ? 'completed' : '';

            return `
                <div class="azkar-item ${completedClass}">
                    <div class="azkar-header">
                        <div class="azkar-arabic">${template.arabicText}</div>
                        <div class="azkar-translation">${template.translation}</div>
                        <div class="azkar-category">${template.category}</div>
                    </div>
                    <div class="azkar-counter">
                        <div class="counter-display">
                            <span class="current-count">${currentCount}</span>
                            <span class="separator">/</span>
                            <span class="target-count">${targetCount}</span>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: ${percentage}%"></div>
                        </div>
                    </div>
                    <div class="azkar-actions">
                        ${accessToken && !isCompleted ? `
                            <button class="btn-increment" data-azkar-id="${template.id}" data-count="1">+1</button>
                            <button class="btn-increment" data-azkar-id="${template.id}" data-count="10">+10</button>
                            <button class="btn-increment" data-azkar-id="${template.id}" data-count="33">+33</button>
                        ` : isCompleted ? '<span class="completed-badge">✅ Completed</span>' :
                            '<span class="login-required">Login to track</span>'}
                    </div>
                </div>
            `;
        }).join('');

        // Add event listeners to increment buttons
        document.querySelectorAll('.btn-increment').forEach(btn => {
            btn.addEventListener('click', async () => {
                const azkarId = btn.dataset.azkarId;
                const count = parseInt(btn.dataset.count);
                await incrementAzkar(azkarId, count);
            });
        });
    } catch (error) {
        console.log(error);
        container.innerHTML = '<div class="loading">Failed to load azkar</div>';
    }
}

async function incrementAzkar(azkarId, count) {
    try {
        const response = await fetch(`${API_BASE_URL}/daily/azkar/progress`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${accessToken}`
            },
            body: JSON.stringify({ azkarId, count })
        });

        const data = await response.json();

        if (response.ok) {
            if (data.completed) {
                showToast(`Azkar completed! +${data.xpEarned} XP, +${data.coinsEarned} coins`, 'success');
            } else {
                showToast(`+${count} count added`, 'success');
            }
            loadAzkar(currentAzkarCategory);
            loadDailyTasks();
            loadUserProfile();
        } else {
            showToast(data.message || 'Failed to update azkar', 'error');
        }
    } catch (error) {
        showToast('Failed to update azkar', 'error');
    }
}

function initAzkarFilters() {
    const filterBtns = document.querySelectorAll('.azkar-filter-btn');
    filterBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            filterBtns.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            currentAzkarCategory = btn.dataset.category;
            loadAzkar(currentAzkarCategory === 'all' ? 'all' : currentAzkarCategory);
        });
    });
}

function initActionButtons() {
    const buttons = document.querySelectorAll('.action-btn');
    buttons.forEach(btn => {
        btn.addEventListener('click', async () => {
            if (!accessToken) {
                showToast('Please login first', 'error');
                return;
            }

            const actionType = btn.dataset.action;
            await recordAction(actionType);
        });
    });
}

async function recordAction(actionType) {
    try {
        const response = await fetch(`${API_BASE_URL}/daily/actions`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${accessToken}`
            },
            body: JSON.stringify({ actionType })
        });

        const data = await response.json();

        if (response.ok) {
            showToast(`${actionType} recorded! +${data.rewards.xp} XP, +${data.rewards.coins} coins`, 'success');
            loadDailyTasks();
            loadUserProfile();
        } else {
            showToast(data.message || 'Failed to record action', 'error');
        }
    } catch (error) {
        showToast('Failed to record action', 'error');
    }
}

function getActionEmoji(actionType) {
    const emojis = {
        'PRAYER': '🕌',
        'TASBEEH': '📿',
        'CHARITY': '💰',
        'AZKAR': '📖'
    };
    return emojis[actionType] || '✅';
}

// Leaderboard
async function loadLeaderboard(type) {
    const container = document.getElementById('leaderboardList');
    container.innerHTML = '<div class="loading">Loading leaderboard...</div>';

    try {
        const response = await fetch(`${API_BASE_URL}/leaderboards/${type}`);
        const users = await response.json();

        container.innerHTML = users.map((user, index) => {
            const rank = index + 1;
            const rankClass = rank === 1 ? 'gold' : rank === 2 ? 'silver' : rank === 3 ? 'bronze' : '';
            const score = type === 'xp' ? user.xp : user.coins;
            
            return `
                <div class="leaderboard-item">
                    <div class="rank ${rankClass}">#${rank}</div>
                    <div class="user-avatar">${user.displayName.charAt(0).toUpperCase()}</div>
                    <div class="user-details">
                        <div class="user-display-name">${user.displayName}</div>
                        <div class="user-level">Level ${user.level}</div>
                    </div>
                    <div class="user-score">${score.toLocaleString()}</div>
                </div>
            `;
        }).join('');
    } catch (error) {
        container.innerHTML = '<div class="loading">Failed to load leaderboard</div>';
    }
}

// Leaderboard tabs
document.querySelectorAll('.leaderboard-tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        document.querySelectorAll('.leaderboard-tab-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        loadLeaderboard(btn.dataset.type);
    });
});

// Toast Notification
function showToast(message, type = 'success') {
    toast.textContent = message;
    toast.className = `toast show ${type}`;
    
    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}

