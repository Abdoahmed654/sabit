import { IsNotEmpty, IsEnum, IsOptional, IsString, IsInt, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { DailyActionType } from '@prisma/client';

export class RecordActionDto {
  @ApiProperty({ enum: DailyActionType })
  @IsEnum(DailyActionType)
  actionType: DailyActionType;

  @ApiPropertyOptional()
  @IsOptional()
  metadata?: any;

  @ApiPropertyOptional({
    description: 'Challenge task ID if this action is for a challenge',
  })
  @IsOptional()
  @IsString()
  taskId?: string;

  @ApiPropertyOptional({
    description: 'Count for counter-based actions (e.g., Azkar count)',
    default: 1,
  })
  @IsOptional()
  @IsInt()
  @Min(1)
  count?: number;
}

