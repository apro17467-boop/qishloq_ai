import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { CreateMessageDto } from './dto/create-message.dto';
import { ConversationsQueryDto } from './dto/conversations-query.dto';
import { MessagesQueryDto } from './dto/messages-query.dto';
import { ListingStatus } from '@prisma/client';

@Injectable()
export class ChatService {
  constructor(private readonly prisma: PrismaService) {}

  async createConversation(currentUserId: string, dto: CreateConversationDto) {
    const listing = await this.prisma.listing.findUnique({
      where: { id: dto.listingId },
    });

    if (!listing || listing.deletedAt) {
      throw new NotFoundException('Listing not found');
    }

    if (listing.status !== ListingStatus.ACTIVE) {
      throw new BadRequestException('Cannot start a conversation on a non-active listing');
    }

    if (listing.ownerId === currentUserId) {
      throw new BadRequestException('Cannot start a conversation with yourself');
    }

    // Try to find an existing conversation
    let conversation = await this.prisma.conversation.findUnique({
      where: {
        listingId_buyerId_sellerId: {
          listingId: dto.listingId,
          buyerId: currentUserId,
          sellerId: listing.ownerId,
        },
      },
      include: {
        listing: true,
        buyer: { include: { profile: true } },
        seller: { include: { profile: true } },
        messages: {
          orderBy: { createdAt: 'desc' },
          take: 1,
        },
      },
    });

    if (!conversation) {
      conversation = await this.prisma.conversation.create({
        data: {
          listingId: dto.listingId,
          buyerId: currentUserId,
          sellerId: listing.ownerId,
        },
        include: {
          listing: true,
          buyer: { include: { profile: true } },
          seller: { include: { profile: true } },
          messages: {
            orderBy: { createdAt: 'desc' },
            take: 1,
          },
        },
      });
    }

    const lastMessage = conversation.messages.length > 0 ? conversation.messages[0] : null;
    return {
      data: this.mapConversation(conversation, lastMessage, 0, currentUserId),
    };
  }

  async getMyConversations(currentUserId: string, query: ConversationsQueryDto) {
    const skip = (query.page - 1) * query.limit;
    const take = query.limit;

    const where = {
      OR: [
        { buyerId: currentUserId },
        { sellerId: currentUserId },
      ],
    };

    const total = await this.prisma.conversation.count({ where });
    const totalPages = Math.ceil(total / query.limit);

    const conversations = await this.prisma.conversation.findMany({
      where,
      orderBy: { updatedAt: 'desc' },
      skip,
      take,
      include: {
        listing: true,
        buyer: { include: { profile: true } },
        seller: { include: { profile: true } },
        messages: {
          orderBy: { createdAt: 'desc' },
          take: 1,
        },
      },
    });

    const mappedConversations = await Promise.all(
      conversations.map(async (conv: any) => {
        const lastMessage = conv.messages.length > 0 ? conv.messages[0] : null;
        const unreadCount = await this.prisma.message.count({
          where: {
            conversationId: conv.id,
            senderId: { not: currentUserId },
            readAt: null,
          },
        });
        return this.mapConversation(conv, lastMessage, unreadCount, currentUserId);
      }),
    );

    return {
      data: mappedConversations,
      meta: {
        page: query.page,
        limit: query.limit,
        total,
        totalPages,
      },
    };
  }

  async getMessages(currentUserId: string, conversationId: string, query: MessagesQueryDto) {
    const conversation = await this.prisma.conversation.findUnique({
      where: { id: conversationId },
    });

    if (!conversation) {
      throw new NotFoundException('Conversation not found');
    }

    if (conversation.buyerId !== currentUserId && conversation.sellerId !== currentUserId) {
      throw new ForbiddenException('You do not have access to this conversation');
    }

    // Trigger update of unread messages from the other user
    await this.prisma.message.updateMany({
      where: {
        conversationId,
        senderId: { not: currentUserId },
        readAt: null,
      },
      data: {
        readAt: new Date(),
      },
    });

    const skip = (query.page - 1) * query.limit;
    const take = query.limit;

    const total = await this.prisma.message.count({
      where: { conversationId },
    });
    const totalPages = Math.ceil(total / query.limit);

    const messages = await this.prisma.message.findMany({
      where: { conversationId },
      orderBy: { createdAt: 'asc' },
      skip,
      take,
    });

    return {
      data: messages.map((msg: any) => this.mapMessage(msg)),
      meta: {
        page: query.page,
        limit: query.limit,
        total,
        totalPages,
      },
    };
  }

  async sendMessage(currentUserId: string, conversationId: string, dto: CreateMessageDto) {
    const conversation = await this.prisma.conversation.findUnique({
      where: { id: conversationId },
    });

    if (!conversation) {
      throw new NotFoundException('Conversation not found');
    }

    if (conversation.buyerId !== currentUserId && conversation.sellerId !== currentUserId) {
      throw new ForbiddenException('You do not have access to this conversation');
    }

    const message = await this.prisma.message.create({
      data: {
        conversationId,
        senderId: currentUserId,
        body: dto.body,
      },
    });

    // Update conversation updatedAt to bump it to the top of inbox list
    await this.prisma.conversation.update({
      where: { id: conversationId },
      data: { updatedAt: new Date() },
    });

    return {
      data: this.mapMessage(message),
    };
  }

  // Response Mappers
  private mapUser(user: any) {
    if (!user) return null;
    return {
      id: user.id,
      fullName: user.profile?.fullName ?? 'Foydalanuvchi',
      role: user.role,
      isVerified: user.isVerified,
    };
  }

  private mapListing(listing: any) {
    if (!listing) return null;
    return {
      id: listing.id,
      title: listing.title,
      type: listing.type,
      priceAmount: listing.priceAmount ? listing.priceAmount.toString() : null,
      priceCurrency: listing.priceCurrency,
      unit: listing.unit,
      status: listing.status,
    };
  }

  private mapMessage(message: any) {
    if (!message) return null;
    return {
      id: message.id,
      conversationId: message.conversationId,
      senderId: message.senderId,
      body: message.body,
      createdAt: message.createdAt.toISOString(),
      readAt: message.readAt ? message.readAt.toISOString() : null,
    };
  }

  private mapConversation(conv: any, lastMessage: any, unreadCount: number, currentUserId: string) {
    const otherParticipant = conv.buyerId === currentUserId ? conv.seller : conv.buyer;
    return {
      id: conv.id,
      listing: this.mapListing(conv.listing),
      buyer: this.mapUser(conv.buyer),
      seller: this.mapUser(conv.seller),
      otherParticipant: this.mapUser(otherParticipant),
      lastMessage: this.mapMessage(lastMessage),
      unreadCount,
      createdAt: conv.createdAt.toISOString(),
      updatedAt: conv.updatedAt.toISOString(),
    };
  }
}
