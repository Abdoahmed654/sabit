import { IsString, IsInt, Min, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateAzkarDto {
  @ApiProperty({
    description: 'Azkar group ID',
  })
  @IsString()
  groupId: string;

  @ApiProperty({
    description: 'Title in English',
    example: 'Seeking refuge in Allah',
  })
  @IsString()
  title: string;

  @ApiProperty({
    description: 'Title in Arabic',
    example: 'الاستعاذة بالله',
  })
  @IsString()
  titleAr: string;

  @ApiProperty({
    description: 'Arabic text of the azkar',
    example: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
  })
  @IsString()
  arabicText: string;

  @ApiProperty({
    description: 'English translation',
    example: 'I seek refuge in Allah from the accursed Satan',
  })
  @IsString()
  translation: string;

  @ApiPropertyOptional({
    description: 'Transliteration',
    example: 'A\'udhu billahi min ash-shaytanir-rajim',
  })
  @IsOptional()
  @IsString()
  transliteration?: string;

  @ApiProperty({
    description: 'Number of times to recite',
    default: 1,
    minimum: 1,
  })
  @IsInt()
  @Min(1)
  targetCount: number;

  @ApiProperty({
    description: 'XP reward for completion',
    default: 10,
    minimum: 1,
  })
  @IsInt()
  @Min(1)
  xpReward: number;

  @ApiProperty({
    description: 'Coins reward for completion',
    default: 5,
    minimum: 1,
  })
  @IsInt()
  @Min(1)
  coinsReward: number;

  @ApiPropertyOptional({
    description: 'Display order within group',
    default: 0,
  })
  @IsOptional()
  @IsInt()
  @Min(0)
  order?: number;

  @ApiPropertyOptional({
    description: 'Source reference (e.g., Hadith reference)',
  })
  @IsOptional()
  @IsString()
  reference?: string;
}

