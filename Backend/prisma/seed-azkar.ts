import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding Azkar groups and Azkars...');

  // Create Morning Azkar Group
  const morningGroup = await prisma.azkarGroup.create({
    data: {
      name: 'Morning Azkar',
      nameAr: 'أذكار الصباح',
      description: 'Azkar to be recited in the morning',
      icon: '🌅',
      color: '#FF9800',
      category: 'MORNING',
      order: 1,
    },
  });
  // Create Evening Azkar Group
  const eveningGroup = await prisma.azkarGroup.create({
    data: {
      name: 'Evening Azkar',
      nameAr: 'أذكار المساء',
      description: 'Azkar to be recited in the evening',
      icon: '🌙',
      color: '#3F51B5',
      category: 'EVENING',
      order: 2,
    },
  });

  // Create After Prayer Azkar Group
  const afterPrayerGroup = await prisma.azkarGroup.create({
    data: {
      name: 'After Prayer Azkar',
      nameAr: 'أذكار بعد الصلاة',
      description: 'Azkar to be recited after each prayer',
      icon: '🕌',
      color: '#4CAF50',
      category: 'AFTER_PRAYER',
      order: 3,
    },
  });

  // Create Before Sleep Azkar Group
  const beforeSleepGroup = await prisma.azkarGroup.create({
    data: {
      name: 'Before Sleep Azkar',
      nameAr: 'أذكار النوم',
      description: 'Azkar to be recited before sleeping',
      icon: '😴',
      color: '#9C27B0',
      category: 'BEFORE_SLEEP',
      order: 4,
    },
  });

  console.log('Created Azkar groups');

  // Add Azkars to Morning Group
  await prisma.azkar.createMany({
    data: [
      {
        groupId: morningGroup.id,
        title: 'Ayat al-Kursi',
        titleAr: 'آية الكرسي',
        arabicText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ',
        translation: 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth.',
        transliteration: 'Allahu la ilaha illa huwa al-hayyul-qayyum...',
        targetCount: 1,
        xpReward: 50,
        coinsReward: 25,
        order: 1,
        reference: 'Quran 2:255',
      },
      {
        groupId: morningGroup.id,
        title: 'SubhanAllah wa bihamdihi',
        titleAr: 'سبحان الله وبحمده',
        arabicText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        translation: 'Glory be to Allah and praise Him',
        transliteration: 'SubhanAllahi wa bihamdihi',
        targetCount: 100,
        xpReward: 30,
        coinsReward: 15,
        order: 2,
        reference: 'Sahih Muslim 2691',
      },
    ],
  });

  // Add Azkars to Evening Group
  await prisma.azkar.createMany({
    data: [
      {
        groupId: eveningGroup.id,
        title: 'Ayat al-Kursi',
        titleAr: 'آية الكرسي',
        arabicText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ',
        translation: 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth.',
        transliteration: 'Allahu la ilaha illa huwa al-hayyul-qayyum...',
        targetCount: 1,
        xpReward: 50,
        coinsReward: 25,
        order: 1,
        reference: 'Quran 2:255',
      },
    ],
  });

  // Add Azkars to After Prayer Group
  await prisma.azkar.createMany({
    data: [
      {
        groupId: afterPrayerGroup.id,
        title: 'SubhanAllah',
        titleAr: 'سبحان الله',
        arabicText: 'سُبْحَانَ اللَّهِ',
        translation: 'Glory be to Allah',
        transliteration: 'SubhanAllah',
        targetCount: 33,
        xpReward: 15,
        coinsReward: 10,
        order: 1,
        reference: 'Sahih Muslim 595',
      },
      {
        groupId: afterPrayerGroup.id,
        title: 'Alhamdulillah',
        titleAr: 'الحمد لله',
        arabicText: 'الْحَمْدُ لِلَّهِ',
        translation: 'All praise is due to Allah',
        transliteration: 'Alhamdulillah',
        targetCount: 33,
        xpReward: 15,
        coinsReward: 10,
        order: 2,
        reference: 'Sahih Muslim 595',
      },
      {
        groupId: afterPrayerGroup.id,
        title: 'Allahu Akbar',
        titleAr: 'الله أكبر',
        arabicText: 'اللَّهُ أَكْبَرُ',
        translation: 'Allah is the Greatest',
        transliteration: 'Allahu Akbar',
        targetCount: 34,
        xpReward: 15,
        coinsReward: 10,
        order: 3,
        reference: 'Sahih Muslim 595',
      },
    ],
  });

  // Add Azkars to Before Sleep Group
  await prisma.azkar.createMany({
    data: [
      {
        groupId: beforeSleepGroup.id,
        title: 'Ayat al-Kursi',
        titleAr: 'آية الكرسي',
        arabicText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ',
        translation: 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth.',
        transliteration: 'Allahu la ilaha illa huwa al-hayyul-qayyum...',
        targetCount: 1,
        xpReward: 50,
        coinsReward: 25,
        order: 1,
        reference: 'Quran 2:255',
      },
    ],
  });

  console.log('Seeded Azkar groups and Azkars successfully!');
}

main()
  .catch((e) => {
    console.error('❌ Error seeding azkar:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

