import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class BuyItemDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  itemId: string;
}

