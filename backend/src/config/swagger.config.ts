import { INestApplication } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

const defaultSwaggerPath = 'docs';

export function isSwaggerEnabled(): boolean {
  const rawValue = process.env.SWAGGER_ENABLED?.trim().toLowerCase();

  if (process.env.NODE_ENV === 'production') {
    return rawValue === 'true';
  }

  return rawValue === undefined ? true : rawValue === 'true';
}

export function getSwaggerPath(): string {
  return process.env.SWAGGER_PATH?.trim() || defaultSwaggerPath;
}

export function setupSwagger(app: INestApplication): void {
  if (!isSwaggerEnabled()) {
    return;
  }

  const config = new DocumentBuilder()
    .setTitle('QISHLOQ AI Backend API')
    .setDescription(
      'Agro marketplace, listing, complaint, admin moderation and AI advisory API',
    )
    .setVersion('1.0.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup(getSwaggerPath(), app, document);
}
