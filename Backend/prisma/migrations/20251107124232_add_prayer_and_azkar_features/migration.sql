-- CreateEnum
CREATE TYPE "PrayerName" AS ENUM ('FAJR', 'DHUHR', 'ASR', 'MAGHRIB', 'ISHA');

-- CreateEnum
CREATE TYPE "AzkarCategory" AS ENUM ('MORNING', 'EVENING', 'AFTER_PRAYER', 'BEFORE_SLEEP', 'GENERAL');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "DailyActionType" ADD VALUE 'QURAN_READ';
ALTER TYPE "DailyActionType" ADD VALUE 'DUA';
ALTER TYPE "DailyActionType" ADD VALUE 'FASTING';

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "TaskType" ADD VALUE 'PRAYER';
ALTER TYPE "TaskType" ADD VALUE 'AZKAR';

-- AlterTable
ALTER TABLE "DailyAction" ADD COLUMN     "count" INTEGER NOT NULL DEFAULT 1,
ADD COLUMN     "taskId" TEXT;

-- CreateTable
CREATE TABLE "PrayerTime" (
    "id" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "fajr" TEXT NOT NULL,
    "dhuhr" TEXT NOT NULL,
    "asr" TEXT NOT NULL,
    "maghrib" TEXT NOT NULL,
    "isha" TEXT NOT NULL,
    "location" TEXT,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PrayerTime_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PrayerCompletion" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "prayerName" "PrayerName" NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "completedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "onTime" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "PrayerCompletion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AzkarTemplate" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "arabicText" TEXT NOT NULL,
    "translation" TEXT NOT NULL,
    "category" "AzkarCategory" NOT NULL,
    "targetCount" INTEGER NOT NULL DEFAULT 1,
    "reward" INTEGER NOT NULL DEFAULT 10,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AzkarTemplate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AzkarProgress" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "azkarId" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "currentCount" INTEGER NOT NULL DEFAULT 0,
    "targetCount" INTEGER NOT NULL,
    "completed" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AzkarProgress_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "PrayerTime_date_idx" ON "PrayerTime"("date");

-- CreateIndex
CREATE UNIQUE INDEX "PrayerTime_date_latitude_longitude_key" ON "PrayerTime"("date", "latitude", "longitude");

-- CreateIndex
CREATE INDEX "PrayerCompletion_userId_idx" ON "PrayerCompletion"("userId");

-- CreateIndex
CREATE INDEX "PrayerCompletion_date_idx" ON "PrayerCompletion"("date");

-- CreateIndex
CREATE INDEX "PrayerCompletion_userId_date_idx" ON "PrayerCompletion"("userId", "date");

-- CreateIndex
CREATE UNIQUE INDEX "PrayerCompletion_userId_prayerName_date_key" ON "PrayerCompletion"("userId", "prayerName", "date");

-- CreateIndex
CREATE INDEX "AzkarTemplate_category_idx" ON "AzkarTemplate"("category");

-- CreateIndex
CREATE INDEX "AzkarProgress_userId_idx" ON "AzkarProgress"("userId");

-- CreateIndex
CREATE INDEX "AzkarProgress_date_idx" ON "AzkarProgress"("date");

-- CreateIndex
CREATE INDEX "AzkarProgress_userId_date_idx" ON "AzkarProgress"("userId", "date");

-- CreateIndex
CREATE UNIQUE INDEX "AzkarProgress_userId_azkarId_date_key" ON "AzkarProgress"("userId", "azkarId", "date");

-- CreateIndex
CREATE INDEX "DailyAction_userId_createdAt_idx" ON "DailyAction"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "DailyAction_userId_taskId_createdAt_idx" ON "DailyAction"("userId", "taskId", "createdAt");

-- AddForeignKey
ALTER TABLE "PrayerCompletion" ADD CONSTRAINT "PrayerCompletion_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AzkarProgress" ADD CONSTRAINT "AzkarProgress_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
