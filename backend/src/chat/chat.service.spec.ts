import { ChatService } from './chat.service';
import { PrismaService } from '../database/prisma.service';
import { ListingStatus } from '@prisma/client';
import {
  BadRequestException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';

describe('ChatService', () => {
  function createService(mocks: any = {}) {
    const prisma = {
      listing: {
        findUnique: jest.fn().mockResolvedValue(
          mocks.listing || {
            id: 'listing-1',
            ownerId: 'seller-1',
            status: ListingStatus.ACTIVE,
            title: 'MTZ Traktor',
            priceAmount: '100000',
            priceCurrency: 'UZS',
          },
        ),
      },
      conversation: {
        findUnique: jest.fn().mockResolvedValue(mocks.conversation || null),
        create: jest.fn().mockResolvedValue(
          mocks.createdConversation || {
            id: 'conv-1',
            listingId: 'listing-1',
            buyerId: 'buyer-1',
            sellerId: 'seller-1',
            createdAt: new Date(),
            updatedAt: new Date(),
            messages: [],
            listing: {
              id: 'listing-1',
              title: 'MTZ Traktor',
              priceAmount: '100000',
              priceCurrency: 'UZS',
            },
            buyer: { id: 'buyer-1', profile: { fullName: 'Buyer Name' } },
            seller: { id: 'seller-1', profile: { fullName: 'Seller Name' } },
          },
        ),
        findMany: jest.fn().mockResolvedValue(mocks.conversationsList || []),
        count: jest.fn().mockResolvedValue(mocks.conversationsCount || 0),
        update: jest.fn().mockResolvedValue({}),
      },
      message: {
        count: jest.fn().mockResolvedValue(mocks.messagesCount || 0),
        findMany: jest.fn().mockResolvedValue(mocks.messagesList || []),
        create: jest.fn().mockResolvedValue(
          mocks.createdMessage || {
            id: 'msg-1',
            conversationId: 'conv-1',
            senderId: 'buyer-1',
            body: 'Hello',
            createdAt: new Date(),
            readAt: null,
          },
        ),
        updateMany: jest.fn().mockResolvedValue({ count: 0 }),
      },
    };

    return {
      prisma,
      service: new ChatService(prisma as unknown as PrismaService),
    };
  }

  describe('createConversation', () => {
    it('throws BadRequestException if listing is owned by current user (self-chat)', async () => {
      const { service } = createService({
        listing: {
          id: 'listing-1',
          ownerId: 'buyer-1',
          status: ListingStatus.ACTIVE,
        },
      });

      await expect(
        service.createConversation('buyer-1', { listingId: 'listing-1' }),
      ).rejects.toThrow(BadRequestException);
    });

    it('throws BadRequestException if listing is not ACTIVE', async () => {
      const { service } = createService({
        listing: {
          id: 'listing-1',
          ownerId: 'seller-1',
          status: ListingStatus.PENDING,
        },
      });

      await expect(
        service.createConversation('buyer-1', { listingId: 'listing-1' }),
      ).rejects.toThrow(BadRequestException);
    });

    it('returns existing conversation if it already exists (idempotency)', async () => {
      const existingConv = {
        id: 'conv-1',
        listingId: 'listing-1',
        buyerId: 'buyer-1',
        sellerId: 'seller-1',
        createdAt: new Date(),
        updatedAt: new Date(),
        messages: [],
        listing: {
          id: 'listing-1',
          title: 'MTZ Traktor',
          priceAmount: '100000',
          priceCurrency: 'UZS',
        },
        buyer: { id: 'buyer-1', profile: { fullName: 'Buyer Name' } },
        seller: { id: 'seller-1', profile: { fullName: 'Seller Name' } },
      };

      const { service, prisma } = createService({
        conversation: existingConv,
      });

      const response = await service.createConversation('buyer-1', {
        listingId: 'listing-1',
      });

      expect(response.data.id).toBe('conv-1');
      expect(prisma.conversation.create).not.toHaveBeenCalled();
    });

    it('creates and returns a new conversation if it does not exist', async () => {
      const { service, prisma } = createService({
        conversation: null, // None exists yet
      });

      const response = await service.createConversation('buyer-1', {
        listingId: 'listing-1',
      });

      expect(response.data.id).toBe('conv-1');
      expect(prisma.conversation.create).toHaveBeenCalled();
    });
  });

  describe('getMessages', () => {
    it('throws NotFoundException if conversation does not exist', async () => {
      const { service } = createService({
        conversation: null,
      });

      await expect(
        service.getMessages('buyer-1', 'conv-nonexistent', { page: 1, limit: 30 }),
      ).rejects.toThrow(NotFoundException);
    });

    it('throws ForbiddenException if current user is not a participant', async () => {
      const { service } = createService({
        conversation: {
          id: 'conv-1',
          buyerId: 'buyer-1',
          sellerId: 'seller-1',
        },
      });

      await expect(
        service.getMessages('stranger-1', 'conv-1', { page: 1, limit: 30 }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('returns messages and triggers readAt updates for the other user', async () => {
      const { service, prisma } = createService({
        conversation: {
          id: 'conv-1',
          buyerId: 'buyer-1',
          sellerId: 'seller-1',
        },
        messagesList: [
          {
            id: 'msg-1',
            conversationId: 'conv-1',
            senderId: 'seller-1',
            body: 'Hi buyer',
            createdAt: new Date(),
            readAt: null,
          },
        ],
      });

      const response = await service.getMessages('buyer-1', 'conv-1', {
        page: 1,
        limit: 30,
      });

      expect(response.data).toHaveLength(1);
      expect((response.data as any)[0].body).toBe('Hi buyer');
      expect(prisma.message.updateMany).toHaveBeenCalledWith({
        where: {
          conversationId: 'conv-1',
          senderId: { not: 'buyer-1' },
          readAt: null,
        },
        data: {
          readAt: expect.any(Date),
        },
      });
    });
  });

  describe('sendMessage', () => {
    it('throws ForbiddenException if sending message to a conversation you do not belong to', async () => {
      const { service } = createService({
        conversation: {
          id: 'conv-1',
          buyerId: 'buyer-1',
          sellerId: 'seller-1',
        },
      });

      await expect(
        service.sendMessage('stranger-1', 'conv-1', { body: 'Hello!' }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('creates message and updates conversation timestamp', async () => {
      const { service, prisma } = createService({
        conversation: {
          id: 'conv-1',
          buyerId: 'buyer-1',
          sellerId: 'seller-1',
        },
      });

      const response = await service.sendMessage('buyer-1', 'conv-1', {
        body: 'Hello seller',
      });

      expect(response.data!.body).toBe('Hello');
      expect(prisma.message.create).toHaveBeenCalledWith({
        data: {
          conversationId: 'conv-1',
          senderId: 'buyer-1',
          body: 'Hello seller',
        },
      });
      expect(prisma.conversation.update).toHaveBeenCalledWith({
        where: { id: 'conv-1' },
        data: { updatedAt: expect.any(Date) },
      });
    });
  });
});
