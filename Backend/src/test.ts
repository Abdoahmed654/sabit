import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable, tap } from 'rxjs';
import { AppLogger } from './AppLogger';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  constructor(private readonly logger: AppLogger) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const req = context.switchToHttp().getRequest();
    const { method, url } = req;
    const now = Date.now();

    this.logger.log(`➡️  ${method} ${url}`, 'HTTP');

    return next.handle().pipe(
      tap(() =>
        this.logger.log(
          `⬅️  ${method} ${url} (${Date.now() - now}ms)`,
          req.headers["Authorization"]  || "No Auth",
        ),
      ),
    );
  }
}
