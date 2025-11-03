import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { ShopModule } from '../shop/shop.module';
import { ChallengesModule } from '../challenges/challenges.module';
import { BadgesModule } from '../badges/badges.module';

@Module({
  imports: [ShopModule, ChallengesModule, BadgesModule],
  controllers: [AdminController],
})
export class AdminModule {}

