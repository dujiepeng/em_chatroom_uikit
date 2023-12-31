// ignore_for_file: empty_catches

import 'package:chatroom_uikit/chatroom_uikit.dart';

import 'package:chatroom_uikit/default/controllers/default_members_controller.dart';
import 'package:chatroom_uikit/default/controllers/default_mutes_controller.dart';
import 'package:flutter/material.dart';

class ChatRoomUIKitEvent {
  static String userJoinEvent = 'CHATROOMUIKITUSERJOIN';
  static String userInfo = 'chatroom_uikit_userInfo';
  static String giftEvent = 'CHATROOMUIKITGIFT';
  static String gift = 'chatroom_uikit_gift';
}

/// All business service errors
enum RoomEventsType {
  join,
  leave,
  destroyed,
  kick,
  mute,
  unmute,
  translate,
  recall,
  report,
  fetchParticipants,
  fetchMutes,
  sendMessage,
}

class ChatroomEventListener {
  ChatroomEventListener(
    this.onEventResultChanged,
  );
  final void Function(RoomEventsType type, ChatError? error)?
      onEventResultChanged;
}

class ChatroomController with ChatroomResponse, ChatroomEventResponse {
  ChatroomController({
    required this.roomId,
    required this.ownerId,
    this.listener,
    this.giftControllers,
    List<ChatRoomParticipantPageController>? participantControllers,
  }) {
    List<ChatRoomParticipantPageController> list = [DefaultMembersController()];
    if (ownerId == Client.getInstance.currentUserId) {
      list.add(DefaultMutesController());
    }

    this.participantControllers = participantControllers ?? list;
    ChatRoomUIKitClient.instance.roomService.bindResponse(this);
    ChatRoomUIKitClient.instance.bindRoomEventResponse(this);
  }
  final String roomId;
  final String ownerId;
  final ChatroomEventListener? listener;
  bool isOwner() {
    return ownerId == Client.getInstance.currentUserId;
  }

  late final List<ChatRoomParticipantPageController> participantControllers;
  final Future<List<ChatRoomGiftPageController>?>? giftControllers;

  // late final String _eventKey;

  // ignore: unused_field
  ChatInputBarState? _inputBarState;

  VoidCallback? _showParticipantsViewAction;
  ChatRoomShowGiftListAction? _showGiftsViewAction;

  void dispose() {
    ChatRoomUIKitClient.instance.roomService.unbindResponse(this);
    ChatRoomUIKitClient.instance.unbindRoomEventResponse(this);
  }

  @override
  void onEventResultChanged(
      String roomId, RoomEventsType type, ChatError? error) {
    if (roomId == this.roomId) {
      listener?.onEventResultChanged?.call(type, error);
    }
  }
}

extension Actions on ChatroomController {
  void showParticipantPages() {
    _showParticipantsViewAction?.call();
  }

  void showGiftSelectPages() {
    giftControllers?.then((value) {
      if (value?.isNotEmpty == true) {
        _showGiftsViewAction?.call(value!);
      }
    });
  }

  void hiddenInputBar() {
    _inputBarState?.hiddenInputBar();
  }
}

extension ChatroomImplement on ChatroomController {
  Future<void> chatroomOperating(
    ChatroomOperationType type,
  ) async {
    try {
      await ChatRoomUIKitClient.instance.chatroomOperating(
        roomId: roomId,
        type: type,
      );
    } on ChatError {}
  }

  Future<void> operatingUser(
    String roomId,
    ChatroomUserOperationType type,
    String userId,
  ) async {
    try {
      await ChatRoomUIKitClient.instance.operatingUser(
        roomId: roomId,
        userId: userId,
        type: type,
      );
    } on ChatError {}
  }

  Future<void> sendMessage(String content) async {
    try {
      await ChatRoomUIKitClient.instance.sendRoomMessage(
        roomId: roomId,
        message: content,
      );
    } on ChatError {}
  }

  Future<void> sendGift(GiftEntityProtocol gift) async {
    try {
      await ChatRoomUIKitClient.instance.sendGift(
        roomId: roomId,
        gift: gift,
      );
    } on ChatError {}
  }

  Future<ChatMessage?> translateMessage({
    required ChatMessage message,
    required LanguageCode languageCode,
  }) async {
    try {
      return await ChatRoomUIKitClient.instance.translateMessage(
          roomId: roomId, message: message, language: languageCode);
    } on ChatError {
      return Future.value();
    }
  }

  Future<void> recall(
      {required String roomId, required ChatMessage message}) async {
    try {
      await ChatRoomUIKitClient.instance.recall(
        roomId: roomId,
        message: message,
      );
    } on ChatError {}
  }

  Future<void> report({
    required String messageId,
    required String tag,
    required String reason,
  }) async {
    try {
      await ChatRoomUIKitClient.instance.report(
        roomId: roomId,
        messageId: messageId,
        tag: tag,
        reason: reason,
      );
    } on ChatError {}
  }
}

extension ChatUIKitExt on ChatroomController {
  void setInputBarState(ChatInputBarState? state) {
    _inputBarState = state;
  }

  void setShowParticipantsViewCallback(VoidCallback? callback) {
    _showParticipantsViewAction = callback;
  }

  void setShowGiftsViewCallback(ChatRoomShowGiftListAction? callback) {
    _showGiftsViewAction = callback;
  }
}
