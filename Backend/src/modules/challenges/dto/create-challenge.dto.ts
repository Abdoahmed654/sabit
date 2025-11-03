import { IsNotEmpty, IsString, IsInt, IsBoolean, IsDateString, IsOptional, Min, IsArray, ValidateNested } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { TaskType } from '@prisma/client';

export class CreateChallengeTaskDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  title: string;

  @ApiProperty({ enum: TaskType })
  @IsNotEmpty()
  type: TaskType;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(1)
  goalCount?: number;

  @ApiPropertyOptional({ default: 10 })
  @IsOptional()
  @IsInt()
  @Min(1)
  points?: number;

  @ApiPropertyOptional()
  @IsOptional()
  params?: any;
}

export class CreateChallengeDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  title: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  description: string;

  @ApiProperty()
  @IsDateString()
  startAt: string;

  @ApiProperty()
  @IsDateString()
  endAt: string;

  @ApiProperty()
  @IsInt()
  @Min(0)
  rewardXp: number;

  @ApiProperty()
  @IsInt()
  @Min(0)
  rewardCoins: number;

  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @IsBoolean()
  isGlobal?: boolean;

  @ApiProperty({ type: [CreateChallengeTaskDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateChallengeTaskDto)
  tasks: CreateChallengeTaskDto[];
}

