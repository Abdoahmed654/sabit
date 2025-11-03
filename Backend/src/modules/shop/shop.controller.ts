import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ShopService } from './shop.service';
import { CreateItemDto, BuyItemDto, EquipItemDto } from './dto';
import { CurrentUser, Public } from '../../common';

@ApiTags('shop')
@Controller('shop')
export class ShopController {
  constructor(private shopService: ShopService) {}

  @Public()
  @Get('items')
  @ApiOperation({ summary: 'Get all shop items' })
  async getAllItems() {
    return this.shopService.getAllItems();
  }

  @Public()
  @Get('items/:id')
  @ApiOperation({ summary: 'Get item by ID' })
  async getItemById(@Param('id') id: string) {
    return this.shopService.getItemById(id);
  }

  @ApiBearerAuth()
  @Post('buy')
  @ApiOperation({ summary: 'Buy an item' })
  async buyItem(@CurrentUser() user: any, @Body() dto: BuyItemDto) {
    return this.shopService.buyItem(user.id, dto);
  }

  @ApiBearerAuth()
  @Post('equip')
  @ApiOperation({ summary: 'Equip an item' })
  async equipItem(@CurrentUser() user: any, @Body() dto: EquipItemDto) {
    return this.shopService.equipItem(user.id, dto);
  }

  @ApiBearerAuth()
  @Delete('unequip/:userItemId')
  @ApiOperation({ summary: 'Unequip an item' })
  async unequipItem(
    @CurrentUser() user: any,
    @Param('userItemId') userItemId: string,
  ) {
    return this.shopService.unequipItem(user.id, userItemId);
  }
}

