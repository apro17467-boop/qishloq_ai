import { PrismaService } from '../database/prisma.service';
import { SellersService } from './sellers.service';

describe('SellersService', () => {
  const createdAt = new Date('2026-07-07T10:00:00.000Z');

  function createService() {
    const prisma = {
      user: {
        findFirst: jest.fn().mockResolvedValue({
          id: 'seller-1',
          role: 'FARMER',
          isVerified: true,
          createdAt,
          profile: {
            fullName: 'Ali Valiyev',
            address: 'Oqdaryo tumani',
            region: {
              id: 'region-1',
              nameUz: 'Samarqand viloyati',
            },
          },
        }),
      },
      listing: {
        count: jest.fn().mockResolvedValue(1),
        findMany: jest.fn().mockResolvedValue([
          {
            id: 'listing-1',
            type: 'PRODUCT_SALE',
            status: 'ACTIVE',
            title: 'Pomidor',
            description: null,
            priceAmount: {
              toString: () => '10000',
            },
            priceCurrency: 'UZS',
            unit: 'kg',
            contactPhone: '+998901234567',
            address: 'Oqdaryo tumani',
            viewCount: 0,
            createdAt,
            category: {
              id: 'category-1',
              nameUz: 'Dehqon mahsulotlari',
              slug: 'dehqon-mahsulotlari',
            },
            region: {
              id: 'region-1',
              nameUz: 'Oqdaryo tumani',
              type: 'DISTRICT',
            },
            images: [],
          },
        ]),
      },
      favorite: {
        findMany: jest.fn().mockResolvedValue([
          {
            listingId: 'listing-1',
          },
        ]),
      },
      $transaction: jest.fn(async (queries: Promise<unknown>[]) =>
        Promise.all(queries),
      ),
    };

    return {
      prisma,
      service: new SellersService(prisma as unknown as PrismaService),
    };
  }

  it('returns public seller profile without private fields', async () => {
    const { prisma, service } = createService();

    await expect(service.getSellerProfile('seller-1')).resolves.toEqual({
      data: {
        id: 'seller-1',
        fullName: 'Ali Valiyev',
        role: 'FARMER',
        region: {
          id: 'region-1',
          nameUz: 'Samarqand viloyati',
        },
        address: 'Oqdaryo tumani',
        isVerified: true,
        activeListingsCount: 1,
        createdAt,
      },
    });

    expect(prisma.user.findFirst).toHaveBeenCalledWith({
      where: {
        id: 'seller-1',
        isActive: true,
      },
      select: expect.any(Object),
    });
  });

  it('returns active seller listings with favorite state', async () => {
    const { service } = createService();

    await expect(
      service.getSellerListings('seller-1', { page: 1, limit: 10 }, 'user-1'),
    ).resolves.toMatchObject({
      data: [
        {
          id: 'listing-1',
          priceAmount: '10000',
          isFavorite: true,
        },
      ],
      meta: {
        page: 1,
        limit: 10,
        total: 1,
        totalPages: 1,
      },
    });
  });

  it('throws when seller does not exist', async () => {
    const { prisma, service } = createService();
    prisma.user.findFirst.mockResolvedValueOnce(null);

    await expect(service.getSellerProfile('missing-seller')).rejects.toThrow(
      'Seller not found',
    );
  });
});
