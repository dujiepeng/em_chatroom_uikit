import 'package:chatroom_uikit/chatroom_uikit.dart';
import 'package:chatroom_uikit/utils/extension.dart';

class ChatRoomServiceImplement extends ChatRoomService {
  List<ChatroomResponse> responses = [];

  ChatRoomServiceImplement() {
    _addListener();
  }

  @override
  void dispose() {
    _removeListener();
  }

  @override
  void bindResponse(ChatroomResponse response) {
    if (responses.contains(response)) return;
    responses.add(response);
  }

  @override
  void unbindResponse(ChatroomResponse response) {
    responses.remove(response);
  }

  @override
  Future<void> chatroomOperating({
    required String roomId,
    required ChatroomOperationType type,
  }) async {
    switch (type) {
      case ChatroomOperationType.join:
        await Client.getInstance.chatRoomManager.joinChatRoom(roomId);
        await _sendJoinMessage(roomId: roomId);
        break;
      case ChatroomOperationType.leave:
        await Client.getInstance.chatRoomManager.leaveChatRoom(roomId);
        break;
      case ChatroomOperationType.destroyed:
        await Client.getInstance.chatRoomManager.destroyChatRoom(roomId);
        break;

      default:
    }
  }

  @override
  Future<String?> fetchAnnouncement({required String roomId}) async {
    return await Client.getInstance.chatRoomManager
        .fetchChatRoomAnnouncement(roomId);
  }

  @override
  Future<void> operatingUser({
    required String roomId,
    required ChatroomUserOperationType type,
    required String userId,
  }) async {
    switch (type) {
      case ChatroomUserOperationType.mute:
        await Client.getInstance.chatRoomManager.muteChatRoomMembers(
          roomId,
          [userId],
          duration: -1,
        );
        break;
      case ChatroomUserOperationType.unmute:
        await Client.getInstance.chatRoomManager.unMuteChatRoomMembers(
          roomId,
          [userId],
        );
        break;
      case ChatroomUserOperationType.kick:
        await Client.getInstance.chatRoomManager.removeChatRoomMembers(
          roomId,
          [userId],
        );
        break;
      default:
        break;
    }
  }

  @override
  Future<void> sendRoomMessage({
    required String roomId,
    required String message,
    List<String>? receiver,
  }) async {
    final msg = ChatMessage.createTxtSendMessage(
      targetId: roomId,
      content: message,
      chatType: MsgType.ChatRoom,
    );
    msg.addUserEntity();
    if (receiver?.isNotEmpty == true) {
      msg.receiverList = receiver;
    }
    Client.getInstance.chatManager.sendMessage(msg);
  }

  @override
  Future<void> sendCustomMessage({
    required String roomId,
    required String event,
    Map<String, String>? params,
    List<String>? receiver,
  }) async {
    final msg = ChatMessage.createCustomSendMessage(
      targetId: roomId,
      event: event,
      params: params,
      chatType: MsgType.ChatRoom,
    );
    msg.addUserEntity();
    if (receiver?.isNotEmpty == true) {
      msg.receiverList = receiver;
    }
    Client.getInstance.chatManager.sendMessage(msg);
  }

  @override
  Future<ChatMessage> translateMessage({
    required String roomId,
    required ChatMessage message,
    required LanguageCode language,
  }) async {
    ChatMessage msg = await Client.getInstance.chatManager.translateMessage(
      msg: message,
      languages: [language.code],
    );
    _onMessageTransformed(roomId, msg);
    return msg;
  }

  @override
  Future<void> updateAnnouncement({
    required String roomId,
    required String announcement,
  }) async {
    await Client.getInstance.chatRoomManager.updateChatRoomAnnouncement(
      roomId,
      announcement,
    );
  }

  Future<void> _sendJoinMessage({
    required String roomId,
  }) async {
    sendCustomMessage(roomId: roomId, event: ChatRoomUIKitEvent.userJoinEvent);
  }

  @override
  Future<void> recall(
      {required String roomId, required ChatMessage message}) async {
    try {
      await Client.getInstance.chatManager.recallMessage(message.msgId);
      _onMessageRecalled(roomId, message);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> report({
    required String messageId,
    required String tag,
    required String reason,
  }) async {
    await Client.getInstance.chatManager.reportMessage(
      messageId: messageId,
      tag: tag,
      reason: reason,
    );
  }

  void sendEventResult(RoomEventsType type, ChatError? error) {
    _onEventResultChanged(type, error);
  }
}

extension ChatroomEventsListener on ChatRoomServiceImplement {
  void _onEventResultChanged(RoomEventsType type, ChatError? error) {}

  void _onMuteListAddedFromChatRoom(
    String roomId,
    List<String> mutes,
  ) {
    for (var response in responses) {
      response.onUserMuted.call(roomId, mutes);
    }
  }

  void _onMuteListRemovedFromChatRoom(
    String roomId,
    List<String> mutes,
  ) {
    for (var response in responses) {
      response.onUserUnmuted.call(roomId, mutes);
    }
  }

  void _onMemberExitedFromChatRoom(
    String roomId,
    String participant,
  ) async {
    for (var response in responses) {
      ChatRoomContext.instance.userInfosMap.remove(participant);
      response.onUserLeave(roomId, participant);
    }
  }

  void _onRemovedFromChatRoom(
    String roomId,
    RoomLeaveReason? reason,
  ) {
    for (var response in responses) {
      if (reason == RoomLeaveReason.Kicked) {
        response.onUserBeKicked(roomId, ChatroomBeKickedReason.removed);
      } else if (reason == RoomLeaveReason.Offline) {
        response.onUserBeKicked(roomId, ChatroomBeKickedReason.offline);
      }
    }
  }

  void _onChatRoomDestroyed(String roomId) {
    for (var response in responses) {
      response.onUserBeKicked(roomId, ChatroomBeKickedReason.destroyed);
    }
  }

  void _onAnnouncementChangedFromChatRoom(
    String roomId,
    String announcement,
  ) {
    for (var response in responses) {
      response.onAnnouncementUpdate(roomId, announcement);
    }
  }

  void _addListener() {
    Client.getInstance.chatRoomManager.addEventHandler(
      "ChatRoomServiceImplement",
      ChatRoomEventHandler(
        onMuteListAddedFromChatRoom: (roomId, mutes, expireTime) {
          _onMuteListAddedFromChatRoom(roomId, mutes);
        },
        onMuteListRemovedFromChatRoom: (roomId, mutes) {
          _onMuteListRemovedFromChatRoom(roomId, mutes);
        },
        onMemberExitedFromChatRoom: (roomId, roomName, participant) {
          _onMemberExitedFromChatRoom(roomId, participant);
        },
        onRemovedFromChatRoom: (roomId, roomName, participant, reason) {
          _onRemovedFromChatRoom(roomId, reason);
        },
        onAnnouncementChangedFromChatRoom: (roomId, announcement) {
          _onAnnouncementChangedFromChatRoom(roomId, announcement);
        },
        onChatRoomDestroyed: (roomId, roomName) {
          _onChatRoomDestroyed(roomId);
        },
      ),
    );

    Client.getInstance.chatManager.addMessageEvent(
      'ChatRoomServiceImplement',
      MessageEvent(
        onSuccess: (msgId, msg) {
          _onMessagesReceived([msg]);
        },
        onError: (msgId, msg, error) {
          for (var element in ChatRoomUIKitClient.instance.banders) {
            element.onEventResultChanged(
              msg.conversationId!,
              RoomEventsType.sendMessage,
              error,
            );
          }
        },
      ),
    );

    Client.getInstance.chatManager.addEventHandler(
      'ChatRoomServiceImplement',
      ChatEventHandler(
        onMessagesRecalled: (messages) {
          Map<String, List<ChatMessage>> map = {};
          for (var msg in messages) {
            List<ChatMessage> list = map[msg.conversationId] ?? [];
            list.add(msg);
          }
          for (var response in responses) {
            for (var element in map.keys) {
              response.onMessageRecalled(element, map[element]!);
            }
          }
        },
        onMessagesReceived: (messages) {
          _onMessagesReceived(messages);
        },
      ),
    );
  }

  void _onMessageRecalled(
    String roomId,
    ChatMessage message,
  ) {
    for (var response in responses) {
      response.onMessageRecalled(roomId, [message]);
    }
  }

  void _onMessageTransformed(
    String roomId,
    ChatMessage message,
  ) {
    for (var response in responses) {
      response.onMessageTransformed(roomId, message);
    }
  }

  void _onMessagesReceived(List<ChatMessage> messages) {
    Map<String, List<ChatMessage>> receives = {};
    Map<String, List<ChatMessage>> join = {};
    Map<String, List<ChatMessage>> globalNotifies = {};

    for (var msg in messages) {
      if (msg.isGiftMsg()) {
        break;
      }
      final info = msg.getUserEntity();
      if (info != null) {
        ChatRoomContext.instance.userInfosMap[info.userId] = info;
      }

      if (msg.isGlobalNotify()) {
        List<ChatMessage> list = globalNotifies[msg.conversationId] ?? [];
        list.add(msg);
        globalNotifies[msg.conversationId!] = list;
      } else if (msg.isJoinNotify()) {
        List<ChatMessage> list = join[msg.conversationId] ?? [];
        list.add(msg);
        join[msg.conversationId!] = list;
      } else {
        List<ChatMessage> list = receives[msg.conversationId] ?? [];
        list.add(msg);
        receives[msg.conversationId!] = list;
      }
    }

    if (join.isNotEmpty) {
      for (var response in responses) {
        for (var element in join.keys) {
          response.onUserJoined(element, join[element]!);
        }
      }
    }

    if (receives.isNotEmpty) {
      for (var response in responses) {
        for (var element in receives.keys) {
          response.onMessageReceived(element, receives[element]!);
        }
      }
    }

    if (globalNotifies.isNotEmpty) {
      for (var response in responses) {
        for (var element in receives.keys) {
          response.onGlobalNotifyReceived(element, receives[element]!);
        }
      }
    }

    // TODO: test notify.
    for (var response in responses) {
      for (var element in receives.keys) {
        response.onGlobalNotifyReceived(element, receives[element]!);
      }
    }
  }

  void _removeListener() {
    Client.getInstance.chatRoomManager.removeEventHandler(
      'ChatRoomServiceImplement',
    );
    Client.getInstance.chatManager
        .removeEventHandler('ChatRoomServiceImplement');

    Client.getInstance.chatManager
        .removeMessageEvent('ChatRoomServiceImplement');
  }
}
