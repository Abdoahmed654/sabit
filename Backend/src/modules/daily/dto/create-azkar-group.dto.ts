import { IsString, IsEnum, IsOptional, IsInt, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { AzkarCategory } from '@prisma/client';

export class CreateAzkarGroupDto {
  @ApiProperty({
    description: 'Group name in English',
    example: 'Morning Azkar',
  })
  @IsString()
  name: string;

  @ApiProperty({
    description: 'Group name in Arabic',
    example: 'أذكار الصباح',
  })
  @IsString()
  nameAr: string;

  @ApiPropertyOptional({
    description: 'Group description',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({
    description: 'Icon name or emoji',
    example: '🌅',
  })
  @IsOptional()
  @IsString()
  icon?: string;

  @ApiPropertyOptional({
    description: 'Hex color code',
    example: '#FF9800',
  })
  @IsOptional()
  @IsString()
  color?: string;

  @ApiProperty({
    enum: AzkarCategory,
    description: 'Category of the azkar group',
  })
  @IsEnum(AzkarCategory)
  category: AzkarCategory;

  @ApiPropertyOptional({
    description: 'Display order',
    default: 0,
  })
  @IsOptional()
  @IsInt()
  @Min(0)
  order?: number;
}

