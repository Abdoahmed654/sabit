import { PrismaClient, ItemType, ItemRarity, GroupType } from '@prisma/client';

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
        name: 'Prayer Support',
        type: GroupType.PUBLIC,
      },
    }),
  ]);
  console.log(`✅ Created ${groups.length} chat groups`);

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

