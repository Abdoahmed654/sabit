import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SendMessageDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  groupId: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  content: string;
}

