import { IsString, IsInt, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateAzkarDto {
  @ApiProperty({
    description: 'Azkar template ID',
  })
  @IsString()
  azkarId: string;

  @ApiProperty({
    description: 'Number of times recited (increment)',
    minimum: 1,
  })
  @IsInt()
  @Min(1)
  count: number;
}

