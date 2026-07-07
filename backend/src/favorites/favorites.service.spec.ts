import { FavoritesService } from './favorites.service';
import { PrismaService } from '../database/prisma.service';

describe('FavoritesService', () => {
  function createService() {
    const prisma = {
      user: {
        findUnique: jest.fn().mockResolvedValue({
          id: 'user-1',
          isActive: true,
        }),
      },
      listing: {
        findFirst: jest.fn().mockResolvedValue({
          id: 'listing-1',
        }),
      },
      favorite: {
        upsert: jest.fn().mockResolvedValue({}),
        findMany: jest.fn().mockResolvedValue([
          {
            listingId: 'listing-1',
          },
          {
            listingId: 'listing-2',
          },
        ]),
      },
    };

    return {
      prisma,
      service: new FavoritesService(prisma as unknown as PrismaService),
    };
  }

  it('adds a favorite idempotently', async () => {
    const { prisma, service } = createService();

    await expect(service.addFavorite('user-1', 'listing-1')).resolves.toEqual({
      success: true,
      message: 'E’lon sevimlilarga qo‘shildi',
    });

    expect(prisma.favorite.upsert).toHaveBeenCalledWith({
      where: {
        userId_listingId: {
          userId: 'user-1',
          listingId: 'listing-1',
        },
      },
      update: {},
      create: {
        userId: 'user-1',
        listingId: 'listing-1',
      },
    });
  });

  it('returns current user favorite listing ids', async () => {
    const { service } = createService();

    await expect(service.getFavoriteIds('user-1')).resolves.toEqual({
      data: ['listing-1', 'listing-2'],
    });
  });
});
