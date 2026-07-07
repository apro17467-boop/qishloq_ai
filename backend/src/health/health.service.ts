import { Injectable } from '@nestjs/common';

export interface HealthResponse {
  status: 'ok';
  service: 'qishloq-ai-backend';
}

@Injectable()
export class HealthService {
  getHealth(): HealthResponse {
    return {
      status: 'ok',
      service: 'qishloq-ai-backend',
    };
  }
}
