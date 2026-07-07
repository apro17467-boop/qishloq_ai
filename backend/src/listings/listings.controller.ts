import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  ApiBearerAuth,
  ApiBody,
  ApiConsumes,
  ApiTags,
} from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../auth/types/authenticated-user.type';
import { CreateListingDto } from './dto/create-listing.dto';
import { ListListingsQueryDto } from './dto/list-listings-query.dto';
import { MyListingsQueryDto } from './dto/my-listings-query.dto';
import { UpdateListingDto } from './dto/update-listing.dto';
import {
  ArchiveListingResponse,
  CreateListingResponse,
  ListingDetailResponse,
  ListingsListResponse,
  MyListingsResponse,
  ListingsService,
  UploadListingImageResponse,
  UpdateListingResponse,
} from './listings.service';
import { isAllowedImageMimeType } from './utils/file-upload.util';

const defaultMaxImageSizeMb = 5;

function getMaxImageSizeBytes(): number {
  const maxImageSizeMb = Number(
    process.env.MAX_IMAGE_SIZE_MB ?? defaultMaxImageSizeMb,
  );
  const safeMaxImageSizeMb =
    Number.isFinite(maxImageSizeMb) && maxImageSizeMb > 0
      ? maxImageSizeMb
      : defaultMaxImageSizeMb;

  return safeMaxImageSizeMb * 1024 * 1024;
}

@Controller('listings')
@ApiTags('Listings')
export class ListingsController {
  constructor(private readonly listingsService: ListingsService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  createListing(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateListingDto,
  ): Promise<CreateListingResponse> {
    return this.listingsService.createListing(user.sub, dto);
  }

  @Get()
  getListings(
    @Query() query: ListListingsQueryDto,
  ): Promise<ListingsListResponse> {
    return this.listingsService.getListings(query);
  }

  @Get('my')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  getMyListings(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: MyListingsQueryDto,
  ): Promise<MyListingsResponse> {
    return this.listingsService.getMyListings(user.sub, query);
  }

  @Post(':id/images')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      required: ['image'],
      properties: {
        image: {
          type: 'string',
          format: 'binary',
        },
      },
    },
  })
  @UseInterceptors(
    FileInterceptor('image', {
      limits: {
        fileSize: getMaxImageSizeBytes(),
      },
      fileFilter: (_request, file, callback) => {
        if (!isAllowedImageMimeType(file.mimetype)) {
          callback(
            new BadRequestException('Only jpeg, png and webp images are allowed'),
            false,
          );
          return;
        }

        callback(null, true);
      },
    }),
  )
  addListingImage(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) id: string,
    @UploadedFile() file?: Express.Multer.File,
  ): Promise<UploadListingImageResponse> {
    if (!file) {
      throw new BadRequestException('Image file is required');
    }

    return this.listingsService.addListingImage(user.sub, id, {
      originalName: file.originalname,
      mimeType: file.mimetype,
      buffer: file.buffer,
      size: file.size,
    });
  }

  @Patch(':id/archive')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  archiveListing(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) id: string,
  ): Promise<ArchiveListingResponse> {
    return this.listingsService.archiveListing(user.sub, id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  updateListing(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) id: string,
    @Body() dto: UpdateListingDto,
  ): Promise<UpdateListingResponse> {
    return this.listingsService.updateListing(user.sub, id, dto);
  }

  @Get(':id')
  getListingById(
    @Param('id', new ParseUUIDPipe()) id: string,
  ): Promise<ListingDetailResponse> {
    return this.listingsService.getListingById(id);
  }
}
