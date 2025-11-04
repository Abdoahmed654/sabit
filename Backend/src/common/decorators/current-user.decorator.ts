import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export interface CurrentUserType {
  id: string | number;
  email?: string;
  refreshToken?: string;
  [key: string]: unknown;
}

export const CurrentUser = createParamDecorator(
  (data: unknown, ctx: ExecutionContext): CurrentUserType | undefined => {
    const request = ctx.switchToHttp().getRequest<{ user?: CurrentUserType }>();
    return request.user;
  },
);
