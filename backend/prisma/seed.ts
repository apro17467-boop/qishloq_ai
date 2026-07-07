import { ListingType, PrismaClient, RegionType } from '@prisma/client';

const prisma = new PrismaClient();

const categories = [
  {
    nameUz: 'Texnika ijarasi',
    nameRu: 'Аренда техники',
    slug: 'texnika-ijarasi',
    type: ListingType.MACHINERY_RENT,
    sortOrder: 10,
    isActive: true,
  },
  {
    nameUz: 'Dehqon mahsulotlari',
    nameRu: 'Сельхозпродукция',
    slug: 'dehqon-mahsulotlari',
    type: ListingType.PRODUCT_SALE,
    sortOrder: 20,
    isActive: true,
  },
  {
    nameUz: 'Chorva savdosi',
    nameRu: 'Продажа скота',
    slug: 'chorva-savdosi',
    type: ListingType.LIVESTOCK_SALE,
    sortOrder: 30,
    isActive: true,
  },
  {
    nameUz: 'Texnika savdosi',
    nameRu: 'Продажа техники',
    slug: 'texnika-savdosi',
    type: ListingType.MACHINERY_SALE,
    sortOrder: 40,
    isActive: true,
  },
  {
    nameUz: 'Agro xizmatlar',
    nameRu: 'Агроуслуги',
    slug: 'agro-xizmatlar',
    type: ListingType.SERVICE,
    sortOrder: 50,
    isActive: true,
  },
];

type RegionSeedInput = {
  nameUz: string;
  nameRu: string;
  type: RegionType;
  parentId: string | null;
};

async function seedCategories(): Promise<number> {
  for (const category of categories) {
    await prisma.category.upsert({
      where: { slug: category.slug },
      update: {
        nameUz: category.nameUz,
        nameRu: category.nameRu,
        type: category.type,
        sortOrder: category.sortOrder,
        isActive: category.isActive,
      },
      create: category,
    });
  }

  return categories.length;
}

async function seedRegion(region: RegionSeedInput) {
  const existingRegion = await prisma.region.findFirst({
    where: {
      nameUz: region.nameUz,
      type: region.type,
      parentId: region.parentId,
    },
  });

  if (existingRegion) {
    return prisma.region.update({
      where: {
        id: existingRegion.id,
      },
      data: {
        nameRu: region.nameRu,
        parentId: region.parentId,
      },
    });
  }

  return prisma.region.create({
    data: region,
  });
}

async function seedRegions(): Promise<number> {
  const province = await seedRegion({
    nameUz: 'Samarqand viloyati',
    nameRu: 'Самаркандская область',
    type: RegionType.PROVINCE,
    parentId: null,
  });

  await seedRegion({
    nameUz: 'Oqdaryo tumani',
    nameRu: 'Акдарьинский район',
    type: RegionType.DISTRICT,
    parentId: province.id,
  });

  return 2;
}

async function main(): Promise<void> {
  const seededCategoriesCount = await seedCategories();
  const seededRegionsCount = await seedRegions();

  console.log(`Seeded ${seededCategoriesCount} categories.`);
  console.log(`Seeded ${seededRegionsCount} regions.`);
}

main()
  .catch((error) => {
    console.error('Seed failed:', error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
