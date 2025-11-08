import { IsEnum, IsBoolean, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { PrayerName } from '@prisma/client';

export class CompletePrayerDto {
  @ApiProperty({ 
    enum: PrayerName,
    description: 'Name of the prayer (FAJR, DHUHR, ASR, MAGHRIB, ISHA)'
  })
  @IsEnum(PrayerName)
  prayerName: PrayerName;

  @ApiPropertyOptional({
    description: 'Whether the prayer was completed on time',
    default: false,
  })
  @IsOptional()
  @IsBoolean()
  onTime?: boolean;
}

