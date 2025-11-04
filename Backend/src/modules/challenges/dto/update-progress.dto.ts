import { IsNotEmpty, IsString, IsInt, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateProgressDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  taskId: string;

  @ApiProperty()
  @IsInt()
  @Min(1)
  increment: number;
}

