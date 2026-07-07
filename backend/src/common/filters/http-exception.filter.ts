import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Request, Response } from 'express';

interface ErrorResponseBody {
  success: false;
  error: {
    code: string;
    message: string;
    details: string[];
  };
  statusCode: number;
  path: string;
  timestamp: string;
}

interface HttpExceptionResponse {
  message?: string | string[];
  error?: string;
  statusCode?: number;
}

interface MulterLikeException {
  code?: string;
  message?: string;
  status?: number;
  statusCode?: number;
}

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost): void {
    const context = host.switchToHttp();
    const request = context.getRequest<Request>();
    const response = context.getResponse<Response>();

    const statusCode = this.getStatusCode(exception);
    const normalizedError = this.normalizeError(exception, statusCode);

    const body: ErrorResponseBody = {
      success: false,
      error: normalizedError,
      statusCode,
      path: request.url,
      timestamp: new Date().toISOString(),
    };

    response.status(statusCode).json(body);
  }

  private normalizeError(
    exception: unknown,
    statusCode: number,
  ): ErrorResponseBody['error'] {
    const exceptionResponse = this.getExceptionResponse(exception);

    if (this.isValidationError(exceptionResponse, statusCode)) {
      return {
        code: 'VALIDATION_ERROR',
        message: 'Validation failed',
        details: this.toDetails(exceptionResponse.message),
      };
    }

    if (this.isPayloadTooLarge(exception, statusCode)) {
      return {
        code: 'PAYLOAD_TOO_LARGE',
        message: this.getMessage(exceptionResponse, exception, 'Payload too large'),
        details: [],
      };
    }

    if (statusCode === HttpStatus.INTERNAL_SERVER_ERROR) {
      return {
        code: 'INTERNAL_SERVER_ERROR',
        message: 'Internal server error',
        details: [],
      };
    }

    return {
      code: this.getErrorCode(statusCode),
      message: this.getMessage(
        exceptionResponse,
        exception,
        'Request failed',
      ),
      details: [],
    };
  }

  private getStatusCode(exception: unknown): number {
    if (exception instanceof HttpException) {
      return exception.getStatus();
    }

    const multerException = this.getMulterLikeException(exception);

    if (multerException?.code === 'LIMIT_FILE_SIZE') {
      return HttpStatus.PAYLOAD_TOO_LARGE;
    }

    if (this.isPositiveStatusCode(multerException?.statusCode)) {
      return multerException.statusCode;
    }

    if (this.isPositiveStatusCode(multerException?.status)) {
      return multerException.status;
    }

    return HttpStatus.INTERNAL_SERVER_ERROR;
  }

  private getExceptionResponse(
    exception: unknown,
  ): HttpExceptionResponse | undefined {
    if (!(exception instanceof HttpException)) {
      return undefined;
    }

    const response = exception.getResponse();

    if (typeof response === 'string') {
      return {
        message: response,
      };
    }

    if (this.isRecord(response)) {
      return {
        message: this.getResponseMessage(response.message),
        error:
          typeof response.error === 'string' ? response.error : undefined,
        statusCode:
          typeof response.statusCode === 'number'
            ? response.statusCode
            : undefined,
      };
    }

    return undefined;
  }

  private getMessage(
    exceptionResponse: HttpExceptionResponse | undefined,
    exception: unknown,
    fallback: string,
  ): string {
    if (typeof exceptionResponse?.message === 'string') {
      return exceptionResponse.message;
    }

    if (Array.isArray(exceptionResponse?.message)) {
      return exceptionResponse.message[0] ?? fallback;
    }

    const multerException = this.getMulterLikeException(exception);

    if (typeof multerException?.message === 'string') {
      return multerException.message;
    }

    if (exception instanceof Error && exception.message) {
      return exception.message;
    }

    return fallback;
  }

  private getErrorCode(statusCode: number): string {
    switch (statusCode) {
      case HttpStatus.BAD_REQUEST:
        return 'BAD_REQUEST';
      case HttpStatus.UNAUTHORIZED:
        return 'UNAUTHORIZED';
      case HttpStatus.FORBIDDEN:
        return 'FORBIDDEN';
      case HttpStatus.NOT_FOUND:
        return 'NOT_FOUND';
      case HttpStatus.PAYLOAD_TOO_LARGE:
        return 'PAYLOAD_TOO_LARGE';
      case HttpStatus.TOO_MANY_REQUESTS:
        return 'TOO_MANY_REQUESTS';
      default:
        return statusCode >= 500 ? 'INTERNAL_SERVER_ERROR' : 'BAD_REQUEST';
    }
  }

  private isValidationError(
    exceptionResponse: HttpExceptionResponse | undefined,
    statusCode: number,
  ): exceptionResponse is HttpExceptionResponse & { message: string[] } {
    return (
      statusCode === HttpStatus.BAD_REQUEST &&
      Array.isArray(exceptionResponse?.message)
    );
  }

  private isPayloadTooLarge(exception: unknown, statusCode: number): boolean {
    return (
      statusCode === HttpStatus.PAYLOAD_TOO_LARGE ||
      this.getMulterLikeException(exception)?.code === 'LIMIT_FILE_SIZE'
    );
  }

  private toDetails(message: string | string[] | undefined): string[] {
    if (Array.isArray(message)) {
      return message;
    }

    return typeof message === 'string' ? [message] : [];
  }

  private getResponseMessage(value: unknown): string | string[] | undefined {
    if (typeof value === 'string') {
      return value;
    }

    if (Array.isArray(value)) {
      return value.filter((item): item is string => typeof item === 'string');
    }

    return undefined;
  }

  private getMulterLikeException(
    exception: unknown,
  ): MulterLikeException | undefined {
    return this.isRecord(exception) ? exception : undefined;
  }

  private isPositiveStatusCode(value: unknown): value is number {
    return typeof value === 'number' && value >= 400 && value <= 599;
  }

  private isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === 'object' && value !== null;
  }
}
