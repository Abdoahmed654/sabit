/*
  Warnings:

  - You are about to drop the `AzkarProgress` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `AzkarTemplate` table. If the table is not empty, all the data it contains will be lost.

*/
-- CreateEnum
CREATE TYPE "FastingType" AS ENUM ('VOLUNTARY', 'RAMADAN', 'SUNNAH');

-- DropForeignKey
ALTER TABLE "public"."AzkarProgress" DROP CONSTRAINT "AzkarProgress_userId_fkey";

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "isAdmin" BOOLEAN NOT NULL DEFAULT false;

-- DropTable
DROP TABLE "public"."AzkarProgress";

-- DropTable
DROP TABLE "public"."AzkarTemplate";

-- CreateTable
CREATE TABLE "AzkarGroup" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "nameAr" TEXT NOT NULL,
    "description" TEXT,
    "icon" TEXT,
    "color" TEXT,
    "category" "AzkarCategory" NOT NULL,
    "order" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AzkarGroup_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Azkar" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "titleAr" TEXT NOT NULL,
    "arabicText" TEXT NOT NULL,
    "translation" TEXT NOT NULL,
    "transliteration" TEXT,
    "targetCount" INTEGER NOT NULL DEFAULT 1,
    "xpReward" INTEGER NOT NULL DEFAULT 10,
    "coinsReward" INTEGER NOT NULL DEFAULT 5,
    "order" INTEGER NOT NULL DEFAULT 0,
    "reference" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Azkar_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AzkarCompletion" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "azkarId" TEXT NOT NULL,
    "completedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "xpEarned" INTEGER NOT NULL,
    "coinsEarned" INTEGER NOT NULL,

    CONSTRAINT "AzkarCompletion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FastingCompletion" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "fastingType" "FastingType" NOT NULL DEFAULT 'VOLUNTARY',
    "completedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "xpEarned" INTEGER NOT NULL DEFAULT 100,
    "coinsEarned" INTEGER NOT NULL DEFAULT 50,

    CONSTRAINT "FastingCompletion_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "AzkarGroup_category_idx" ON "AzkarGroup"("category");

-- CreateIndex
CREATE INDEX "AzkarGroup_order_idx" ON "AzkarGroup"("order");

-- CreateIndex
CREATE INDEX "Azkar_groupId_idx" ON "Azkar"("groupId");

-- CreateIndex
CREATE INDEX "Azkar_order_idx" ON "Azkar"("order");

-- CreateIndex
CREATE INDEX "AzkarCompletion_userId_idx" ON "AzkarCompletion"("userId");

-- CreateIndex
CREATE INDEX "AzkarCompletion_azkarId_idx" ON "AzkarCompletion"("azkarId");

-- CreateIndex
CREATE INDEX "AzkarCompletion_completedAt_idx" ON "AzkarCompletion"("completedAt");

-- CreateIndex
CREATE UNIQUE INDEX "AzkarCompletion_userId_azkarId_key" ON "AzkarCompletion"("userId", "azkarId");

-- CreateIndex
CREATE INDEX "FastingCompletion_userId_idx" ON "FastingCompletion"("userId");

-- CreateIndex
CREATE INDEX "FastingCompletion_date_idx" ON "FastingCompletion"("date");

-- CreateIndex
CREATE INDEX "FastingCompletion_userId_date_idx" ON "FastingCompletion"("userId", "date");

-- CreateIndex
CREATE UNIQUE INDEX "FastingCompletion_userId_date_key" ON "FastingCompletion"("userId", "date");

-- AddForeignKey
ALTER TABLE "Azkar" ADD CONSTRAINT "Azkar_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "AzkarGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AzkarCompletion" ADD CONSTRAINT "AzkarCompletion_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AzkarCompletion" ADD CONSTRAINT "AzkarCompletion_azkarId_fkey" FOREIGN KEY ("azkarId") REFERENCES "Azkar"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FastingCompletion" ADD CONSTRAINT "FastingCompletion_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
