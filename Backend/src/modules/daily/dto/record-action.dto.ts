import { IsNotEmpty, IsEnum, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { DailyActionType } from '@prisma/client';

export class RecordActionDto {
  @ApiProperty({ enum: DailyActionType })
  @IsEnum(DailyActionType)
  actionType: DailyActionType;

  @ApiPropertyOptional()
  @IsOptional()
  metadata?: any;
}

