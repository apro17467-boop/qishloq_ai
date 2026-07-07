import { mkdirSync } from 'fs';
import { extname } from 'path';
import { randomUUID } from 'crypto';

const imageMimeTypeExtensions: Record<string, string> = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
};

export function ensureUploadDir(dir: string): void {
  mkdirSync(dir, { recursive: true });
}

export function generateSafeFileName(
  originalName: string,
  mimeType?: string,
): string {
  const extension =
    (mimeType ? imageMimeTypeExtensions[mimeType] : undefined) ??
    normalizeExtension(extname(originalName));

  return `${Date.now()}-${randomUUID()}${extension}`;
}

export function isAllowedImageMimeType(mimeType: string): boolean {
  return Object.prototype.hasOwnProperty.call(imageMimeTypeExtensions, mimeType);
}

function normalizeExtension(extension: string): string {
  const safeExtension = extension.toLowerCase();

  return ['.jpg', '.jpeg', '.png', '.webp'].includes(safeExtension)
    ? safeExtension.replace('.jpeg', '.jpg')
    : '';
}
