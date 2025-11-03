import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class EquipItemDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  userItemId: string;
}

