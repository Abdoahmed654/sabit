import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AddMemberDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  userId: string;
}

