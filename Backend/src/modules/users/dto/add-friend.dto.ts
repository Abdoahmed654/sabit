import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AddFriendDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  friendId: string;
}

