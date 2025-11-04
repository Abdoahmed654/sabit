import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { EventEmitterModule } from '@nestjs/event-emitter';
import { ThrottlerModule } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { ShopModule } from './modules/shop/shop.module';
import { ChallengesModule } from './modules/challenges/challenges.module';
import { ChatModule } from './modules/chat/chat.module';
import { LeaderboardsModule } from './modules/leaderboards/leaderboards.module';
import { BadgesModule } from './modules/badges/badges.module';
import { DailyModule } from './modules/daily/daily.module';
import { AdminModule } from './modules/admin/admin.module';
import { JwtAuthGuard } from './common/guards';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    EventEmitterModule.forRoot(),
    ThrottlerModule.forRoot([{
      ttl: 60000,
      limit: 10,
    }]),
    PrismaModule,
    AuthModule,
    UsersModule,
    ShopModule,
    ChallengesModule,
    ChatModule,
    LeaderboardsModule,
    BadgesModule,
    DailyModule,
    AdminModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
  ],
})
export class AppModule {}
