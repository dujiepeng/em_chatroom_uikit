import 'dart:convert';

import 'package:chatroom_uikit/chatroom_uikit.dart';

extension PutWithoutNull on Map<String, dynamic> {
  void putIfNotNull(String key, dynamic value) {
    if (value != null) {
      this[key] = value;
    }
  }
}

extension Notify on ChatMessage {
  bool isJoinNotify() {
    if (body.type == BodyType.CUSTOM) {
      if (ChatRoomUIKitEvent.userJoinEvent == (body as CustomBody).event) {
        return true;
      }
    }
    return false;
  }
}

extension GlobalNotify on ChatMessage {
  bool isGlobalNotify() {
    // TODO: 实现广播消息解析
    return false;
  }
}

extension Gift on ChatMessage {
  bool isGiftMsg() {
    if (body.type == BodyType.CUSTOM) {
      return (body as CustomBody).event == ChatRoomUIKitEvent.giftEvent;
    } else {
      return false;
    }
  }

  GiftEntityProtocol? getGiftEntity() {
    GiftEntityProtocol? ret;
    do {
      if (body.type != BodyType.CUSTOM) break;
      if ((body as CustomBody).event != ChatRoomUIKitEvent.giftEvent) break;
      if ((body as CustomBody).params == null) break;
      if (!(body as CustomBody).params!.containsKey(ChatRoomUIKitEvent.gift)) {
        break;
      }
      String? jString = (body as CustomBody).params![ChatRoomUIKitEvent.gift];
      final map = json.decode(jString!);
      ret = ChatRoomUIKitClient.instance.giftService.giftFromJson(map);
    } while (false);

    return ret;
  }
}

extension UserInfo on ChatMessage {
  void addUserEntity() {
    UserInfoProtocol? userInfo =
        ChatRoomContext.instance.userInfosMap[Client.getInstance.currentUserId];
    if (userInfo != null) {
      Map<String, dynamic>? map =
          ChatRoomUIKitClient.instance.userService.userToJson(userInfo);
      if (map?.isNotEmpty == true) {
        attributes ??= {};
        attributes![ChatRoomUIKitEvent.userInfo] = map;
      }
    }
  }

  UserInfoProtocol? getUserEntity() {
    Map<String, dynamic>? map = attributes?[ChatRoomUIKitEvent.userInfo];
    if (map != null) {
      return ChatRoomUIKitClient.instance.userService.userFromJson(map);
    } else {
      return null;
    }
  }
}
