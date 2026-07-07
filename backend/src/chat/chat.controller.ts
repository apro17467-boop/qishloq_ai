import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../auth/types/authenticated-user.type';
import { ChatService } from './chat.service';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { CreateMessageDto } from './dto/create-message.dto';
import { ConversationsQueryDto } from './dto/conversations-query.dto';
import { MessagesQueryDto } from './dto/messages-query.dto';

@Controller('conversations')
@ApiTags('Chat')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Post()
  createConversation(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateConversationDto,
  ) {
    return this.chatService.createConversation(user.sub, dto);
  }

  @Get('my')
  getMyConversations(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: ConversationsQueryDto,
  ) {
    return this.chatService.getMyConversations(user.sub, query);
  }

  @Get(':id/messages')
  getMessages(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) id: string,
    @Query() query: MessagesQueryDto,
  ) {
    return this.chatService.getMessages(user.sub, id, query);
  }

  @Post(':id/messages')
  sendMessage(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', new ParseUUIDPipe()) id: string,
    @Body() dto: CreateMessageDto,
  ) {
    return this.chatService.sendMessage(user.sub, id, dto);
  }
}
