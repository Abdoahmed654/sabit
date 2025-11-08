/*
  Warnings:

  - A unique constraint covering the columns `[userId,azkarId,date]` on the table `AzkarCompletion` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `date` to the `AzkarCompletion` table without a default value. This is not possible if the table is not empty.

*/
-- DropIndex
DROP INDEX "public"."AzkarCompletion_completedAt_idx";

-- DropIndex
DROP INDEX "public"."AzkarCompletion_userId_azkarId_key";

-- AlterTable
ALTER TABLE "AzkarCompletion" ADD COLUMN     "date" TIMESTAMP(3) NOT NULL;

-- CreateIndex
CREATE INDEX "AzkarCompletion_date_idx" ON "AzkarCompletion"("date");

-- CreateIndex
CREATE INDEX "AzkarCompletion_userId_date_idx" ON "AzkarCompletion"("userId", "date");

-- CreateIndex
CREATE UNIQUE INDEX "AzkarCompletion_userId_azkarId_date_key" ON "AzkarCompletion"("userId", "azkarId", "date");
