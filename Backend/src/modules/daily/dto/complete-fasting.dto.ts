import { IsEnum, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { FastingType } from '@prisma/client';

export class CompleteFastingDto {
  @ApiPropertyOptional({
    enum: FastingType,
    description: 'Type of fasting',
    default: 'VOLUNTARY',
  })
  @IsOptional()
  @IsEnum(FastingType)
  fastingType?: FastingType;
}

