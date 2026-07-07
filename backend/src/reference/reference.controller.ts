import { Controller, Get } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import {
  CategoryReference,
  ReferenceResponse,
  ReferenceService,
  RegionReference,
} from './reference.service';

@Controller('reference')
@ApiTags('Reference')
export class ReferenceController {
  constructor(private readonly referenceService: ReferenceService) {}

  @Get('categories')
  getCategories(): Promise<ReferenceResponse<CategoryReference>> {
    return this.referenceService.getCategories();
  }

  @Get('regions')
  getRegions(): Promise<ReferenceResponse<RegionReference>> {
    return this.referenceService.getRegions();
  }
}
