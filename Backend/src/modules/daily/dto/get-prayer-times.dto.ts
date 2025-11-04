import { IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class GetPrayerTimesDto {
  @ApiProperty({ description: 'Latitude', example: 21.3891 })
  @IsNotEmpty()
  @Type(() => Number)
  latitude: number;

  @ApiProperty({ description: 'Longitude', example: 39.8579 })
  @IsNotEmpty()
  @Type(() => Number)
  longitude: number;

  @ApiPropertyOptional({ description: 'Date in DD-MM-YYYY format', example: '03-11-2025' })
  @IsOptional()
  @IsString()
  date?: string;

  @ApiPropertyOptional({ description: 'Calculation method (0-15)', example: 4, default: 4 })
  @IsOptional()
  @Type(() => Number)
  method?: number;
}

