import { IsNotEmpty, IsString, IsInt, IsEnum, IsOptional, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ItemType, ItemRarity } from '@prisma/client';

export class CreateItemDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiProperty({ enum: ItemType })
  @IsEnum(ItemType)
  type: ItemType;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  imageUrl?: string;

  @ApiProperty()
  @IsInt()
  @Min(0)
  priceCoins: number;

  @ApiPropertyOptional({ default: 0 })
  @IsOptional()
  @IsInt()
  @Min(0)
  priceXp?: number;

  @ApiPropertyOptional({ enum: ItemRarity, default: ItemRarity.COMMON })
  @IsOptional()
  @IsEnum(ItemRarity)
  rarity?: ItemRarity;
}

