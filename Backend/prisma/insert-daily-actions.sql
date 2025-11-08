-- Insert Daily Actions directly into PostgreSQL
-- Replace 'USER_ID_HERE' with an actual user ID from your database

-- First, get a user ID (or create one)
-- SELECT id FROM "User" LIMIT 1;

-- Insert Prayer actions
INSERT INTO "DailyAction" ("id", "userId", "actionType", "metadata", "createdAt")
VALUES 
  -- Fajr Prayer
  (gen_random_uuid(), 'USER_ID_HERE', 'PRAYER', '{"prayerName": "Fajr", "inMosque": true}', NOW() - INTERVAL '0 days' + TIME '05:30:00'),
  
  -- Dhuhr Prayer
  (gen_random_uuid(), 'USER_ID_HERE', 'PRAYER', '{"prayerName": "Dhuhr", "inMosque": false}', NOW() - INTERVAL '0 days' + TIME '13:00:00'),
  
  -- Asr Prayer
  (gen_random_uuid(), 'USER_ID_HERE', 'PRAYER', '{"prayerName": "Asr", "inMosque": false}', NOW() - INTERVAL '0 days' + TIME '16:30:00'),
  
  -- Maghrib Prayer
  (gen_random_uuid(), 'USER_ID_HERE', 'PRAYER', '{"prayerName": "Maghrib", "inMosque": true}', NOW() - INTERVAL '0 days' + TIME '18:45:00'),
  
  -- Isha Prayer
  (gen_random_uuid(), 'USER_ID_HERE', 'PRAYER', '{"prayerName": "Isha", "inMosque": false}', NOW() - INTERVAL '0 days' + TIME '20:30:00');

-- Insert Tasbeeh actions
INSERT INTO "DailyAction" ("id", "userId", "actionType", "metadata", "createdAt")
VALUES 
  (gen_random_uuid(), 'USER_ID_HERE', 'TASBEEH', '{"count": 100, "type": "SubhanAllah", "after": "Fajr prayer"}', NOW() - INTERVAL '0 days' + TIME '06:00:00'),
  (gen_random_uuid(), 'USER_ID_HERE', 'TASBEEH', '{"count": 33, "type": "Before sleep", "dhikr": "SubhanAllah, Alhamdulillah, Allahu Akbar"}', NOW() - INTERVAL '0 days' + TIME '22:00:00');

-- Insert Azkar actions
INSERT INTO "DailyAction" ("id", "userId", "actionType", "metadata", "createdAt")
VALUES 
  (gen_random_uuid(), 'USER_ID_HERE', 'AZKAR', '{"type": "morning", "completed": true, "duration": "10 minutes"}', NOW() - INTERVAL '0 days' + TIME '06:30:00'),
  (gen_random_uuid(), 'USER_ID_HERE', 'AZKAR', '{"type": "evening", "completed": true, "duration": "8 minutes"}', NOW() - INTERVAL '0 days' + TIME '19:00:00');

-- Insert Charity action
INSERT INTO "DailyAction" ("id", "userId", "actionType", "metadata", "createdAt")
VALUES 
  (gen_random_uuid(), 'USER_ID_HERE', 'CHARITY', '{"amount": 10, "currency": "USD", "cause": "Orphan support", "organization": "Islamic Relief"}', NOW() - INTERVAL '0 days' + TIME '14:00:00');

-- Insert actions for yesterday
INSERT INTO "DailyAction" ("id", "userId", "actionType", "metadata", "createdAt")
VALUES 
  (gen_random_uuid(), 'USER_ID_HERE', 'PRAYER', '{"prayerName": "Fajr"}', NOW() - INTERVAL '1 days' + TIME '05:30:00'),
  (gen_random_uuid(), 'USER_ID_HERE', 'PRAYER', '{"prayerName": "Dhuhr"}', NOW() - INTERVAL '1 days' + TIME '13:00:00'),
  (gen_random_uuid(), 'USER_ID_HERE', 'PRAYER', '{"prayerName": "Asr"}', NOW() - INTERVAL '1 days' + TIME '16:30:00'),
  (gen_random_uuid(), 'USER_ID_HERE', 'PRAYER', '{"prayerName": "Maghrib"}', NOW() - INTERVAL '1 days' + TIME '18:45:00'),
  (gen_random_uuid(), 'USER_ID_HERE', 'PRAYER', '{"prayerName": "Isha"}', NOW() - INTERVAL '1 days' + TIME '20:30:00'),
  (gen_random_uuid(), 'USER_ID_HERE', 'AZKAR', '{"type": "morning", "completed": true}', NOW() - INTERVAL '1 days' + TIME '06:30:00'),
  (gen_random_uuid(), 'USER_ID_HERE', 'AZKAR', '{"type": "evening", "completed": true}', NOW() - INTERVAL '1 days' + TIME '19:00:00');

-- Insert actions for 2 days ago
INSERT INTO "DailyAction" ("id", "userId", "actionType", "metadata", "createdAt")
VALUES 
  (gen_random_uuid(), 'USER_ID_HERE', 'PRAYER', '{"prayerName": "Fajr"}', NOW() - INTERVAL '2 days' + TIME '05:30:00'),
  (gen_random_uuid(), 'USER_ID_HERE', 'PRAYER', '{"prayerName": "Dhuhr"}', NOW() - INTERVAL '2 days' + TIME '13:00:00'),
  (gen_random_uuid(), 'USER_ID_HERE', 'PRAYER', '{"prayerName": "Asr"}', NOW() - INTERVAL '2 days' + TIME '16:30:00'),
  (gen_random_uuid(), 'USER_ID_HERE', 'PRAYER', '{"prayerName": "Maghrib"}', NOW() - INTERVAL '2 days' + TIME '18:45:00'),
  (gen_random_uuid(), 'USER_ID_HERE', 'PRAYER', '{"prayerName": "Isha"}', NOW() - INTERVAL '2 days' + TIME '20:30:00'),
  (gen_random_uuid(), 'USER_ID_HERE', 'TASBEEH', '{"count": 100, "type": "SubhanAllah"}', NOW() - INTERVAL '2 days' + TIME '13:15:00');

-- Verify the insertions
SELECT 
  "actionType",
  COUNT(*) as count,
  DATE("createdAt") as date
FROM "DailyAction"
WHERE "userId" = 'USER_ID_HERE'
GROUP BY "actionType", DATE("createdAt")
ORDER BY date DESC, "actionType";

