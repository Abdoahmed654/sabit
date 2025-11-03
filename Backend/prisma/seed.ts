import { PrismaClient, ItemType, ItemRarity, TaskType, GroupType } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting seed...');

  // Create shop items
  console.log('Creating shop items...');
  const items = await Promise.all([
    // Hair items
    prisma.item.create({
      data: {
        name: 'Classic Kufi',
        type: ItemType.HAIR,
        priceCoins: 100,
        rarity: ItemRarity.COMMON,
        imageUrl: '/items/hair/kufi-classic.png',
      },
    }),
    prisma.item.create({
      data: {
        name: 'Golden Turban',
        type: ItemType.HAIR,
        priceCoins: 500,
        rarity: ItemRarity.RARE,
        imageUrl: '/items/hair/turban-golden.png',
      },
    }),
    // Cloth items
    prisma.item.create({
      data: {
        name: 'White Thobe',
        type: ItemType.CLOTH,
        priceCoins: 200,
        rarity: ItemRarity.COMMON,
        imageUrl: '/items/cloth/thobe-white.png',
      },
    }),
    prisma.item.create({
      data: {
        name: 'Royal Jubba',
        type: ItemType.CLOTH,
        priceCoins: 1000,
        rarity: ItemRarity.EPIC,
        imageUrl: '/items/cloth/jubba-royal.png',
      },
    }),
    // Accessories
    prisma.item.create({
      data: {
        name: 'Tasbih Beads',
        type: ItemType.ACCESSORY,
        priceCoins: 150,
        rarity: ItemRarity.COMMON,
        imageUrl: '/items/accessory/tasbih.png',
      },
    }),
    prisma.item.create({
      data: {
        name: 'Blessed Amulet',
        type: ItemType.ACCESSORY,
        priceCoins: 2000,
        rarity: ItemRarity.LEGENDARY,
        imageUrl: '/items/accessory/amulet.png',
      },
    }),
    // Shoes
    prisma.item.create({
      data: {
        name: 'Simple Sandals',
        type: ItemType.SHOES,
        priceCoins: 50,
        rarity: ItemRarity.COMMON,
        imageUrl: '/items/shoes/sandals.png',
      },
    }),
    prisma.item.create({
      data: {
        name: 'Leather Khuffs',
        type: ItemType.SHOES,
        priceCoins: 300,
        rarity: ItemRarity.RARE,
        imageUrl: '/items/shoes/khuffs.png',
      },
    }),
  ]);
  console.log(`✅ Created ${items.length} items`);

  // Create badges
  console.log('Creating badges...');
  const badges = await Promise.all([
    prisma.badge.create({
      data: {
        name: 'First Steps',
        description: 'Complete your first daily action',
        iconUrl: '/badges/first-steps.png',
        criteria: { type: 'first_action' },
      },
    }),
    prisma.badge.create({
      data: {
        name: 'Level 5 Master',
        description: 'Reach level 5',
        iconUrl: '/badges/level-5.png',
        criteria: { type: 'level', value: 5 },
      },
    }),
    prisma.badge.create({
      data: {
        name: 'Level 10 Master',
        description: 'Reach level 10',
        iconUrl: '/badges/level-10.png',
        criteria: { type: 'level', value: 10 },
      },
    }),
    prisma.badge.create({
      data: {
        name: 'Prayer Warrior',
        description: 'Complete 30 days of prayer streak',
        iconUrl: '/badges/prayer-warrior.png',
        criteria: { type: 'streak', action: 'PRAYER', days: 30 },
      },
    }),
    prisma.badge.create({
      data: {
        name: 'Generous Soul',
        description: 'Give charity 10 times',
        iconUrl: '/badges/generous.png',
        criteria: { type: 'count', action: 'CHARITY', count: 10 },
      },
    }),
  ]);
  console.log(`✅ Created ${badges.length} badges`);

  // Create challenges
  console.log('Creating challenges...');
  const ramadanChallenge = await prisma.challenge.create({
    data: {
      title: 'Ramadan 2025',
      description: 'Complete all Ramadan tasks to earn special rewards',
      startAt: new Date('2025-03-01'),
      endAt: new Date('2025-03-30'),
      rewardXp: 1000,
      rewardCoins: 500,
      isGlobal: true,
      tasks: {
        create: [
          {
            title: 'Fast for 30 days',
            type: TaskType.COUNT,
            goalCount: 30,
            points: 100,
          },
          {
            title: 'Read Quran daily',
            type: TaskType.DAILY,
            goalCount: 30,
            points: 50,
          },
          {
            title: 'Pray Taraweeh',
            type: TaskType.COUNT,
            goalCount: 30,
            points: 75,
          },
        ],
      },
    },
  });

  const dailyPrayerChallenge = await prisma.challenge.create({
    data: {
      title: '30-Day Prayer Challenge',
      description: 'Pray all 5 daily prayers for 30 consecutive days',
      startAt: new Date(),
      endAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      rewardXp: 500,
      rewardCoins: 250,
      isGlobal: true,
      tasks: {
        create: [
          {
            title: 'Maintain prayer streak',
            type: TaskType.STREAK,
            goalCount: 30,
            points: 100,
          },
        ],
      },
    },
  });

  console.log(`✅ Created 2 challenges`);

  // Create chat groups
  console.log('Creating chat groups...');
  const groups = await Promise.all([
    prisma.chatGroup.create({
      data: {
        name: 'General Discussion',
        type: GroupType.PUBLIC,
      },
    }),
    prisma.chatGroup.create({
      data: {
        name: 'Ramadan 2025 Group',
        type: GroupType.CHALLENGE,
      },
    }),
    prisma.chatGroup.create({
      data: {
        name: 'Prayer Support',
        type: GroupType.PUBLIC,
      },
    }),
  ]);
  console.log(`✅ Created ${groups.length} chat groups`);

  // Create a badge for Ramadan challenge
  await prisma.badge.create({
    data: {
      name: 'Ramadan 2025 Champion',
      description: 'Complete the Ramadan 2025 challenge',
      iconUrl: '/badges/ramadan-2025.png',
      criteria: { type: 'challenge', challengeId: ramadanChallenge.id },
    },
  });

  console.log('✅ Seed completed successfully!');
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

