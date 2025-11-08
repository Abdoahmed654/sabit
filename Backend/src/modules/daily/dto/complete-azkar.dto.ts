import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CompleteAzkarDto {
  @ApiProperty({
    description: 'Azkar ID to complete',
  })
  @IsString()
  azkarId: string;
}

