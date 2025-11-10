import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { ShopModule } from '../shop/shop.module';

@Module({
  imports: [ShopModule],
  controllers: [AdminController],
})
export class AdminModule {}

