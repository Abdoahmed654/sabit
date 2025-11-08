-- AlterTable
ALTER TABLE "ChatGroup" ADD COLUMN     "challengeId" TEXT;

-- CreateIndex
CREATE INDEX "ChatGroup_challengeId_idx" ON "ChatGroup"("challengeId");
