import { Controller, Post, Body } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ShopService } from '../shop/shop.service';
import { CreateItemDto } from '../shop/dto';

@ApiTags('admin')
@ApiBearerAuth()
@Controller('admin')
export class AdminController {
  constructor(
    private shopService: ShopService,
  ) {}

  // Items Management
  @Post('items')
  @ApiOperation({ summary: 'Create a new item' })
  async createItem(@Body() dto: CreateItemDto) {
    return this.shopService.createItem(dto);
  }
}

