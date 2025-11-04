import { IsNotEmpty, IsString, IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { GroupType } from '@prisma/client';

export class CreateGroupDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiProperty({ enum: GroupType })
  @IsEnum(GroupType)
  type: GroupType;
}

